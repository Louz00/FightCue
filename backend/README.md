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
