# Domain Data Model

## Goal

FightCue needs a domain model that can support anonymous usage first, optional accounts later, quiet ads in free tier, and event/fighter tracking across multiple sports.

## Core entities

### User profile

- `user_profile`
- created for every installation
- anonymous by default
- stores:
  - language
  - timezone
  - selected viewing country
  - analytics/ad consent
  - premium state
  - ad tier

### User account

- `user_account`
- optional
- first auth method: `email_magic_link`
- links back to the existing anonymous profile rather than replacing it

### Organization

- `organization`
- examples:
  - Matchroom
  - UFC
  - GLORY

### Fighter

- `fighter`
- stores normalized identity and metadata
- can be followed directly by the user

### Event

- `event`
- stores organization, venue, local timezone, UTC start time, card status, and watch availability references

### Bout

- `bout`
- belongs to an event
- references fighter A and fighter B
- stores bout order and summary metadata

### Watch availability

- `watch_availability`
- linked to event
- scoped by `country_code`
- stores provider label, provider type, confidence, and last verification timestamp

### Follow

- `follow`
- supports:
  - `fighter`
  - `event`
- designed to drive home visibility and alerts

### Alert

- `alert`
- can target either event or fighter follow context
- stores alert type and scheduled send time

### Entitlement

- `entitlement`
- tracks premium state server-side
- premium removes ads and unlocks higher follow/alert limits

### Leaderboard

- `leaderboard`
- optional later feature
- must store source type and source label
- boxing leaderboards should be official-source-backed if added

## User model decisions

- anonymous profile first
- optional account via email magic link first
- premium purchase does not require account creation
- account linking improves restore and cross-device sync

## Ads model decisions

- ad tier is derived from entitlement
- free users can receive quiet ad placements
- premium users receive no ads
- ad consent state must be stored separately from analytics consent if required

## Watch-availability model decisions

- watch data is event + country scoped
- selected country can be auto-detected but user-controlled
- watch availability should carry confidence and last verification metadata

## UX-driven model decisions

- followed fighters must be easy to query for home-screen visibility
- event summaries should be renderable in collapsed and expanded form
- the event model should expose both hero metadata and fight-card details without separate shape conversion
