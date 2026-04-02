# FightCue

FightCue is a cross-platform mobile app for Android and iOS that helps combat sports fans see upcoming fights in their own timezone, follow events, set reminders, and export events to their calendar.

## Current status

Last updated: 2026-04-02

### Confirmed decisions

- Product name: `FightCue`
- Platforms: Android and iOS
- Mobile direction: Flutter app from one shared codebase
- Backend direction: Node.js + TypeScript API
- Product promise: upcoming combat sports events in the user's local time
- Languages from day one: English, Dutch, and Spanish
- Store setup for now: store-ready only, no connected Apple or Google developer accounts yet
- Temporary working developer/publisher name: `Solmeriq Labs`
- Temporary working bundle/application ID base: `com.lou.fightcue`
- Identity model: anonymous users by default with optional account creation
- Monetization model: free tier with quiet ads, premium tier without ads
- Watch information: not shown in the main UI for now; this can return later as a dedicated feature
- Follow model: users can follow fighters as well as events
- Home priority: home should show only upcoming events; saved fighters and saved events belong in a dedicated favorites area
- Saved fighter icon: heart
- Saved event icon: glove
- UI naming: `GLORY` should be presented as `Glory Kickboxing`
- Privacy and security are first-class product requirements

### In progress

- Live-backed mobile shell for home, following, settings, detail screens, and persisted follow actions
- First live UFC source pilot now merged into the main home feed with cached fallback behavior
- First live GLORY source is now merged into the main home feed through the official GLORY event API
- First live ONE Championship source is now merged into the main home feed through the official ONE events page
- UFC coverage hardening through load-more parsing and source-health checks against the official upcoming count
- UFC upcoming coverage is now secondarily validated against ESPN schedule data to catch missing cards earlier
- Backend persistence for anonymous profile state, follows, alert presets, and country-specific watch info
- Mobile settings controls for language and viewing-country preferences
- First calendar-export endpoint for event-level `.ics` downloads
- Home feed filtering for key combat-sports slices such as boxing, UFC, GLORY, and followed cards
- UFC-inspired event presentation refactor with white/red editorial cards and cartoon portrait avatars
- Editorial white/red design system now extended across rankings, following, alerts, fighter profile, and settings
- Loading, retry, and fallback states are now visible across home, rankings, alerts, event detail, and fighter profile
- Backend runtime resolution and HTTP routes are now split into focused modules instead of one monolithic file
- Anonymous device identity is now wired end to end, so each app install gets its own persisted state file instead of sharing one demo profile
- PostgreSQL-backed user-state storage and migrations now exist, with a safe per-device file fallback when `DATABASE_URL` is not configured
- Backend can now be forced into database-only mode with `FIGHTCUE_REQUIRE_DATABASE=true`, so local and future production runs do not silently fall back to JSON storage
- Route-level integration tests now verify PostgreSQL-backed API behavior for preferences, follows, alerts, and metadata
- First live Matchroom boxing source is now merged into the main home feed and exposed through a dedicated source-preview endpoint
- First live Queensberry boxing source is now merged into the main home feed and exposed through a dedicated source-preview endpoint
- First live Top Rank boxing source is now available through the official Top Rank site API and exposed through a dedicated source-preview endpoint
- ESPN boxing schedule is now used as a deduped secondary boxing layer, so it can fill gaps without duplicating promoter cards in the main home feed
- Live PBC and Golden Boy boxing sources are now wired into the backend, with official-source priority over overlapping co-promoted cards
- Live BOXXER event ingestion is now wired into the backend through the official BOXXER WordPress events API
- The backend now keeps a short-lived cached runtime snapshot per device state, so repeated home loads do not rebuild every live source on every request
- Signed anonymous session bootstrap is now available, so mobile clients can move beyond plain spoofable device IDs
- Mobile API requests now use request timeouts, cached GET fallback, and lightweight diagnostics logging
- Mobile API read requests now use bounded retry with exponential backoff for transient network and server failures, without retrying mutation calls
- Global Flutter error handling is now wired in as a first app-level safety net
- Backend linting and a first GitHub Actions CI workflow are now in place
- A first system-level dark-mode foundation is now wired into the Flutter app theme, with additional per-screen polish still needed
- PostgreSQL is now the default backend runtime expectation; file-state fallback is explicit opt-in instead of the normal path
- Backend source ingestion now uses a shared source registry plus a declarative home-feed pipeline instead of a hardcoded merge chain
- Shared parsing utilities now back the main source adapters, reducing repeated slug/sanitize/entity logic
- Structured backend source-failure logging is now in place, so parser and timeout issues emit machine-readable log events instead of ad-hoc warnings
- Watch-provider enrichment now runs through a shared backend enrichment layer with organization defaults and event-specific overrides instead of a small inline runtime map
- The mobile shell now surfaces saved-preview state explicitly when home or detail views fall back to cached data
- Mobile widget coverage now includes cached home load, optimistic follow rollback, and event-detail cache/fallback behavior
- Mobile widget coverage now also includes rankings, alerts, and following screens so the main read-only user flows have direct UI regression coverage
- Mobile widget coverage now also includes settings mutation rollback paths, so failed billing/push saves are tested for safe optimistic-state recovery
- Shared editorial UI is now dark-mode aware on core surfaces instead of hardcoding light-only card colors
- Accessibility semantics are now added on key headings, action pills, ranking toggles, and settings preference chips
- Accessibility semantics now also cover navigation, home filter chips, home event/fighter cards, and more detail/settings interaction surfaces
- Billing and quiet-ad foundations now exist across backend routes, mobile API parsing, settings consent controls, and a reserved quiet-ad slot in the home feed for free users
- Billing provider status and ad-network status are now exposed through the backend, and the mobile app now has repo-side StoreKit/Play Billing readiness checks plus AdMob SDK wiring for the reserved quiet-ad slot
- Mobile crash-reporting foundations are now wired for Firebase Crashlytics, with graceful no-op behavior when Firebase runtime config is missing
- Mobile ad initialization now uses safer dev/test defaults, including official Google test AdMob identifiers for local builds when real IDs are not configured
- Mobile settings now surface runtime safety status for ads and crash reporting, so local builds make it clear when Google test IDs or no-op crash collection are active
- Firebase Messaging is now wired into the mobile app as the primary Android/iOS push-token path, with the earlier native permission bridge kept as a safe fallback when Firebase config is missing
- The iOS app target now aligns with Firebase Messaging requirements at iOS 15, so simulator builds stay compatible with the new push stack
- Session-token signing now requires an explicit `FIGHTCUE_SESSION_SIGNING_SECRET` outside local development/test environments instead of silently falling back to a shared default secret
- Local Docker infrastructure is now trimmed to PostgreSQL only; Redis has been removed until FightCue actually uses it
- Backend rate limiting now scopes bursts per FightCue device identity instead of only by shared client IP
- User-state persistence is now split into dedicated file and PostgreSQL store implementations, reducing the size and responsibility of the old combined store file
- Mobile maintainability cleanup now includes split screen/controller files plus extracted content/part/helper files for `event_detail_screen.dart`, `settings_screen.dart`, `alerts_screen.dart`, `rankings_screen.dart`, `following_screen.dart`, `app_shell.dart`, the home feed widget layer, `fighter_avatar.dart`, `editorial_ui.dart`, `app_strings.dart`, and the main API/domain model libraries, plus a lighter `fightcue_api.dart` with pure mapping helpers extracted
- Backend operations hardening now includes tracked SQL migrations, persistence health snapshots, PostgreSQL pool visibility, and stronger push-worker degradation status in `/health` and `/v1/meta`
- Runtime/source observability now includes aggregated cache counters plus last-seen source-health snapshots for local and staging diagnostics
- Watch-provider overrides and organization defaults now live in dedicated config data instead of inside enrichment scoring logic
- The home event-card layer is now split into dedicated card, primitive, and bout-preview parts, and monetization runtime panels are now separated from settings mutation logic
- A first full mobile UI v2 pass is now implemented in the repo across `Home`, `Leaderboard`, `Favorites`, `Event detail`, `Fighter profile`, `Alerts`, and `Settings`, using the editorial white/red system with cleaner hierarchy and upcoming-events-first navigation
- The old mobile layout is now preserved under `mobile/lib/src_v1_backup/` so the repo keeps a direct code-level rollback path while v2 is being tested

