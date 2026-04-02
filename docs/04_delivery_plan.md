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
- PostgreSQL is now the default runtime expectation and per-device JSON storage is an explicit fallback mode
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
- the first ONE Championship source is now implemented against the official ONE events page
- the first Matchroom boxing source is now implemented against the official Matchroom events page
- Matchroom coverage checks are now in place against the official on-page card count
- the first Queensberry boxing source is now implemented against the official Queensberry events page
- the first Top Rank boxing source is now implemented against the official Top Rank site API used by the public events page
- ESPN boxing schedule is now available as a deduped secondary boxing layer for validation and broader coverage
- PBC and Golden Boy are now live boxing sources, with deduplication handling overlapping co-promoted cards
- BOXXER is now live through the official BOXXER WordPress events API
- ESPN boxing rankings and Ring boxing ratings are now available as editorial source layers for future boxing leaderboard work
- runtime resolution now keeps a short-lived cached home snapshot and coalesces in-flight source requests for faster repeated home loads
- next priority is continuing hardening work around parsing utilities, watch-provider enrichment, and source observability

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

## Hardening sequence

This is the current recommended order for the next engineering cycle.

Current batch order:

1. security and infra cleanup
   - require an explicit signing secret outside local development/test
   - remove unused Redis from local infra
2. backend maintainability and abuse controls
   - split oversized persistence/backend files
   - add per-device-aware rate limiting
3. mobile maintainability
   - split the remaining large screens and API/model files
4. source confidence
   - add missing parser/source tests and tighten enrichment verification
5. product polish and release prep
   - continue accessibility/dark-mode polish
   - finish provider-backed push
   - deepen billing/quiet-ads and release readiness

Current execution order:

1. fix mobile environment/runtime basics such as API base-URL handling
2. add Flutter CI
3. split oversized mobile files
4. add push-notification foundations
5. expand offline UX
6. continue the accessibility pass
7. finish dark-mode polish
8. add billing and quiet-ad foundations

### Stage 1: Stability and observability basics

- add HTTP timeouts to the Flutter API client
- replace silent `catch (_) {}` blocks with lightweight error logging
- audit remaining sparse-data crash paths in mobile and backend parsing
- extract shared parsing utilities for source adapters
- add backend linting and a minimal CI pipeline

Why first:
- these changes reduce debugging time and lower the chance that small data issues become app crashes

Current note:
- HTTP timeouts, cached mobile GET fallback, diagnostics logging, global Flutter error handling, backend linting, and a first CI workflow are now in place
- shared parsing utilities are now in place and the main remaining work in this stage is broader sparse-data auditing

### Stage 2: Security and persistence hardening

- move from plain device IDs to signed anonymous session/device tokens
- narrow the runtime cache key so it only depends on state that affects event resolution
- prefer PostgreSQL as the normal local path and keep file storage as a deliberate fallback
- add structured logging around live source failures and parser drift

Why next:
- FightCue now stores meaningful user state, so privacy and traceability matter more than adding more surface area

Current note:
- signed anonymous session bootstrap and the narrower runtime cache key are now implemented
- PostgreSQL is now the normal default runtime path in config, while file storage is explicit opt-in fallback
- structured source-failure logging is now in place for loader failures, preview warnings, and persistence fallback events
- signed device tokens can now also be enforced in strict mode on stateful routes; the main remaining step is operational rollout and validation outside sandboxed sessions
- the first backend maintainability tranche is now in place: user-state persistence is split into dedicated file/postgres implementations and rate limiting now keys off FightCue device identity instead of only shared IPs

### Stage 3: Mobile reliability

- cache the last successful home, event, and leaderboard payloads locally
- add global Flutter error handling
- expand mobile test coverage around API parsing, optimistic update rollback, and key screens
- continue refining loading, error, and retry states

Why next:
- once the backend is more trustworthy, the client should become more resilient when networks are slow or unstable

Current note:
- the first maintainability tranche is now in place: `event_detail_screen.dart`, `settings_screen.dart`, `alerts_screen.dart`, `rankings_screen.dart`, `following_screen.dart`, `app_shell.dart`, the home feed widget layer, `fighter_avatar.dart`, `editorial_ui.dart`, `app_strings.dart`, and the main API/domain model libraries have been split into smaller screen/controller, part, or helper files
- `fightcue_api.dart` has also been lightened by extracting pure mapping helpers while keeping the public client surface stable for tests
- `event_detail_content.dart` is now also split into focused header, bouts, and info part files
- `settings_content.dart` is now split into dedicated monetization and push part files
- the next mobile maintainability targets are the remaining oversized rendering surfaces and any API/client helpers that can still be extracted without coupling the test fakes to internal implementation details

