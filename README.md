# FightCue

FightCue is a cross-platform mobile app for Android and iOS that helps combat sports fans see upcoming fights in their own timezone, follow events, set reminders, and export events to their calendar.

## Current status

Last updated: 2026-03-30

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
- Watch information: country-based availability with manual country override
- Follow model: users can follow fighters as well as events
- Home priority: followed fighters and followed events must be visible immediately
- Privacy and security are first-class product requirements

### In progress

- Live-backed mobile shell for home, following, settings, detail screens, and persisted follow actions
- First live UFC source pilot now merged into the main home feed with cached fallback behavior
- First live GLORY source is now merged into the main home feed through the official GLORY event API
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

### Immediate priorities

1. Run local development against a real PostgreSQL instance outside the current sandbox and flip `FIGHTCUE_REQUIRE_DATABASE=true`
2. Expand boxing coverage beyond Matchroom, Queensberry, Top Rank, and deduped ESPN support
3. Expand watch-provider verification beyond the current UFC, GLORY, Matchroom, Queensberry, Top Rank, and ESPN pilots
4. Add push delivery, billing, and quiet-ad integrations after persistence is fully verified
5. Add the next official promoter boxing adapters after Matchroom, Queensberry, and Top Rank stabilize

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

### 2026-03-31

- Added BOXXER as a live boxing source through the official BOXXER WordPress events API
- Improved backend home-feed performance with source-request coalescing and a short-lived runtime snapshot cache
- Added a live Queensberry source, a live Top Rank source, and live PBC and Golden Boy boxing sources with deduplication across overlapping cards
- Added ESPN boxing schedule as a broader secondary boxing validation layer without merging duplicates into the primary promoter-driven feed
- Added ESPN boxing rankings and Ring boxing ratings as source-layer inputs for future boxing leaderboards
- Added preview routes and parser tests for the new boxing leaderboard sources

## Current constraints

- Android is ready in Flutter tooling.
- Xcode and the iOS simulator runtime are installed, but real device signing and store provisioning are still not configured.
- Apple and Google developer accounts are not connected yet, so bundle IDs cannot be truly reserved yet.
- `Solmeriq Labs` is a working company/publisher name and can still be changed later after legal and trademark checks.
- Backend persistence now supports PostgreSQL through `DATABASE_URL`, and strict database-only mode can be enabled with `FIGHTCUE_REQUIRE_DATABASE=true`.
- Backend test coverage now covers time, merge, ICS, source-health logic, PostgreSQL persistence, and route-level API behavior, but still needs expansion for auth and broader source coverage.

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

See [docs/08_ux_ui_direction.md](docs/08_ux_ui_direction.md).

## Domain Data Model

See [docs/09_domain_data_model.md](docs/09_domain_data_model.md).
