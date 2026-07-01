# Pulse AI

AI health platform for the **QRing (Android)** and **QWatchPro / QCBandSDK (iOS)**
wearables — band → app → AI coaching, scores, and insights.

Built as a **modular monolith** (one backend, one AI service, one app, one DB) —
the right starting architecture for scaling to ~50–100k users without
microservice overhead. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Repository layout

```
Pulse Ai/
  pulse_ai_app/     Flutter app — 5-tab bilingual UI + BLE bridge + API client
  backend/          NestJS API gateway (auth, devices, health, scores, ai, subs) + Prisma
  ai-engine/        FastAPI AI engine — composite scoring + Pulse Coach (Claude)
  infra/            docker-compose for the local stack
  docs/             architecture
  QRing_Android_SDK_*/ , QWatchPro_iOS_SDK_*/    vendor wearable SDKs
```

## Final tech stack

| Layer | Technology |
|---|---|
| Mobile | Flutter |
| BLE integration | Kotlin (QRing) + Swift (QCBandSDK) bridged to Flutter |
| Backend API | NestJS (TypeScript) + Prisma |
| AI services | Python + FastAPI |
| AI models | Anthropic Claude (`claude-opus-4-8`) + room for custom ML |
| Database | PostgreSQL (+ TimescaleDB when time-series volume grows) |
| Cache / queues | Redis |
| Auth | self-hosted JWT (swap for Firebase/Supabase Auth if desired) |
| Notifications | Firebase Cloud Messaging (planned) |
| Admin / Website | Next.js (planned — Phase 2) |
| Analytics | PostHog / Mixpanel (planned) |

## Run the whole stack (Docker)

```bash
cp backend/.env.example backend/.env        # adjust if needed
ANTHROPIC_API_KEY=sk-...                     # optional — coach falls back to canned replies without it
docker compose -f infra/docker-compose.yml up --build
# backend → http://localhost:3000/api   ·   ai-engine → http://localhost:8000
```

> Docker isn't installed on the current dev machine — install Docker Desktop, or
> run each service directly (below) against a local/hosted Postgres + Redis.

## Run services directly (no Docker)

**Backend** (needs Postgres + Redis reachable via `backend/.env`):
```bash
cd backend
npm install
npx prisma migrate dev --name init     # creates tables
npm run start:dev                        # http://localhost:3000/api
```

**AI engine:**
```bash
cd ai-engine
python -m venv .venv && .venv\Scripts\activate     # Windows
pip install -r requirements.txt
setx ANTHROPIC_API_KEY sk-...                       # optional
uvicorn app.main:app --reload --port 8000
```

**App:** see [pulse_ai_app/README.md](pulse_ai_app/README.md). Point it at the
backend with `--dart-define=PULSE_API_BASE=http://10.0.2.2:3000/api` (Android
emulator → host).

## API surface (backend)

| Method | Path | Purpose |
|---|---|---|
| POST | `/api/auth/register`, `/api/auth/login` | JWT auth |
| GET/PATCH | `/api/users/me` | profile + language |
| GET/POST/DELETE | `/api/devices` | band registration |
| POST | `/api/health/samples` | bulk band-sample upload |
| GET | `/api/health/dashboard` | composite scores + latest vitals (app renders this) |
| POST | `/api/ai/coach` | Pulse Coach reply |
| GET/POST | `/api/subscriptions/me`, `/checkout` | plan + payment (provider stubs) |

## Status & what needs external sources

✅ Backend (auth, devices, health ingest, scoring, AI gateway, subs) — typechecks clean
✅ AI engine (scoring + Pulse Coach, Claude-grounded with deterministic fallback) — syntax-clean
✅ Flutter API client wired (`lib/data/api_client.dart`)

⏳ **External sources to provide later:** `ANTHROPIC_API_KEY`; payment merchant
credentials (eSewa/Khalti/Fonepay/Stripe); FCM project; the native BLE handlers
(templates in `pulse_ai_app/native_templates/`); a Postgres instance (Docker or hosted).

⏳ **Phase 2:** Next.js admin panel + marketing site, FCM notifications, PostHog
analytics, TimescaleDB migration.
