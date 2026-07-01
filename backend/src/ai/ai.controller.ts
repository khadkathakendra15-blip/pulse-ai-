import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { IsIn, IsOptional, IsString } from 'class-validator';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser, AuthUser } from '../auth/current-user.decorator';
import { AiService } from './ai.service';

class CoachDto {
  @IsString()
  message!: string;

  @IsOptional()
  @IsIn(['np', 'en'])
  lang?: string;

  @IsOptional()
  @IsIn(['recovery', 'plan', 'workout'])
  promptKey?: string;
}

@UseGuards(JwtAuthGuard)
@Controller('ai')
export class AiController {
  constructor(private readonly ai: AiService) {}

  @Post('coach')
  coach(@CurrentUser() user: AuthUser, @Body() dto: CoachDto) {
    return this.ai.coach(user.id, dto);
  }
}
