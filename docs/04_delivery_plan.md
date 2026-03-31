# Delivery Plan

## Step 1: Product baseline

- lock app name and positioning
- confirm MVP scope
- list owner decisions and unknowns

Exit criteria:
- product direction is clear enough to scaffold without rework

## Step 2: Technical scaffold

- create Flutter app shell for Android and iOS
- create backend shell
- add local Docker services
- set environment variable strategy

Exit criteria:
- app and API both boot locally

Current note:
- Flutter SDK is installed
- Android tooling is configured
- Xcode is installed
- local iOS simulator builds are working via `flutter build ios --simulator --no-codesign`

## Step 3: Mock-first mobile flows

- home/upcoming
- followed fighters on startup
- event detail
- expandable event cards
- following
- alerts
- settings
- paywall
- watch by country
- quiet free-tier ads

Exit criteria:
- mobile navigation and UI shell are stable with mock data

Current note:
- home, following, alerts, settings, event detail, and fighter profile are now wired to shared app state
- fighter and event follow state updates now propagate across screens

## Step 4: Persistence and contracts

- create database schema
- wire organizations/events
- add anonymous user profile model
- add optional account-linking model
- add fighter follows
- add favorites and alerts
- add watch availability storage
- add subscription status shape

Exit criteria:
- mobile app can read and persist core MVP state

Current note:
- current persistence uses anonymous device IDs and supports PostgreSQL-backed state when `DATABASE_URL` is configured
- per-device JSON storage remains as a safe fallback for local runs without a database
- route modularization is now in place with extracted runtime service and focused route files
- strict database-only mode is now available through `FIGHTCUE_REQUIRE_DATABASE=true`
- route-level integration tests now validate PostgreSQL-backed metadata, preferences, follows, and alerts

## Step 5: Source ingestion

- adapter contract
- first launch source
- normalization
- ingestion logs and parser failure handling

Exit criteria:
- at least one reliable source feeds the app end to end

Current note:
- the first UFC source pilot is implemented against the official UFC events page
- backend now exposes a UFC source-preview endpoint alongside mock detail endpoints
- source-health checking now compares parsed UFC coverage against the official upcoming count
- the first GLORY source is now implemented against the official GLORY event API
- the first Matchroom boxing source is now implemented against the official Matchroom events page
- Matchroom coverage checks are now in place against the official on-page card count
- the first Queensberry boxing source is now implemented against the official Queensberry events page
- the first Top Rank boxing source is now implemented against the official Top Rank site API used by the public events page
- ESPN boxing schedule is now available as a deduped secondary boxing layer for validation and broader coverage
- PBC and Golden Boy are now live boxing sources, with deduplication handling overlapping co-promoted cards
- BOXXER is now live through the official BOXXER WordPress events API
- ESPN boxing rankings and Ring boxing ratings are now available as editorial source layers for future boxing leaderboard work
- runtime resolution now keeps a short-lived cached home snapshot and coalesces in-flight source requests for faster repeated home loads
- next priority is adding the next official promoter adapters beyond Matchroom, Queensberry, Top Rank, PBC, Golden Boy, and BOXXER

## Step 6: Release features

- notifications
- ICS export
- billing verification
- free-tier ad integration
- privacy/legal surfaces
- country override for watch availability
- consent management

Exit criteria:
- core release checklist is functionally complete

## Step 7: Quality and release prep

- loading, empty, and error states
- tests for time conversion and entitlements
- tests for follow-state persistence and country-specific watch info
- store metadata and policies

Exit criteria:
- internal beta candidate is ready

Current note:
- loading, retry, and fallback states are now visible across the main mobile flows
- backend tests now cover timezone conversion, ICS generation, event merging, source-health logic, and PostgreSQL-backed user-state persistence

## Near-term execution order

### Week 1

- fix sparse-data crash paths and defensive rendering gaps
- add tests for timezone conversion, ICS generation, and runtime event merging
- extract duplicated formatting logic into shared backend utilities
- add UFC parser/source-health checks
- add loading/error/retry states in the mobile app

### Week 2

- introduce PostgreSQL-backed persistence for anonymous users and preferences
- migrate follows and alerts away from the local JSON state file
- split backend route modules out of `index.ts`
- add GLORY as the next live source
- begin boxing ingestion with Matchroom after GLORY is stable

Current note:
- PostgreSQL-backed state, route splitting, anonymous device identity, GLORY live ingestion, route-level API tests, and Matchroom live ingestion are now implemented
- the remaining follow-through is to run local development with PostgreSQL required outside sandboxed environments and then harden boxing coverage
