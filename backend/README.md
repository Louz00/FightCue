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
npm run migrate
FIGHTCUE_REQUIRE_DATABASE=true npm run dev
```

If you want the backend to fail fast instead of silently falling back to per-device JSON storage, set:

```bash
FIGHTCUE_REQUIRE_DATABASE=true
```

That is the recommended mode once PostgreSQL is running locally.

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
- Per-device JSON storage remains as a local fallback when no database is configured
- Route-level integration tests now cover the PostgreSQL-backed API behavior through Fastify injection