### Current hardening batches

1. Security and infra cleanup
   - require an explicit signing secret outside local development/test
   - remove unused Redis from local infra and docs
2. Backend maintainability and abuse controls
   - split oversized persistence/backend files
   - add per-device-aware rate limiting
3. Mobile maintainability
   - split the remaining large screens and parsing/model files
4. Source confidence
   - add missing source-adapter tests and tighten watch-provider/source verification
   - completed for the current live event-source set; keep extending it as new sources land
5. Product polish and release prep
   - continue accessibility and dark-mode passes
   - finish provider-backed push
   - deepen billing/quiet-ads and store readiness
   - completed in-repo with a dedicated premium/paywall surface, settings entry point, backend-driven monetization state, and store-readiness messaging; external store credentials and real checkout wiring remain

### Fighter data direction

FightCue should support richer fighter identity surfaces, but in a way that keeps data quality and likeness risk under control.

Tale of the tape direction:

- add a dedicated fighter-profile data layer for commonly expected combat-sports fields:
  - height
  - reach
  - weight class
  - stance
  - age or date of birth
  - nationality
  - record
  - selected performance context such as finish rate, ranking context, or recent form
- every field should carry source-aware metadata where possible:
  - `value`
  - `sourceLabel`
  - `lastUpdatedAt`
  - optional `confidence` or `verificationState`
- missing data should stay explicitly unknown instead of being guessed
- cached fighter-profile data should refresh opportunistically:
  - on fighter-profile open
  - on follow/save actions for that fighter
  - on a slower periodic backend refresh for fighters a user follows
- the UI should show a lightweight `last updated` or `saved details` timestamp when fighter data is stale or cached

Avatar direction:

- fighter avatars should remain original, deterministic, and stylized rather than photo-derived
- avatar generation may use broad non-unique buckets such as:
  - skin-tone range
  - hair-length category
  - facial-hair yes/no or coarse type
  - head-shape category
  - accent colors and outfit cues
- avatar generation should not aim for close portrait likeness and should avoid unique identity markers such as:
  - tattoos
  - scars
  - exact hairlines
  - realistic face proportions tied to a known person
  - direct photo tracing or image-to-avatar derivation
- the product goal is `combat identity vibe`, not `recognizable real-person likeness`

Practical product rule:

- tale of the tape: yes, and it should become a first-class refreshable fighter-data surface
- stylized system avatars: yes, as the safe default
- realistic or photo-derived fighter portraits: no, unless FightCue later has explicit rights or commissioned illustration rights for that usage

### Implementation status

Fully or functionally done in the current codebase:

- crash-risk paths in Flutter and source parsing are largely defended against
- HTTP timeouts are in place in the mobile API client
- the main silent mobile catch paths now log errors and stack traces
- backend ESLint is configured
- a minimal GitHub Actions CI pipeline is configured
- the runtime cache key has been narrowed
- signed anonymous device/session token foundations are in place
- global Flutter error handling is wired in
- cached GET fallback exists for home, detail, and leaderboard-style reads
- source-health and coverage monitoring are materially expanded
- source confidence is now materially stronger, with targeted tests for UFC, GLORY, Golden Boy, PBC, Queensberry, Top Rank, BOXXER, ONE, ESPN boxing schedule/rankings, Ring ratings, and the supporting validation helpers
- backend operations visibility is now materially stronger, with tracked SQL migrations, persistence health snapshots, PostgreSQL pool counts, push-worker degradation status, and a runtime/source observability snapshot exposed in metadata and health endpoints
- more live organizations are integrated, including `ONE Championship`
- dark-mode foundations are in place
- shared parse utilities now back the main source adapters
- the runtime now uses a declarative source pipeline
- generic source config replaced the earlier many-`getCachedXxxPreview` pattern
- PostgreSQL is now the default runtime expectation, with file fallback as explicit opt-in
- watch-provider enrichment has been moved out of the small inline runtime fallback map into a dedicated backend enrichment layer
- strict signed-device-token mode now exists for stateful backend routes, beyond the earlier bootstrap/token foundation
- watch-provider enrichment now keeps source-vs-default provenance and prefers the strongest verified provider when duplicate labels collide
- watch-provider verification is now stricter when weak unknown source data conflicts with stronger curated event-level overrides
- push-notification foundations are now in place across backend persistence, API routes, mobile API parsing, a first settings status surface, and a new backend push-preview planning endpoint
- backend push delivery now supports `disabled`, `log`, and `firebase` provider modes, with safe misconfiguration reporting and a test-send route visible in settings
- backend reminder dispatch foundations now exist for due scheduled reminders, including due-preview and dispatch routes plus in-process duplicate suppression for repeated worker runs
- an in-process backend push worker now exists as an optional scheduled runner for due reminders, with status exposed in health/meta and env-controlled intervals
- offline UX now includes cached-response timestamps, stale-data warnings, visible saved-data notices across home, following, alerts, detail, rankings, and push-settings surfaces, pull-to-refresh where it matters, and background prefetch for key read surfaces after a successful home sync
- monetization now has a first real state foundation for premium/ad tier, ad consent, analytics consent, and quiet-ad eligibility
- the app now includes a dedicated premium/paywall screen, reachable from settings, so the current plan state, premium value, and store-readiness path are visible before real checkout wiring lands
- the paywall and settings surfaces now also show backend billing/ad provider readiness, while the mobile app checks local store availability and can render an AdMob-backed banner slot when unit IDs are configured
- mobile crash reporting now has a provider foundation via Firebase Crashlytics, but production DSN/project validation is still part of the external release setup
- mobile runtime safety is now explicit across environments:
  - development and simulator builds use official Google AdMob test identifiers when real ad IDs are absent
  - release builds stay dependent on real configured billing/ad/Firebase credentials instead of silently pretending to be production-ready
  - settings shows whether ads are running in safe local test mode and whether crash reporting is active or intentionally disabled for the current runtime

