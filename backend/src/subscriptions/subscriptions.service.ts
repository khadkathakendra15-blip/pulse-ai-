import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SubscriptionsService {
  constructor(private readonly prisma: PrismaService) {}

  async mine(userId: string) {
    const sub = await this.prisma.subscription.findUnique({ where: { userId } });
    return sub ?? this.prisma.subscription.create({ data: { userId } });
  }

  /// Begin a checkout for a paid plan.
  ///
  /// Payment providers are integrated here:
  ///   - Nepal: eSewa, Khalti, Fonepay (server creates an order, returns a
  ///     redirect/intent; a webhook confirms and flips `status`/`plan`).
  ///   - International: Stripe (PaymentIntent / Checkout Session).
  /// These require merchant credentials (external sources) — wire the chosen
  /// provider's SDK in `startCheckout` and confirm in a webhook controller.
  async startCheckout(_userId: string, plan: string, provider: string) {
    // TODO: integrate the provider SDK and return its checkout/redirect payload.
    return {
      status: 'not_configured',
      message: `Checkout for ${plan} via ${provider} needs merchant credentials.`,
    };
  }
}
