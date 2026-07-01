import { Controller, Get } from '@nestjs/common';

@Controller()
export class AppController {
  @Get()
  root() {
    return {
      service: 'Pulse AI Backend',
      status: 'ok',
      endpoints: [
        'POST /api/auth/register',
        'POST /api/auth/login',
        'GET  /api/users/me',
        'GET/POST /api/devices',
        'POST /api/health/samples',
        'GET  /api/health/dashboard',
        'POST /api/ai/coach',
        'GET/POST /api/subscriptions',
      ],
    };
  }

  @Get('health')
  health() {
    return { status: 'ok' };
  }
}