Partly done:

- formatting checks: ESLint is in place, but there is still no full Prettier/format-check pipeline
- structured backend logging: significantly better than before, but not yet a full observability stack
- mobile test coverage: clearly improved across cache handling, following, alerts, rankings, and optimistic rollback, but still not broad enough to call finished
- offline/cache strategy: the UX is materially better with cached timestamps, stale-data affordances, pull-to-refresh, light background prefetch, and stale auto-refresh on key read surfaces, but it still needs broader screen coverage and a more complete proactive strategy
- extra feature breadth before hardening: some has been added, but it has been kept deliberately bounded
- dark mode: the shared UI layer plus following, event detail, fighter profile, settings, app shell, and key home widgets are improved, but the app is not fully polished screen by screen yet
- accessibility: the pass now also covers navigation, home filter chips, home cards, reminder chips, event/fighter detail interactions, and settings controls, but a full screen-by-screen pass is still open
- mobile maintainability: `event_detail_screen.dart` plus `event_detail_content.dart`, `settings_screen.dart` plus `settings_content.dart`, `alerts_screen.dart`, `rankings_screen.dart`, `following_screen.dart`, `app_shell.dart`, the home feed widget layer, `fighter_avatar.dart`, `editorial_ui.dart`, `app_strings.dart`, and the main API/domain model libraries are now split into smaller files, and `fightcue_api.dart` now delegates pure mapping work to a helper layer, but several large feature/widget files still need the same treatment
- mobile maintainability moved another step forward on 2026-04-02: `home_screen.dart` now listens through a single merged listenable, `home_event_cards.dart` is split into dedicated card/primitives/bout parts, and monetization runtime panels are extracted out of the main settings monetization state file

Still open:

- run local development against a real PostgreSQL instance with `FIGHTCUE_REQUIRE_DATABASE=true` outside the current sandbox and verify that path end to end
- keep hardening the signed anonymous session-token/device-auth flow and reduce residual reliance on raw headers in non-strict mode
- continue backend maintainability cleanup after the first persistence-store split, especially around remaining large service files
- expand watch-provider verification beyond the current curated/default enrichment layer and reduce remaining organization-default assumptions
- add live-source tests for each new adapter as soon as it lands, so source confidence stays high instead of catching up later
- broaden mobile test coverage further across home, event detail, fighter detail, settings, alerts mutations, and state transitions
- continue mobile maintainability cleanup, especially around the remaining larger rendering surfaces and any API/client concerns that can be extracted without breaking test subclassing
- complete a wider offline UX strategy with broader screen coverage, clearer stale-state behavior, and more proactive refresh beyond the current key read surfaces
- continue the accessibility pass across more screens and interaction patterns
- finish dark-mode polish across the rest of the app
- connect real provider-backed push delivery on top of the new push foundation and preview-planning layer
- connect the existing premium/paywall flow to real store billing, entitlement verification, and live ad delivery

### Consolidated review snapshot

Consolidated app review date: 2026-04-02

This section combines the latest external review with a fresh local validation pass on the current codebase.

Current local validation:

- `npm run lint`: pass
- `npm test`: pass (`70/70`)
- `flutter analyze`: pass
- `flutter test`: pass (`42/42`)

Consolidated codebase snapshot:

- Backend: Node.js + TypeScript + Fastify 5
- Mobile: Flutter for Android and iOS
- Infra: PostgreSQL 16 for local development, Firebase-ready mobile push wiring, GitHub Actions CI for backend and Flutter
- Live sources in the repo today:
  - UFC
  - GLORY
  - ONE Championship
  - Matchroom
  - Queensberry
  - Top Rank
  - PBC
  - Golden Boy
  - BOXXER
  - ESPN Boxing schedule
  - ESPN Boxing rankings
  - Ring boxing ratings

Consolidated scoring snapshot:

- Architecture: `8/10`
- Data ingestion: `9/10`
- Security: `7/10`
- Mobile UX code: `7/10`
- Testing: `8/10`
- State management: `6/10`
- Production readiness: `6/10`
- Documentation: `8/10`
- Weighted overall snapshot: `7.4 / 10`

What the current review confirms:

- the backend architecture is strong and modular, with source registry, per-source TTLs, timeout fallbacks, multi-layer caching, and solid parser validation coverage
- the mobile app has a stronger reliability base than a typical MVP, including offline cache fallback, optimistic updates with rollback, push foundations, monetization foundations, and broader widget coverage
- the main remaining gaps are no longer “can FightCue work?”, but “is it hardened enough to release and maintain safely?”

Most important current findings:

1. Session-token security is improved, but still too dependent on local-environment assumptions.
   - The current fallback secret in local/dev should only exist as an explicit opt-in, never as an accidental default.
2. New anonymous users are still seeded from demo-style sample state.
   - That is useful for prototyping, but it should not remain the default behavior for release-like onboarding.
3. File-state fallback is safer than before, but still forgiving in ways that can hide data corruption or configuration mistakes.
4. Watch-provider coverage is materially better, but still partially heuristic and partly override-driven rather than fully source- or data-backed.
5. Large mobile content files remain the biggest maintainability pressure point.
   - `event_detail_content.dart`
   - `settings_content.dart`
   - `home_event_cards.dart`
