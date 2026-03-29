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
- Temporary working developer/publisher name: `Solmeriq Labs`
- Temporary working bundle/application ID base: `com.lou.fightcue`
- Identity model: anonymous users by default with optional account creation
- Monetization model: free tier with quiet ads, premium tier without ads
- Watch information: country-based availability with manual country override
- Follow model: users can follow fighters as well as events
- Home priority: followed fighters and followed events must be visible immediately
- Privacy and security are first-class product requirements

### In progress

- Mock-first mobile flows for home, following, alerts, settings, event detail, and fighter profile
- First live UFC source pilot against the official UFC events page
- Backend contract shaping for event detail, fighter detail, and source preview endpoints
- iOS simulator runtime setup in Xcode for local Apple build testing

### Next build steps

1. Connect the mobile app to backend detail and source-preview endpoints
2. Add persistence for anonymous users, follows, alerts, and optional accounts
3. Add calendar export, notifications, and subscription state
4. Add quiet ad placement wiring for the free tier
5. Expand source coverage after UFC: Matchroom, GLORY, then more boxing organizations
6. Finish iOS simulator/runtime setup and begin device-level build testing

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
- Set `Solmeriq Labs` as the temporary company and store-publisher name pending legal clearance
- Built stateful mobile flows for followed fighters, followed events, alerts, and settings
- Added dedicated event-detail and fighter-profile screens with shared follow state
- Added the first live UFC source adapter against the official UFC events page
- Added backend endpoints for event detail, fighter detail, and UFC source preview
- Added a dedicated rankings section with weight-class leaderboards for men and women
- Added a stylized fighter-avatar system as a safe interim alternative to real fighter photos
- Validated the new mobile flows with `flutter analyze` and `flutter test`
- Validated the backend UFC parser with a successful live source check and TypeScript build

## Current constraints

- Android is ready in Flutter tooling.
- Xcode is installed, but the iOS simulator runtime still needs to be installed from Xcode Settings > Components for local simulator builds.
- Apple and Google developer accounts are not connected yet, so bundle IDs cannot be truly reserved yet.
- `Solmeriq Labs` is a working company/publisher name and can still be changed later after legal and trademark checks.

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
- licensed fighter portraits or commissioned original illustrations
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
