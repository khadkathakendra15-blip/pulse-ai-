import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { IsIn } from 'class-validator';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser, AuthUser } from '../auth/current-user.decorator';
import { SubscriptionsService } from './subscriptions.service';

class CheckoutDto {
  @IsIn(['PRO', 'CORPORATE'])
  plan!: string;

  @IsIn(['esewa', 'khalti', 'fonepay', 'stripe'])
  provider!: string;
}

@UseGuards(JwtAuthGuard)
@Controller('subscriptions')
export class SubscriptionsController {
  constructor(private readonly subs: SubscriptionsService) {}

  @Get('me')
  mine(@CurrentUser() user: AuthUser) {
    return this.subs.mine(user.id);
  }

  @Post('checkout')
  checkout(@CurrentUser() user: AuthUser, @Body() dto: CheckoutDto) {
    return this.subs.startCheckout(user.id, dto.plan, dto.provider);
  }
}