6. Billing, ads, and push are now wired in-repo, but not fully production-ready until the external Apple/Google/Firebase pieces are connected.
7. Observability is improved, but still not yet a full production operations layer.
   - request-ID correlation now exists across HTTP handling and structured backend logs
   - runtime/source cache hits and misses now emit structured log events
   - slow runtime/source operations now emit structured slow-path log events
   - what is still missing is aggregation, dashboards, alerting, and broader operational metrics

### Immediate priorities

This is the strict execution order that best fits the current state of the app.

#### Batch 1: Security and request hardening

Priority: critical

- enforce `FIGHTCUE_SESSION_SIGNING_SECRET` for every non-local deployment path and make accidental weak fallback harder to ship
- add Fastify request body size limits and review upload/request ceilings
- tighten the remaining non-strict device-auth paths so stateful behavior depends on signed identity by default
- stop seeding new users from demo-style follows/events outside explicit demo mode

Expected outcome:

- safer default production posture
- less spoofing/configuration risk
- cleaner anonymous-user onboarding

Status:

- completed in the current codebase
- fresh anonymous users now start clean by default unless `FIGHTCUE_SEED_DEMO_STATE=true`
- the backend now enforces a request body size limit
- insecure local signing fallback now requires explicit opt-in in development
- signed device tokens remain enforceable and are now the documented default path

#### Batch 2: Backend maintainability and API shape

Priority: high

- split `me-routes.ts` into focused route modules such as profile/preferences, follows/alerts, push, and monetization
- continue reducing large backend files that still combine orchestration and domain policy
- harden file-fallback behavior so corruption/config problems are visible instead of silently reseeded
- review remaining large source adapters for more shared parsing structure where it lowers maintenance cost safely

Expected outcome:

- easier backend navigation
- lower regression risk when extending user-state and push/monetization flows

Status:

- completed in the current codebase
- `me-routes.ts` is now split into focused modules for profile, follows, alerts, and push
- file-state fallback is now stricter for corrupted JSON instead of silently reseeding over unreadable state
- the backend route surface is easier to extend without reopening one large mixed-responsibility file

#### Batch 3: Mobile maintainability

Priority: high

- split the largest screen/content files into smaller focused parts and helper surfaces
- continue the same cleanup for `home_event_cards.dart` and any remaining oversized content layers
- keep API/data/model boundaries clean so `FightCueApi` stays transport-focused rather than becoming a second domain layer

Expected outcome:

- smaller review surface for UI changes
- faster iteration on design and behavior without destabilizing entire screens

Status:

- completed for the current highest-pressure files
- `event_detail_content.dart` is now split into dedicated header, bouts, and info part files
- `settings_content.dart` is now split into dedicated monetization and push part files
- `home_event_cards.dart` is now split into dedicated card, primitive, and bout-preview part files
- monetization runtime/status panels are now extracted out of the main settings monetization state file
- earlier cleanup of home, alerts, rankings, following, shell, editorial UI, app strings, and API/domain model files remains in place

#### Batch 4: Reliability and mobile quality

Priority: high

- add retry with exponential backoff to the mobile API client for suitable read flows
- expand mobile widget and state tests around error cases, retries, mutation flows, and stale-cache transitions
- continue the offline UX pass with clearer stale-state rules and broader screen coverage
- finish the remaining accessibility and dark-mode passes as part of routine screen hardening

Expected outcome:

- better resilience on weak networks
- stronger confidence in core user flows
- more predictable offline and cached behavior

Status:

- completed in the current codebase
- safe read-only retry with exponential backoff is now built into `FightCueApi`
- settings mutation rollback paths now have direct widget coverage
- cached/stale-state behavior is already covered across home, alerts, detail, rankings, and settings surfaces from the earlier offline UX tranche
- release-readiness tests now also cover non-release bypass behavior, and settings has direct stale cached billing-state coverage

#### Batch 5: Observability and source confidence

Priority: medium

- add request-ID correlation across backend request handling and downstream logs
- add cache hit/miss logging or metrics for source previews and runtime snapshots
- add slow-operation logging for expensive source loads and heavy user-state operations
- keep adding source tests as soon as new adapters land, rather than catching up later
- continue reducing heuristic watch-provider assumptions over time

Expected outcome:

- easier production debugging
- earlier detection of parser drift and source regressions
- better confidence in country-specific watch data

Status:

- completed in the current codebase
- backend requests now generate or reuse `x-request-id` values and echo them back on responses
- structured backend logs now include request correlation IDs when request context exists
- runtime snapshots and source previews now emit structured cache hit, cache miss, and inflight-reuse log events
- slow runtime resolutions and slow source preview loads now emit explicit structured slow-operation log events
- `/health` and `/v1/meta` now expose runtime/source observability snapshots with aggregated cache counters and last-seen source-health items
- push-worker status now reports warning/degraded health, consecutive failure counts, last failure timing, and run duration
- migration tracking now records applied SQL files in `schema_migrations`
- parser/source coverage remains backed by direct tests for the live source set already in the repo

#### Batch 6: External release integrations

Priority: medium

- connect real Firebase/APNs credentials and validate on physical devices
- connect real StoreKit / Play Billing products and backend entitlement verification
- connect real AdMob app IDs and banner units, then validate consent-aware quiet ad behavior
- finish app icon, splash, and final release metadata once the runtime integrations are stable

Expected outcome:

- the app moves from “repo-ready” to “store-ready”
- monetization and push flows become real rather than preview/foundation-only

Status:

- repo-side tranche completed in the current codebase
- FightCue now includes branded app-icon and splash source assets under `mobile/assets/branding/`
- Android launcher icons and launch splash assets are now wired to FightCue-branded native resources in the repo
- iOS app display naming now uses `FightCue`, and the iOS icon/launch image asset set is now populated from the branded source assets
- billing, ads, and push already expose provider-readiness state in-product and through backend routes
- the remaining work is now external-console work: real Firebase/APNs credentials, real store products, real AdMob IDs, entitlement validation, and physical-device verification

### Mobile push setup

To exercise real Firebase-backed mobile push delivery locally, add the platform config files that stay out of git:

- `mobile/android/app/google-services.json`
- `mobile/ios/Runner/GoogleService-Info.plist`

The app now boots Firebase Messaging early and falls back to the native permission bridge if those files are missing, so local development remains usable without credentials.

Mobile runtime release safety now behaves like this:

- development and simulator builds stay permissive and log-friendly
- release builds emit startup readiness notices when Firebase, Crashlytics, or AdMob production config is still incomplete
- release builds should not ship while Google test ad identifiers are still active

For the new repo-side billing/ad wiring, these are the next local configuration inputs:

