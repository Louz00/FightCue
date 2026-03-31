# Source Channels

This document defines the official source channels FightCue should use for event ingestion.

## Important interpretation

Here, "channels" means official source channels for event data, not TV broadcasters.

Broadcast/watch data should be captured as optional event metadata from official event pages, because broadcast rights can differ by country and change over time.

## Launch source strategy

### Boxing

Boxing has no single official master source. To cover the most important fights, FightCue should use a promoter cluster:

1. Matchroom
2. Queensberry
3. Top Rank
4. Premier Boxing Champions
5. Golden Boy
6. BOXXER

Current implementation status:
- Matchroom: live
- Queensberry: live
- Top Rank: live
- Premier Boxing Champions: live
- Golden Boy: live
- BOXXER: live
- ESPN boxing schedule: live secondary validation/enrichment layer
- ESPN boxing rankings: live editorial leaderboard source layer
- Ring boxing ratings: live editorial leaderboard source layer

### MMA

1. UFC
2. Later: PFL
3. Later: ONE Championship

### Kickboxing

1. GLORY
2. Later: ONE Championship kickboxing where relevant

## Recommended implementation order

If the goal is balanced launch coverage across the target sports:

1. Matchroom
2. UFC
3. GLORY
4. Queensberry
5. Top Rank
6. Premier Boxing Champions
7. Golden Boy

If the goal shifts to boxing-heavy coverage first, then the boxing promoter cluster should be completed before adding more MMA or kickboxing sources.

## Why this approach

- official event pages are more defensible than unofficial aggregators
- promoter sites usually expose date, venue, tickets, and fight-card details
- UFC and GLORY have clearer centralized event structures
- boxing needs multiple promoters because major fights are fragmented across organizations

## Secondary editorial sources

These are useful, but should not replace the official promoter cluster as the main source of truth.

- ESPN boxing schedule: useful as a broad editorial schedule layer and validation source, especially for major headline cards and broadcast labels
- ESPN divisional rankings: useful as a possible later source-labeled boxing leaderboard input
- ESPN divisional rankings source preview is now implemented for both men's and women's boxing divisions
- Ring Magazine events: useful as a broad editorial signal, but currently less structured than promoter pages and better treated as a secondary layer
- Ring Magazine rankings: valuable candidate input for later boxing leaderboard features, but they should always be labeled as Ring editorial ratings rather than official governing-body rankings
- Ring ratings source preview now uses a curated set of `The Ring Ratings Reviewed` division pages discovered from the Ring sitemap

## Official channels to use

### Boxing

- Matchroom: https://www.matchroomboxing.com/events/
- Queensberry: https://queensberry.co.uk/pages/events
- Premier Boxing Champions: https://www.premierboxingchampions.com/boxing-schedule
- Golden Boy: https://www.goldenboy.com/events/
- Top Rank: https://www.toprank.com/
- BOXXER: https://www.boxxer.com/tickets/

### MMA

- UFC: https://www.ufc.com/events
- PFL: https://pflmma.com/
- ONE Championship: https://www.onefc.com/events/

### Kickboxing

- GLORY: https://glorykickboxing.com/en/events

## Data handling rules

- use official source pages first
- prefer structured JSON or embedded data where available
- keep source URL for every normalized event
- store event-local timezone separately from UTC
- treat watch/broadcast info as optional and territory-sensitive metadata
