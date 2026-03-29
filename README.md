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
- Identity model: anonymous users by default with optional account creation
- Monetization model: free tier with quiet ads, premium tier without ads
- Watch information: country-based availability with manual country override
- Follow model: users can follow fighters as well as events
- Home priority: followed fighters and followed events must be visible immediately
- Privacy and security are first-class product requirements

### In progress

- Project foundation and documentation
- MVP definition for `FightCue`
- Technical architecture and delivery order
- Source channel plan for boxing, MMA, and kickboxing
- UX and UI direction for clean event and fight presentation
- Data, privacy, ads, and optional account model

### Next build steps

1. Confirm product and business inputs with owner
2. Shape the event, fighter, and watch-availability data models
3. Build mock-first mobile flows for home, event detail, follows, alerts, and paywall
4. Scaffold backend persistence for anonymous users and optional accounts
5. Implement the first source adapter
6. Add notifications, calendar export, subscriptions, and quiet ads
7. Add privacy, consent, and security surfaces

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

## Current constraints

- Android is ready in Flutter tooling.
- Xcode still needs to be fully installed and initialized for local iOS builds.
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
- results and fight history
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