- backend env:
  - `FIGHTCUE_BILLING_PROVIDER`
  - `FIGHTCUE_BILLING_PRODUCT_IDS`
  - `FIGHTCUE_AD_PROVIDER`
  - `FIGHTCUE_ADMOB_APP_ID_ANDROID`
  - `FIGHTCUE_ADMOB_APP_ID_IOS`
  - `FIGHTCUE_ADMOB_BANNER_UNIT_ID_ANDROID`
  - `FIGHTCUE_ADMOB_BANNER_UNIT_ID_IOS`
- mobile dart-defines for runtime ad delivery:
  - `--dart-define=FIGHTCUE_ANDROID_BANNER_AD_UNIT_ID=...`
  - `--dart-define=FIGHTCUE_IOS_BANNER_AD_UNIT_ID=...`

The store runtime check now uses the Flutter `in_app_purchase` stack, and the reserved quiet-ad slot now uses `google_mobile_ads` when a banner unit ID is available.

Repo-side release assets are now prepared as well:

- source branding assets live in `mobile/assets/branding/app_icon.png` and `mobile/assets/branding/splash_logo.png`
- Android native launcher icons now use the FightCue-branded icon files
- Android launch backgrounds now render the branded splash logo on the editorial off-white background
- iOS app icons and launch images are now populated from the same branded source assets

For Apple delivery, there is still one final console/signing step outside this repo:

- enable the Push Notifications capability for the iOS app in Xcode/Apple Developer
- connect the APNs key or certificate to the Firebase project
- then validate on a signed physical iPhone, because the iOS simulator does not receive real remote pushes

Minimum mobile release checklist:

- Firebase project connected for both Android and iOS
- `google-services.json` present for Android release builds
- `GoogleService-Info.plist` present for iOS release builds
- Crashlytics confirmed in a signed release/runtime build
- production AdMob app IDs configured for Android and iOS
- production AdMob banner unit IDs configured if quiet ads are enabled
- no Google test ad identifiers left active in release builds

Physical-device smoke checklist:

- iPhone and Android device both install and launch the current debug/release-candidate build
- splash screen, app icon, and app name render correctly on both platforms
- home feed loads without falling back to a permanent error or empty state
- core filters such as `UFC`, `Boxing`, and `GLORY` switch cleanly and update visible cards
- event detail opens from home and shows bouts, timing, and watch info without layout breakage
- fighter profile opens from event detail and renders avatar, metadata, and follow state correctly
- follow and unfollow actions persist after app restart for both fighters and events
- settings changes for language and viewing country persist after app restart
- paywall opens from settings and shows the expected current-plan and provider-readiness state
- quiet-ad slot behavior is correct for the current runtime:
  - local/testing builds may use Google test ad identifiers
  - release-candidate builds must not use Google test ad identifiers
- push permission flow behaves correctly:
  - prompt appears on first request where expected
  - granted/denied state is reflected in settings
  - token registration state updates after permission and sync
- backend-connected refresh still works after app has been backgrounded and reopened
- dark mode and light mode both remain readable on key screens: home, event detail, fighter profile, settings, alerts
- no startup crash, native crash, or repeated startup warning loop appears on either physical device

Recommended smoke-test order:

1. launch the app cold on both devices
2. verify home, filters, event detail, and fighter profile
3. verify follow persistence and settings persistence across restart
4. verify paywall, billing/ad readiness, and quiet-ad behavior
5. verify push permission, token sync, and settings status
6. repeat one final cold launch and quick navigation pass

### Two-week execution plan

#### Week 1: Stability and trustworthiness

Goal:
- make live UFC-backed behavior reliable enough that the app can stop feeling like a prototype

Status:
- completed in the current codebase, including defensive event rendering, shared backend time utilities, backend tests, source-health checks, and visible retry/fallback UX

Planned work:
- add defensive handling for events with empty bout lists or missing watch-provider data
- extract duplicated timezone-formatting logic into a shared backend utility
- add backend unit tests for timezone conversion, ICS export, and home-feed merge logic
- add source-health checks for UFC counts, missing headline cards, and parser-empty fallbacks
- improve mobile loading and error states on home, event detail, fighter detail, rankings, and alerts
- clean repository hygiene issues and confirm generated/local browser data stays out of git

Expected output by end of week 1:
- no known crash path from sparse live event data
- test coverage for the most critical backend logic
- visible loading/error/retry UX instead of silent failure
- UFC ingestion is monitored instead of trusted blindly

#### Week 2: Persistence and multi-user readiness

Goal:
- move FightCue from single-user local prototype behavior to a real multi-user-ready foundation

Status:
- substantially implemented in the current codebase
- route modularization, anonymous device identity, PostgreSQL-backed storage, and GLORY live ingestion are now in place
- the main remaining gap is operational verification of PostgreSQL as the default runtime path in a local/dev environment
- route-level PostgreSQL API tests and the first live Matchroom boxing source are now in place

Planned work:
- design and add PostgreSQL schema for anonymous users, preferences, follows, alerts, and watch-country state
- migrate backend persistence away from `.data/user-state.json`
- introduce anonymous device identity as the default user model
- split backend routes out of `backend/src/index.ts` into focused modules
- add a first release-ready persistence flow for follows, alerts, language, and viewing country
- add the next live source adapter: `GLORY`, then start boxing with `Matchroom`

Expected output by end of week 2:
- backend state supports multi-user PostgreSQL persistence and only falls back to file storage when no database is configured
- API structure is easier to extend
- anonymous users have real persisted state
- live coverage expands beyond UFC through GLORY and Matchroom, with the next boxing adapters ready to follow

### After the two-week plan

Once the foundation above is stable, the next layer is:

1. Push notifications and reminder delivery
2. Premium/billing integration
3. Quiet ad integration for free users
4. Optional account linking via email magic link
5. Store/legal/release preparation

## Project structure

```text
FightCue/
  README.md
  docs/
  mobile/
  backend/
  infra/
  archive/
```

## MVP focus

`FightCue` v1 should stay narrow and reliable:

- upcoming combat sports events
- strong timezone conversion
- event detail and fight card
- expandable event cards with visible main event and full card on demand
- event-level follow/favorites
- fighter follows
- reminder presets
- country-based watch information
- calendar export
- anonymous device profile with optional account creation
- free tier with quiet ads and premium without ads
- premium subscription foundation

Not in the first release:

- live scoring
- exact bout-start promises
- social/community features
- heavy onboarding or mandatory accounts
- noisy ad formats such as disruptive interstitials

## Progress log

### 2026-03-31

