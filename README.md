# FightCue

FightCue is a cross-platform mobile app for Android and iOS that helps combat sports fans see upcoming fights in their own timezone, follow events, set reminders, and export events to their calendar.

## Current status

Last updated: 2026-03-29

### Confirmed decisions

- Product name: `FightCue`
- Platforms: Android and iOS
- Mobile direction: Flutter app from one shared codebase
- Backend direction: Node.js + TypeScript API
- Product promise: upcoming combat sports events in the user's local time
- Languages from day one: English, Dutch, and Spanish
- Store setup for now: store-ready only, no connected Apple or Google developer accounts yet
- Temporary working bundle/application ID base: `com.lou.fightcue`

### In progress

- Project foundation and documentation
- MVP definition for `FightCue`
- Technical architecture and delivery order
- Source channel plan for boxing, MMA, and kickboxing

### Next build steps

1. Confirm product and business inputs with owner
2. Prepare the Flutter codebase structure for Android and iOS
3. Scaffold backend API and local infra
4. Build mock-first mobile flows
5. Add persistence and API wiring
6. Implement the first source adapter
7. Add notifications, calendar export, and subscriptions

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
- event-level follow/favorites
- reminder presets
- calendar export
- premium subscription foundation

Not in the first release:

- live scoring
- exact bout-start promises
- social/community features
- heavy onboarding or mandatory accounts

## Progress log

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

## Current constraints

- `Flutter` is not installed on this machine, so native Android/iOS runner folders have not been generated yet.
- Apple and Google developer accounts are not connected yet, so bundle IDs cannot be truly reserved yet.

## Roadmap

### Phase 1: Foundation

- finalize scope
- create Flutter shell
- create backend shell
- add local Docker services
- define environments and secrets handling

### Phase 2: Mobile UX

- home/upcoming
- event detail
- following
- alerts
- settings
- paywall

### Phase 3: Backend MVP

- organizations endpoint
- events endpoint
- event detail endpoint
- favorites and alerts endpoints
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
- results and fight history
- cloud sync and optional accounts
- multilingual support
- widgets and wearable support

## What is needed from the owner

See [docs/05_open_questions.md](docs/05_open_questions.md).

## Source channels

See [docs/06_source_channels.md](docs/06_source_channels.md).
