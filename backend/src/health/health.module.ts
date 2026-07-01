import { Module } from '@nestjs/common';
import { ScoresModule } from '../scores/scores.module';
import { HealthController } from './health.controller';
import { HealthService } from './health.service';

@Module({
  imports: [ScoresModule],
  controllers: [HealthController],
  providers: [HealthService],
  exports: [HealthService],
})
export class HealthModule {}
