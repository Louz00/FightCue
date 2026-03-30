# UX and UI Direction

## Design goal

FightCue should feel clean, premium, and fast. The app should reduce friction, not add noise, and should present fight information with the confidence of an editorial sports product.

## Core UX principles

- local time is the primary visual element
- followed fighters and followed events are the first things a user should notice
- event cards should show only the most useful information by default
- extra detail should expand on demand instead of cluttering the screen
- the app should feel calm even when showing a lot of fight data

## Home screen structure

Recommended order:

1. next important fight or event
2. followed fighters section
3. followed events section
4. upcoming events grouped by date
5. quiet ad slot lower in the feed for free users only

## Event card pattern

Each event card should show:

- organization
- date
- local start time
- location
- main event or primary bout
- watch provider summary for the selected country
- quick actions for follow, alert, and calendar

Each card should also support an expandable section or accordion:

- collapsed state shows the clean summary
- expanded state shows the full fight card without leaving the list
- expanded content should remain visually lightweight

## Event detail screen

The event detail view should provide:

- event header with a strong branded red band and local time first
- event-local timezone as secondary metadata
- clear separation between main card and preliminary card
- country-specific watch information
- full fight card
- follow and alert actions
- clear status labels if timing changes

## Fighter follow UX

- users should be able to follow fighters directly from event and bout surfaces
- followed fighters should appear on home immediately
- followed fighters should drive alert suggestions and visibility
- if a followed fighter gets booked on a new event, that should surface clearly in home and notifications

## Leaderboard UX

- leaderboards should live in a dedicated section, not crowd the main event flow
- every leaderboard must show its source or label
- official rankings and FightCue popularity lists must never be visually conflated

## Country-specific watch UX

- viewing country should default intelligently
- users must be able to override the country manually in settings
- the selected country should be obvious when watch providers are shown
- if availability is uncertain, show that uncertainty honestly

## Ad UX rules

- ads only in free screens
- ads should blend into the layout without pretending to be content
- do not place ads above primary user goals
- do not interrupt alert setup, follow actions, or event detail reading

## Visual direction

- white-first with red as the primary accent
- UFC-inspired editorial rhythm without copying licensed imagery
- strong hierarchy for time, card section, and main-event status
- mirrored fighter layouts for bout rows, so each matchup reads immediately
- original cartoon portrait avatars instead of real photos until licensed imagery exists
- compact cards with generous spacing
- no overcrowded dashboards