- Added the first live Queensberry boxing source against the official Queensberry events page and merged it into the main home feed
- Added a Queensberry source-preview endpoint with official hero-card coverage checks and official-copy watch-provider enrichment
- Validated live Queensberry coverage at 4 upcoming events with healthy source coverage against the official page
- Added test-runner discovery that now includes nested source tests by default, so new boxing-source tests are not silently skipped
- Added the first live Top Rank boxing source via the official Top Rank site API behind the public events page
- Added boxing deduplication so Matchroom, Queensberry, Top Rank, and ESPN can coexist in the feed without obvious duplicate cards
- Added live PBC and Golden Boy event ingestion, plus route-level coverage that verifies official-source priority when the same card appears across promoters and ESPN
- Added the first live BOXXER boxing source through the official BOXXER WordPress events API and exposed it through a dedicated source-preview endpoint
- Added a short-lived runtime snapshot cache plus source-request coalescing so repeated identical `/v1/home` calls stay fast while live sources are warm
- Added ESPN boxing rankings and Ring boxing ratings as source-layer inputs for future boxing leaderboards
- Added the first live ONE Championship source against the official ONE events page and merged it into the backend runtime
- Added signed anonymous session bootstrap and HMAC-based device tokens as the first security-hardening step for anonymous users
- Added mobile API request timeouts, cached-response fallback, lightweight diagnostics logging, and global Flutter error handling
- Added backend ESLint plus a first GitHub Actions CI workflow for lint, build, and test
- Added a first system-driven dark mode theme foundation in Flutter so the app can start moving beyond light-only rendering
- Switched the backend to a PostgreSQL-first default runtime, with file fallback available only via explicit opt-in
- Replaced the hardcoded home-feed source chain with a shared source registry and declarative merge order
- Added shared backend parse utilities and started consolidating source-adapter text/slug helpers onto them
- Added structured backend logging for source failures, preview warnings, and persistence fallback events
- Moved watch-provider enrichment into a dedicated backend module with organization defaults plus event-specific overrides
- Made cached mobile fallback explicit in the UI for home, event detail, and fighter profile surfaces
- Added mobile widget tests for cached home loads, optimistic event-follow rollback, and event-detail cache/fallback behavior
- Started the next UX tranche by making shared editorial surfaces dark-mode aware and adding semantics to core interactive controls
- Added native iOS/Android push permission bridges plus a backend push-preview endpoint that shows which reminders FightCue would schedule or signal for the current device state
- Added iOS remote-notification background mode configuration so simulator/device builds are closer to real push-ready app settings
- Added backend push-provider status and test-send support, including Firebase-ready configuration paths and visible push-provider readiness in settings
- Added backend due-reminder planning and dispatch support so FightCue can preview and execute scheduled reminder batches instead of only sending isolated test pushes
- Added an optional in-process push worker that periodically scans push-ready devices and dispatches due reminders on a configurable interval

### 2026-03-30

- Added a PostgreSQL-backed user-state store plus SQL migrations, while keeping a safe per-device JSON fallback when no database is configured
- Added PostgreSQL store tests and a strict `FIGHTCUE_REQUIRE_DATABASE` mode so persistence can be enforced instead of silently falling back
- Added route-level integration tests for PostgreSQL-backed API behavior covering metadata, preferences, follows, and alerts
- Added local PostgreSQL helper scripts for project-scoped startup and shutdown outside sandboxed sessions
- Added a secondary UFC validation layer against ESPN schedule data so missing upcoming cards can be detected beyond the official UFC page count
- Added the first live GLORY source adapter against the official GLORY event API and merged it into the main home feed
- Added a GLORY source-preview endpoint so live source coverage can be inspected directly
- Added the first live Matchroom boxing source against the official Matchroom schedule and merged it into the main home feed
- Added a Matchroom source-preview endpoint and validated live ingestion with 8 upcoming boxing events
- Added Matchroom coverage checks against the official on-page card count so parser drift is surfaced earlier
- Added an ESPN boxing schedule preview endpoint as a second boxing research/validation source without polluting the main home feed with duplicate cards
- Extended the UFC parser to follow official load-more pages and validated live coverage against the official UFC events page
- Added UFC source-health checks that compare parsed events against the official upcoming count
- Extracted shared backend time-formatting and event-sorting utilities to remove duplicated logic
- Added backend tests for timezone handling, ICS generation, event merging, and source-health behavior
- Added defensive rendering for sparse live data so empty fight cards no longer crash event surfaces
- Added visible loading, retry, and fallback cards across home, rankings, alerts, event detail, and fighter profile
- Added safe event-summary helpers and mobile tests for empty cards and missing watch providers
- Split the backend into route modules plus a dedicated runtime service to start the week-2 maintainability work
- Added anonymous device IDs on the mobile client and per-device backend state files instead of one shared demo-user file
- Refined the visual system toward a sharper white/red editorial look inspired by UFC event cards
- Rebuilt event detail with a fight-card-first layout, main/preliminary card tabs, and mirrored fighter rows
- Reworked home event cards to match the new event-detail language more closely
- Switched event and fight surfaces to original cartoon portrait avatars instead of real fighter photos
- Extended the same editorial event language to the rest of the app so secondary screens now match the main fight experience

### 2026-03-29

- Created standalone `FightCue` repository
- Chose `FightCue` as product name
- Reviewed the reference package and extracted reusable product direction
- Defined initial cross-platform direction for Android and iOS
- Added project docs, roadmap, and open questions
- Locked in multilingual launch direction: English, Dutch, and Spanish
- Set project to store-ready mode without live store-account wiring
- Added source-channel guidance for boxing, MMA, and GLORY kickboxing
- Added initial mobile and backend scaffolds
- Installed Flutter, Android Studio, Android SDK, CocoaPods, and GitHub CLI
- Generated real Flutter Android and iOS project runners
- Published the repository to GitHub
- Locked in anonymous-by-default users with optional accounts
- Added product requirements for quiet ads, fighter follows, watch by country, and privacy-first data handling
- Chose email magic link as the first optional account method
- Chose Google AdMob as the default quiet-ad direction for the free tier
- Deferred boxing leaderboards until a defensible official source framing is selected
- Set `Solmeriq Labs` as the temporary company and store-publisher name pending legal clearance
- Built stateful mobile flows for followed fighters, followed events, alerts, and settings
- Added dedicated event-detail and fighter-profile screens with shared follow state
- Added the first live UFC source adapter against the official UFC events page
- Added backend endpoints for event detail, fighter detail, and UFC source preview
- Added a dedicated rankings section with weight-class leaderboards for men and women
- Added a stylized fighter-avatar system as a safe interim alternative to real fighter photos
- Added a persisted backend state layer for anonymous profile data, follows, and viewing-country preferences
- Connected the mobile shell to a real backend home payload instead of relying only on local mock merges
- Added language and viewing-country controls in Settings with backend-backed persistence
- Validated real API roundtrips for home loading, preference updates, and fighter follow persistence
- Connected event-detail and fighter-profile screens to dedicated backend detail endpoints with graceful fallback
- Added persisted alert presets for followed fighters and followed events
- Added a first `.ics` calendar export endpoint per event and surfaced it in the event detail screen
- Fixed the main event feed so live UFC source data is merged into `/v1/home` instead of living only behind the source-preview endpoint
- Added clean home-feed filters for boxing, UFC, GLORY, and followed events
- Validated the new mobile flows with `flutter analyze` and `flutter test`
- Validated the backend UFC parser with a successful live source check and TypeScript build
- Validated iOS simulator builds with `flutter build ios --simulator --no-codesign`

