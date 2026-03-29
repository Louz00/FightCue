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

## Official channels to use

### Boxing

- Matchroom: https://www.matchroomboxing.com/events/
- Queensberry: https://queensberry.co.uk/pages/events
- Premier Boxing Champions: https://www.premierboxingchampions.com/boxing-schedule
- Golden Boy: https://www.goldenboy.com/en/events
- Top Rank: https://www.toprank.com/

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
