import { Injectable } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { ScoreService, SignalScores } from '../scores/score.service';
import { SampleDto } from './dto';
import { METRICS, METRIC_TO_VITAL } from './metrics';

/// Latest reading per metric (nullable — band/firmware may not report all).
export interface LatestVitals {
  heartRate?: number;
  hrv?: number;
  spo2?: number;
  steps?: number;
  sleepMinutes?: number;
  stress?: number;
  temperature?: number;
  battery?: number;
}

@Injectable()
export class HealthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly scores: ScoreService,
  ) {}

  async ingest(userId: string, samples: SampleDto[]) {
    if (!samples.length) return { inserted: 0 };
    await this.prisma.healthSample.createMany({
      data: samples.map((s) => ({
        userId,
        metric: s.metric,
        value: s.value,
        unit: s.unit,
        recordedAt: new Date(s.recordedAt),
        source: s.source ?? 'band',
      })),
    });
    return { inserted: samples.length };
  }

  async latestVitals(userId: string): Promise<LatestVitals> {
    const out: LatestVitals = {};
    await Promise.all(
      METRICS.map(async (metric) => {
        const sample = await this.prisma.healthSample.findFirst({
          where: { userId, metric },
          orderBy: { recordedAt: 'desc' },
        });
        if (sample) (out as Record<string, number>)[METRIC_TO_VITAL[metric]] = sample.value;
      }),
    );
    return out;
  }

  /// Assemble the dashboard payload the Flutter app overlays onto its
  /// (bilingual) presentation layer. Falls back to demo numbers so the UI
  /// always renders, even before a band has synced.
  async dashboard(userId: string) {
    const vitals = await this.latestVitals(userId);
    const hasData = Object.keys(vitals).length > 0;
    const signals = this.deriveSignals(vitals);
    const result = this.scores.compute(
      hasData ? signals : { sleep: 95, hrv: 88, heart: 94, stress: 82, activity: 79, recovery: 89 },
    );

    return {
      bandConnected: hasData,
      updatedAt: new Date().toISOString(),
      scores: { health: result.health, recovery: result.recovery, readiness: result.readiness },
      vitals: hasData ? vitals : this.demoVitals(),
      components: result.breakdown,
    };
  }

  /// Map raw metric readings → 0–100 sub-scores. Simple, transparent
  /// normalisations; tune against population baselines later.
  deriveSignals(v: LatestVitals): SignalScores {
    const clamp = (n: number) => Math.max(0, Math.min(100, Math.round(n)));
    const s: SignalScores = {};
    if (v.sleepMinutes != null) s.sleep = clamp((v.sleepMinutes / 480) * 100); // 8h ⇒ 100
    if (v.hrv != null) s.hrv = clamp(((v.hrv - 20) / 60) * 100); // 20–80ms ⇒ 0–100
    if (v.heartRate != null) s.heart = clamp(((80 - v.heartRate) / 40) * 100); // 40bpm best
    if (v.stress != null) s.stress = clamp(100 - v.stress); // stress 0–100, inverted
    if (v.steps != null) s.activity = clamp((v.steps / 10000) * 100); // 10k ⇒ 100
    // Recovery is a blend of overnight signals when present.
    const overnight = [s.sleep, s.hrv, s.heart].filter((x): x is number => x != null);
    if (overnight.length) s.recovery = clamp(overnight.reduce((a, b) => a + b, 0) / overnight.length);
    return s;
  }

  private demoVitals(): LatestVitals {
    return { heartRate: 58, hrv: 68, spo2: 98, steps: 8400, sleepMinutes: 492, stress: 28, battery: 82 };
  }
}
