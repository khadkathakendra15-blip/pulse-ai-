import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface RegisterDeviceInput {
  mac: string;
  name?: string;
  platform?: string;
  firmware?: string;
}

@Injectable()
export class DevicesService {
  constructor(private readonly prisma: PrismaService) {}

  list(userId: string) {
    return this.prisma.device.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  /// Idempotent: re-registering the same MAC updates metadata instead of
  /// creating a duplicate (matches the band re-pairing flow).
  register(userId: string, input: RegisterDeviceInput) {
    return this.prisma.device.upsert({
      where: { userId_mac: { userId, mac: input.mac } },
      create: { userId, ...input },
      update: { name: input.name, platform: input.platform, firmware: input.firmware },
    });
  }

  markSynced(userId: string, mac: string) {
    return this.prisma.device.update({
      where: { userId_mac: { userId, mac } },
      data: { lastSyncAt: new Date() },
    });
  }

  remove(userId: string, id: string) {
    return this.prisma.device.deleteMany({ where: { id, userId } });
  }
}
