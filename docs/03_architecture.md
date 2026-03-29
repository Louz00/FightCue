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
  - manage local preferences
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
  - favorites and alerts persistence
  - subscription verification and entitlement state
  - ICS generation
  - source ingestion orchestration

## Data and services

- PostgreSQL for application data
- Redis reserved for queues, caching, and scheduled jobs
- push via Firebase Cloud Messaging first
- Apple push path to be added during iOS release preparation

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

## App identifiers

- final public developer/publisher name is still open
- temporary working ID base is `com.lou.fightcue`
- final reservation must happen later inside Apple Developer and Google Play Console

## Media policy

- no unlicensed fighter photos by default
- use placeholders or deterministic generated avatars until rights are confirmed
