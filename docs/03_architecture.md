# Architecture

## Repository shape

```text
FightCue/
  mobile/   Flutter app for Android and iOS
  backend/  Node.js + TypeScript API
  infra/    Local development infrastructure
  docs/     Product, technical, and planning docs
```

## Mobile

- Framework: Flutter
- Targets: Android and iOS
- First goal: mock-first flows with real navigation and state boundaries
- Localization from the start: English (`en`), Dutch (`nl`), and Spanish (`es`)
- App responsibilities:
  - render events in local timezone
  - render followed fighters and events prominently on home
  - show watch availability based on selected country
  - manage local preferences
  - manage privacy and ad consent preferences
  - handle notifications permission
  - start calendar export
  - start native purchase flows

## Backend

- Runtime: Node.js
- Language: TypeScript
- API style: JSON REST
- Suggested framework: Fastify
- Responsibilities:
  - normalized event APIs
  - anonymous profile creation and optional account linking
  - fighter follow and event follow persistence
  - favorites and alerts persistence
  - watch availability by country
  - ranking/leaderboard data where defensible
  - subscription verification and entitlement state
  - ICS generation
  - source ingestion orchestration

## Data and services

- PostgreSQL for application data
- Redis reserved for queues, caching, and scheduled jobs
- push via Firebase Cloud Messaging first
- Apple push path to be added during iOS release preparation
- ads provider to be integrated later, but free-tier ad slots must respect consent and premium entitlement

## Identity model

- every installation gets an anonymous app user profile first
- optional account creation can later attach that profile to email or another sign-in method
- premium entitlement must be server-aware
- optional account improves restore, sync, and future multi-device continuity
- paid usage does not have to depend on mandatory account creation

## Time handling rules

The product promise depends on this being correct.

- source event time must be preserved with original timezone
- canonical storage must be UTC
- UI shows local user time first
- event-local time can be shown as secondary metadata
- event status must support at least:
  - scheduled
  - estimated
  - changed
  - cancelled
  - completed

## Billing

- native store billing only
- Google Play and Apple App Store purchase handling
- server-side entitlement verification
- never trust premium state only on device

## Watch availability

- store watch availability per event and per country
- default viewing country can be inferred from device locale or region
- user must be able to override viewing country manually
- watch providers must be labeled as territory-sensitive and time-sensitive metadata

## Ads and privacy

- ads only in free tier
- ad placements must stay quiet and not block core event interactions
- respect consent requirements for ads and analytics by jurisdiction
- premium users should see no ads
- avoid sensitive targeting and unnecessary identifiers

## Ranking and leaderboard rules

- UFC and GLORY can use official ranking structures where available
- boxing requires careful source labeling because rankings are fragmented
- if a ranking is not official or directly source-backed, it must be clearly labeled as a FightCue-specific list and not implied as official

## App identifiers

- final public developer/publisher name is still open
- temporary working ID base is `com.lou.fightcue`
- final reservation must happen later inside Apple Developer and Google Play Console

## Media policy

- no unlicensed fighter photos by default
- use placeholders or deterministic generated avatars until rights are confirmed
