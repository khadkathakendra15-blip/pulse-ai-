import { Module } from '@nestjs/common';
import { HealthModule } from '../health/health.module';
import { AiController } from './ai.controller';
import { AiService } from './ai.service';

@Module({
  imports: [HealthModule],
  controllers: [AiController],
  providers: [AiService],
})
export class AiModule {}
