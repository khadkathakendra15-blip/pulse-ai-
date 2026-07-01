import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser, AuthUser } from '../auth/current-user.decorator';
import { HealthService } from './health.service';
import { IngestDto } from './dto';

@UseGuards(JwtAuthGuard)
@Controller('health')
export class HealthController {
  constructor(private readonly health: HealthService) {}

  /// Bulk sample upload from a band sync.
  @Post('samples')
  ingest(@CurrentUser() user: AuthUser, @Body() dto: IngestDto) {
    return this.health.ingest(user.id, dto.samples);
  }

  @Get('vitals')
  vitals(@CurrentUser() user: AuthUser) {
    return this.health.latestVitals(user.id);
  }

  /// Composite payload the mobile app renders the Today/Score screens from.
  @Get('dashboard')
  dashboard(@CurrentUser() user: AuthUser) {
    return this.health.dashboard(user.id);
  }
}
