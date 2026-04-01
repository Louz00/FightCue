# Backend

This folder contains the TypeScript API and source-ingestion services for FightCue.

## Local setup

1. Copy `.env.example` to `.env`
2. Start PostgreSQL for local development
3. Run `npm install`
4. Run `npm run migrate`
5. Run `npm run dev`

Recommended local database connection:

```bash
DATABASE_URL=postgres://postgres:postgres@localhost:5432/fightcue
```

If you already have Homebrew PostgreSQL installed, you can start a project-local instance with:

```bash
npm run db:start-local
```

And stop it with:

```bash
npm run db:stop-local
```

Then run the backend in strict database mode:

```bash
cp .env.example .env
npm run db:verify-required
npm run migrate
npm run dev
```

By default, the backend now expects PostgreSQL to be available and will fail fast if `DATABASE_URL` is missing.

You can also explicitly verify the required-database path before running the server:

```bash
npm run db:verify-required
```

If you explicitly want the old file-based fallback for a local throwaway run, set:

```bash
FIGHTCUE_ALLOW_FILE_STATE_FALLBACK=true
```

You can also explicitly disable strict database mode with:

```bash
FIGHTCUE_REQUIRE_DATABASE=false
```

If you want stateful routes to reject raw device-id fallback and require signed device tokens after bootstrap, set:

```bash
FIGHTCUE_REQUIRE_SIGNED_DEVICE_TOKEN=true
```

If `initdb` fails in a restricted environment with a shared-memory error, run the same commands in your normal macOS terminal instead of a sandboxed session.

## Push delivery providers

FightCue now supports three backend push modes:

- `FIGHTCUE_PUSH_PROVIDER=disabled`
- `FIGHTCUE_PUSH_PROVIDER=log`
- `FIGHTCUE_PUSH_PROVIDER=firebase`

The default remains `log`, which is useful for local development.

To enable Firebase-backed test delivery, configure one of:

```bash
FIGHTCUE_PUSH_PROVIDER=firebase
FIGHTCUE_FIREBASE_PROJECT_ID=your-project-id
FIGHTCUE_FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}'
```

or:

```bash
FIGHTCUE_PUSH_PROVIDER=firebase
FIGHTCUE_FIREBASE_PROJECT_ID=your-project-id
GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/service-account.json
```

If Firebase is selected but credentials are missing, the provider will stay visible in the API but test sends will be blocked with a clear message instead of failing silently.

## Scheduled reminder worker

FightCue can also run a lightweight in-process worker that periodically dispatches due reminders.

```bash
FIGHTCUE_PUSH_WORKER_ENABLED=true
FIGHTCUE_PUSH_WORKER_INTERVAL_SECONDS=60
FIGHTCUE_PUSH_WORKER_LOOKBACK_MINUTES=15
```

The worker uses the same push provider configuration as manual test sends. It is safe to keep disabled in local development until you are ready to validate reminder delivery end to end.

## Current responsibilities

- organizations and events endpoints
- favorites and alerts persistence
- subscription verification
- calendar ICS generation
- source ingestion and normalization

## Persistence

- PostgreSQL-backed user state is implemented for preferences, follows, and alert presets
- SQL migrations live in [migrations](/Users/lou/FightCue/backend/migrations)
- PostgreSQL is now the default runtime expectation for local and future production-like runs
- Per-device JSON storage remains available only as an explicit fallback mode
- Route-level integration tests now cover the PostgreSQL-backed API behavior through Fastify injection
- Signed anonymous device tokens can now be enforced in strict mode on stateful routes