## Current constraints

- Android is ready in Flutter tooling.
- Xcode and the iOS simulator runtime are installed, but real device signing and store provisioning are still not configured.
- Apple and Google developer accounts are not connected yet, so bundle IDs cannot be truly reserved yet.
- `Solmeriq Labs` is a working company/publisher name and can still be changed later after legal and trademark checks.
- Backend persistence now supports PostgreSQL through `DATABASE_URL`, and strict database-only mode can be enabled with `FIGHTCUE_REQUIRE_DATABASE=true`.
- Backend test coverage now covers time, merge, ICS, source-health logic, PostgreSQL persistence, and route-level API behavior, but still needs expansion for auth and broader source coverage.
- Dark mode is only partially implemented today: the app theme supports it, but several screens still need dedicated dark-surface polish.

## Roadmap

### Phase 1: Foundation

- finalize scope
- create Flutter shell
- create backend shell
- add local Docker services
- define environments and secrets handling

### Phase 2: Mobile UX

- home/upcoming
- followed fighters section on startup
- event detail
- expandable event cards
- following
- alerts
- settings
- paywall
- country-based watch labels
- quiet ad placements in free screens only

### Phase 3: Backend MVP

- organizations endpoint
- events endpoint
- event detail endpoint
- fighter follows endpoint
- favorites and alerts endpoints
- anonymous profile and optional account-linking flow
- watch availability by country
- subscription status endpoint
- ICS export

### Phase 4: Ingestion

- source adapter interface
- normalization pipeline
- first launch source
- ingestion logs and failure handling

### Phase 5: Release integrations

- push notifications
- billing and entitlement verification
- free-tier ad integration
- privacy/legal surfaces
- analytics consent

## Hardening plan

This is the current execution order for turning FightCue from a strong prototype into a stable beta-ready product.

### Track 1: Stability and debugging basics

Priority: highest
Estimated effort: small to medium

- add HTTP timeouts to the mobile API client
- stop silently swallowing mobile exceptions; log errors and stack traces
- audit remaining sparse-data crash paths and parser edge cases
- extract shared parsing helpers such as `sanitizeText`, `decodeHtmlEntities`, and `toSlug`
- add a minimal CI pipeline that runs backend build and tests on every push
- add ESLint and formatting checks for the backend

Target outcome:
- the app fails more gracefully
- debugging gets faster
- source adapters become easier to maintain safely

### Track 2: Security and state hardening

Priority: highest
Estimated effort: medium

- replace plain spoofable device identifiers with a signed anonymous device/session token flow
- tighten how user state is resolved and cached so event resolution depends only on the fields that matter
- make PostgreSQL the normal development path instead of relying on file fallback by default
- add structured backend logging for source failures, parser drift, and request tracing

Target outcome:
- better privacy protection for user follows and alerts
- less accidental cache churn
- better visibility when a live source starts failing

### Track 3: Mobile reliability

Priority: high
Estimated effort: medium to large

- add local caching for the last successful home, event, and rankings payloads
- add global Flutter error handling and a more graceful failure surface
- expand mobile test coverage around API parsing, optimistic follow rollback, and the main screens
- keep improving loading, empty, and retry states where source data is incomplete

Target outcome:
- the app remains useful when the backend is slow or temporarily unavailable
- regressions are caught earlier

### Track 4: Data quality and enrichment

Priority: medium
Estimated effort: medium

- move watch-provider enrichment out of the small hardcoded fallback map and into source-level or database-backed enrichment
- continue source coverage hardening for boxing and UFC
- add source health summaries that are easy to inspect during development
- prepare boxing leaderboards for future in-app release using the new ESPN and Ring source layers

Target outcome:
- better trust in event accuracy
- less manual source-specific patching over time

### Track 5: Release readiness

Priority: medium
Estimated effort: medium to large

- lay the foundation for push notifications
- add accessibility improvements such as semantics and contrast review
- connect store-facing billing and ad infrastructure
- revisit optional account linking once anonymous security is hardened

Target outcome:
- FightCue becomes ready for an internal beta path instead of only local development

### Explicit non-priorities right now

- dark mode is now a supported foundation, but it is still not polished enough across every screen to count as launch-complete
- more feature breadth is still less important than reliability, security, and data confidence
- new organizations should still be added only if they do not destabilize the hardening work above

## Future features backlog

These are intentionally not part of the first cut, but should remain visible for later planning:

- bout-level following and alerts
- premium smart alerts where confidence is high
- more organizations beyond the launch set
- richer fighter profiles
- deterministic fighter avatars
- personalized filtering by sport, organization, and favorites
- organization-based leaderboards/rankings
- surfacing source-labeled boxing leaderboards in-app once the editorial vs official framing is finalized
- licensed fighter portraits or commissioned original illustrations
- results and fight history
- UFC Stats integration for historical results and statistical enrichment
- cloud sync and optional accounts
- multilingual support
- widgets and wearable support

## What is needed from the owner

See [docs/05_open_questions.md](docs/05_open_questions.md).

## Source channels

See [docs/06_source_channels.md](docs/06_source_channels.md).

## Privacy and Data

See [docs/07_user_data_privacy_and_ads.md](docs/07_user_data_privacy_and_ads.md).

## UX and UI

### Current page map in the mobile app

Primary navigation:

- `Home`
- `Leaderboard`
- `Favorites`
- `Alerts`
- `Settings`

Supporting screens:

- `Event detail`
- `Fighter profile`
- `Premium / Paywall`

Current repo surfaces already cover these flows under the existing shell:

- home
- leaderboard
- favorites
- alerts
- settings
- event detail
- fighter profile
- paywall

Current implementation note:

- the route/file structure still contains some legacy names such as `following_*` and `rankings_*`, but the user-facing mobile UI now presents these as `Favorites` and `Leaderboard`
- the older pre-v2 mobile layout is preserved in `mobile/lib/src_v1_backup/`

### Current UI v2 status

The current mobile app is already partway through the intended v2 design direction:

- `Home` now focuses on upcoming events only
- `Home` supports multi-select filters including `Boxing`, `UFC`, `MMA`, and `Glory Kickboxing`
- `Favorites` now separates saved fighters and saved events
- `Leaderboard` now uses a more editorial ranking layout with stronger hierarchy
- `Event detail` now prioritizes event context, main-event emphasis, fight-card structure, and calendar export
- `Fighter profile` now foregrounds tale of the tape and next-fight context
- `Alerts` and `Settings` now use the same editorial card system and clearer status communication

This is intentionally a product-safe adaptation of the newer design language:

- stronger typography and card hierarchy: yes
- cleaner editorial sports feel: yes
- betting, odds, replay, or watch-provider clutter: no
- realistic fighter photography: no
- stylized system avatars: yes

### Required screen direction

- `Home`: show only upcoming events. Do not place followed fighters or saved events on the homepage. The homepage should feel like a clean upcoming-events feed.
- `Home filters`: support multi-select chips so users can combine combat sports or organizations such as `Boxing + UFC` or `Boxing + Glory Kickboxing`. Replace `Glory` with `Glory Kickboxing` in the UI.
- `Favorites`: split clearly into `Fighters` and `Events`.
- `Favorites -> Fighters`: show fighters the user has liked with a heart icon. Tapping a fighter opens the fighter profile with avatar, tale of the tape, and the next scheduled fight if one exists.
- `Favorites -> Events`: show saved events with a glove icon instead of a heart. Saved events must be easy to reopen and export to the calendar with the correct local date and time.
- `Leaderboard`: show more than five fighters. The minimum target is ten entries per ranking list, and the UI should be able to handle longer lists cleanly when the source provides them.
- `Event detail`: prioritize local date and time, card structure, key bouts, save-state with glove icon, and calendar export. Do not show watch-provider information in this design pass.
- `Fighter profile`: include stylized avatar, name, record, nationality, organization hint, full tale of the tape, and a clear `next fight` block when the fighter is booked.
- `Alerts`: keep this page lightweight and practical. It should manage reminder presets for followed fighters and saved events without becoming a noisy dashboard.
- `Settings`: keep only what is truly needed. Focus on language, notifications, timezone, and premium. Do not include an ad on/off setting. Ads disappear only when the user has premium.
- `Paywall`: explain the difference between free and premium in a calm, premium-feeling way. The main user-facing premium promise is `no ads`, plus a better reminder experience.

### Design constraints

- the UI should feel professional, premium, clean, and calm
- use stylized original avatars instead of photos
- no watch-provider UI for now; that may return later
- favor strong time hierarchy, generous spacing, and low-noise cards
- use clear icon semantics:
  - fighter saved state: heart
  - event saved state: glove
- avoid cluttered dashboards, dense tables, or overly gamified layouts

### Rollback safety

If the v2 mobile UI direction needs to be rolled back or compared against the previous layout:

- Git history keeps the pre-v2 and transition commits
- the current repo also keeps a code-level backup under `mobile/lib/src_v1_backup/`
- `mobile/analysis_options.yaml` excludes that backup path so it does not affect normal analysis or builds

### AI design prompt

```text
Design a professional, clean, premium mobile app UI and UX for FightCue, a combat sports app for iOS and Android.

FightCue helps users track upcoming combat sports events in their local timezone. The product covers Boxing, UFC, MMA, Kickboxing, and specifically Glory Kickboxing.

Important product rules:
- Home must show only upcoming events.
- Do not place followed fighters or saved events on the home screen.
- Home needs multi-select filter chips, so users can combine filters like Boxing + UFC or Boxing + Glory Kickboxing.
- Use the label "Glory Kickboxing" instead of "Glory".
- Fighters can be saved with a heart icon.
- Events can be saved with a glove icon.
- Saved events must support calendar export with the correct local date and time.
- Fighter profile must show a tale of the tape and whether the fighter has an upcoming fight, including which event it is.
- Leaderboards must support at least 10 fighters per list, and scale cleanly when there are more.
- Settings must stay simple and practical.
- There must be no manual ad on/off toggle. Ads are removed only when the user has premium.
- Do not show where users can watch the fight in this design pass.
- Use stylized, original avatars instead of real fighter photos.

Required page map:
1. Home
   - Upcoming events only
   - Multi-select filter chips
   - Clean event cards with event name, organization, local date, local time, city/venue, key bout if available, and save-event glove action

2. Leaderboard
   - Ranking lists with at least 10 entries
   - Clear hierarchy for rank, fighter, record, and source
   - Must work for longer lists without feeling crowded

3. Favorites
   - Split into two tabs or segments: Fighters and Events
   - Fighters view shows liked fighters with heart icon
   - Events view shows saved events with glove icon

4. Fighter Profile
   - Avatar
   - Name, nickname if available, record, nationality, organization
   - Tale of the tape section
   - Next fight section
   - Related event cards if booked

5. Event Detail
   - Strong event header
   - Local date/time first
   - Main card and prelim structure
   - Save-event glove action
   - Calendar export action
   - Fighter rows with avatars and heart-save affordance where relevant

6. Alerts
   - Lightweight reminder management for saved fighters and saved events
   - Should feel simple, not like an enterprise settings panel

7. Settings
   - Language
   - Notifications
   - Timezone
   - Premium
   - No ad toggle

8. Premium / Paywall
   - Free vs Premium comparison
   - Premium removes ads
   - Clean and trustworthy presentation

Visual direction:
- Editorial sports product feel
- White or off-white base with strong red accents
- Premium, minimal, modern, clean
- Strong typography and time/date hierarchy
- Card-based layout with generous breathing room
- No clutter, no noisy dashboards, no gimmicky gamification
- Must feel polished on both iPhone and Android

Output requested:
- mobile-first UX structure
- navigation map
- wireframe-level screen descriptions
- polished visual direction
- key components and interaction patterns
- clean, production-ready UI concept
```

For the longer UX direction reference, see [docs/08_ux_ui_direction.md](docs/08_ux_ui_direction.md).

## Domain Data Model

See [docs/09_domain_data_model.md](docs/09_domain_data_model.md).