Current note:
- local cached fallback is now in place for GET-based API responses
- GET-based API reads now also retry with exponential backoff for transient failures, without retrying mutation calls
- global Flutter error handling is now wired in
- home, event detail, and fighter profile now surface saved-preview state explicitly when cached data is being shown
- mobile tests now cover API cache detection, cached home rendering, optimistic event-follow rollback, event-detail cache/fallback behavior, and the rankings/following/alerts screens
- mobile tests now also cover settings mutation rollback for monetization and push-state updates
- the shared editorial UI layer is now dark-mode aware on its core cards and controls instead of assuming light-only surfaces
- event detail, fighter profile, and settings now use more context-aware surfaces and semantics instead of relying on light-only defaults
- home widgets and the main navigation now also use stronger semantics and more context-aware dark-mode styling on smaller controls and cards
- mobile test coverage is moving in the right direction, but it is still far from where it needs to be for beta confidence

### Stage 4: Data quality and enrichment

- move watch-provider enrichment away from the small hardcoded runtime fallback map
- keep hardening boxing and UFC coverage checks
- make source health easier to inspect during development and staging
- prepare the future boxing leaderboard path around ESPN and Ring editorial sources

Why next:
- this improves user trust without forcing premature feature expansion

Current note:
- watch-provider enrichment now runs through a shared backend module with organization-level defaults and event-specific overrides
- watch-provider enrichment now also keeps provider provenance and prefers the strongest verified source when duplicate provider labels collide
- the current live-source batch now has explicit parser/loader tests for UFC, GLORY, Golden Boy, PBC, Queensberry, Top Rank, BOXXER, ONE, and the ESPN/Ring boxing sources
- provider selection is now stricter when a weak unknown source provider collides with a stronger event-level override
- the next step in this stage is moving more of that enrichment toward source- and database-driven verification instead of curated overrides

### Stage 5: Beta-readiness

- push notification foundation
- accessibility pass
- store-facing billing/ad infrastructure
- optional account-linking follow-through after anonymous security is improved

Why last:
- these are valuable, but they depend on the platform being stable and secure first

Current note:
- accessibility work has started with semantics on key headings and interactive controls, but a broader screen-by-screen pass is still open
- push foundations now exist for persistence, API routes, native permission/token bridges, a first mobile settings surface, a backend push-preview planning endpoint, and provider-backed push status/test-send support
- Firebase is now a first-class backend push provider option, and the mobile app now uses Firebase Messaging as its primary token path on Android/iOS while keeping the native permission bridge as a fallback when local Firebase config is missing
- real delivery still depends on production Firebase credentials plus final APNs capability/signing validation on a physical iPhone
- scheduled reminder dispatch foundations now exist as backend due-preview and dispatch routes, with in-process duplicate suppression to keep repeated worker runs from immediately re-sending the same reminder
- an optional scheduled push worker now exists in the backend runtime, with health/meta visibility and env-based interval/lookback control for local or staging reminder runs
- offline UX is now clearer in the mobile app with saved-data timestamps, stale-data warnings, visible cached notices across home/following/alerts/detail/rankings/push-settings, pull-to-refresh, background prefetch, and stale auto-refresh on key read surfaces, but it still needs broader screen coverage and deeper proactive refresh behavior
- billing/ad foundations now exist for monetization state, ad/analytics consent, quiet-ad eligibility, settings controls, a reserved home-feed ad slot, backend billing/ad provider-status routes, mobile store-readiness checks, and AdMob SDK wiring, but real store checkout and live ad credentials are still open
- the app now also has a dedicated premium/paywall screen linked from settings, so store readiness and the current plan state are visible in-product even before checkout wiring is connected
- mobile startup now also evaluates release-readiness for Firebase, Crashlytics, and AdMob so release builds log missing provider config instead of silently looking production-ready
- request-ID correlation is now in place for backend requests, and responses now echo `x-request-id` for easier traceability
- runtime snapshots and source preview loads now emit structured cache hit/miss and inflight-reuse log events
- slow runtime resolutions and slow source preview loads now emit explicit slow-path log events for easier staging/production diagnosis
- repo-side release assets are now in place as branded FightCue icon and splash source files, with native Android and iOS launcher/launch assets populated from them
- the remaining release-integration work is now mostly external: Firebase/APNs console setup, store product creation, entitlement verification, live AdMob IDs, and physical-device validation
