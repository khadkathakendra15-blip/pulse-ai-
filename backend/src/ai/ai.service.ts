import { Injectable, Logger, ServiceUnavailableException } from '@nestjs/common';
import axios from 'axios';

import { PrismaService } from '../prisma/prisma.service';
import { HealthService } from '../health/health.service';

export interface CoachRequest {
  message: string;
  lang?: string; // 'np' | 'en'
  promptKey?: string; // 'recovery' | 'plan' | 'workout'
}

/// Thin gateway to the Python AI engine. The engine does the reasoning; the
/// backend supplies the user's health context and records the call.
@Injectable()
export class AiService {
  private readonly log = new Logger(AiService.name);
  private readonly base = process.env.AI_ENGINE_URL ?? 'http://localhost:8000';

  constructor(
    private readonly prisma: PrismaService,
    private readonly health: HealthService,
  ) {}

  async coach(userId: string, req: CoachRequest) {
    const context = await this.health.dashboard(userId);
    try {
      const { data } = await axios.post(
        `${this.base}/coach`,
        { message: req.message, lang: req.lang ?? 'np', promptKey: req.promptKey, context },
        { timeout: 30_000 },
      );
      await this.prisma.aiLog.create({
        data: {
          userId,
          kind: 'coach',
          promptKey: req.promptKey,
          model: data?.model,
          tokensIn: data?.usage?.input_tokens,
          tokensOut: data?.usage?.output_tokens,
        },
      });
      return data;
    } catch (err) {
      this.log.error(`AI engine unavailable: ${(err as Error).message}`);
      throw new ServiceUnavailableException('AI coach is temporarily unavailable');
    }
  }
}
