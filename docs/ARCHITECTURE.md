# Pulse AI — System Architecture

A **modular monolith**, deliberately chosen over microservices for the MVP: one
backend, one AI service, one app, one database. It scales to ~50–100k users and
keeps development fast and cheap; split services out (AI, notifications,
analytics) only when a real bottleneck appears.

```
 Health Band (QRing / QCBandSDK)
        │  BLE
        ▼
 Flutter app ──── REST (JWT) ────► NestJS backend (API gateway + domain)
   (lib/data/api_client.dart)            │            │
                                         │            └── Postgres (+ TimescaleDB later)
                                         │            └── Redis (sessions / cache / queues)
                                         ▼
                                 FastAPI AI engine ──► Claude (Anthropic) / ML
                                 (scores · Pulse Coach)
```

## Components

| Layer | Tech | Where |
|---|---|---|
| Mobile app | Flutter (Dart) | `pulse_ai_app/` |
| BLE bridge | Kotlin (QRing AAR) + Swift (QCBandSDK) via platform channels | `pulse_ai_app/native_templates/` |
| Backend / API gateway | NestJS (TypeScript) + Prisma | `backend/` |
| AI engine | Python + FastAPI + Anthropic SDK | `ai-engine/` |
| Database | PostgreSQL | `backend/prisma/schema.prisma` |
| Cache / queues | Redis | (wired via `REDIS_URL`) |
| Local stack | Docker Compose | `infra/docker-compose.yml` |

## Backend modules (`backend/src/`)

`auth` (JWT register/login) · `users` · `devices` (band registration) ·
`health` (sample ingest + the dashboard aggregation the app renders) ·
`scores` (composite Health/Recovery/Readiness math) · `ai` (gateway to the
FastAPI engine) · `subscriptions` (plan + eSewa/Khalti/Fonepay/Stripe stubs).

All domains live in one deployable. Module boundaries are clean, so peeling one
into its own service later is a lift-and-shift, not a rewrite.

## Data flow

1. **Band → app** over BLE (native SDKs, bridged to Flutter).
2. **App → backend**: `POST /api/health/samples` uploads readings;
   `GET /api/health/dashboard` returns composite scores + latest vitals.
3. **Scoring**: `ScoreService` weights signals — Sleep 30 · HRV 25 · Heart 20 ·
   Stress 10 · Activity 10 · Recovery 5 (renormalised over present signals).
4. **Coach**: `POST /api/ai/coach` → backend attaches the user's health context →
   FastAPI engine answers (deterministic bilingual replies for quick prompts, or
   a Claude-grounded free-form reply). Calls are logged to `AiLog`.

## Scaling path (when, not now)

- **Time-series volume** → convert `HealthSample` to a **TimescaleDB** hypertable
  (Postgres extension; no schema rewrite).
- **AI load / latency** → the FastAPI engine is already a separate process;
  scale it horizontally or move it to its own deployment.
- **Notifications / analytics** → extract into services once they justify it
  (FCM for Morning Brief / alerts; PostHog or Mixpanel for retention/DAU).
- **Auth** → swap self-hosted JWT for Firebase/Supabase Auth if you want managed
  social/OTP login (the `auth` module is the only thing that changes).

## Health-claim boundary

Ring/band BP, SpO₂, and glucose are **wellness estimates, not medical readings**.
The coach prompt enforces non-diagnostic framing and defers to clinicians.
