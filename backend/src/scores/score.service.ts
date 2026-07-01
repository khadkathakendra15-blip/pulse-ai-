import { Injectable } from '@nestjs/common';

/// Per-signal sub-scores (0–100). Any may be omitted if the device/day
/// lacks that metric — weights are renormalised over what's present.
export interface SignalScores {
  sleep?: number;
  hrv?: number;
  heart?: number;
  stress?: number;
  activity?: number;
  recovery?: number;
}

export interface ScoreResult {
  health: number;
  recovery: number;
  readiness: number;
  breakdown: {
    weights: Record<string, number>;
    signals: SignalScores;
  };
}

/// Composite health-score math. Mirrors the weighting surfaced in the app's
/// "How is 92 calculated?" card: Sleep 30 · HRV 25 · Heart 20 · Stress 10 ·
/// Activity 10 · Recovery 5.
@Injectable()
export class ScoreService {
  static readonly WEIGHTS: Record<keyof SignalScores, number> = {
    sleep: 0.3,
    hrv: 0.25,
    heart: 0.2,
    stress: 0.1,
    activity: 0.1,
    recovery: 0.05,
  };

  compute(signals: SignalScores): ScoreResult {
    const health = this.weighted(signals);

    // Recovery leans on overnight signals; Readiness blends recovery with
    // today's activity capacity. Both reuse the same sub-scores.
    const recovery = this.weighted(signals, { sleep: 0.4, hrv: 0.35, heart: 0.25 });
    const readiness = this.weighted(signals, { recovery: 0.5, hrv: 0.3, stress: 0.2 });

    return {
      health,
      recovery,
      readiness,
      breakdown: { weights: ScoreService.WEIGHTS, signals },
    };
  }

  /// Weighted average over present signals, renormalising weights so missing
  /// metrics don't drag the score toward zero.
  private weighted(signals: SignalScores, weights: Partial<Record<keyof SignalScores, number>> = ScoreService.WEIGHTS): number {
    let sum = 0;
    let wsum = 0;
    for (const key of Object.keys(weights) as (keyof SignalScores)[]) {
      const v = signals[key];
      const w = weights[key]!;
      if (typeof v === 'number') {
        sum += v * w;
        wsum += w;
      }
    }
    if (wsum === 0) return 0;
    return Math.round(sum / wsum);
  }
}
