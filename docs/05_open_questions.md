# Open Questions

These are the inputs still needed from the owner to keep building without avoidable rework.

## Needed soon

1. Do you want to keep the temporary working company/publisher name `Solmeriq Labs`, or replace it later after legal clearance?
2. Do you want to keep the temporary working app ID `com.lou.fightcue`, or replace it with another reverse-domain identifier later?
3. Which real source should be implemented first after the scaffold: `Matchroom`, `UFC`, or `GLORY`?
4. Do you want optional account creation to be visible in v1 UI immediately, or only after sync/restore is ready?
5. Which official boxing ranking family should be evaluated first for a later leaderboard feature: WBA, WBC, IBF, WBO, or Ring-style editorial rankings?
6. Should ad consent be handled with a lightweight custom consent flow first, or should we plan for a dedicated consent SDK from the start?

## Working assumptions for now

- `FightCue` is the final app name
- Flutter is the mobile framework
- Android and iOS are both first-class targets
- launch will focus on reliable upcoming events, not live scoring
- payments will use native store billing
- languages at launch are English, Dutch, and Spanish
- store setup is prepared in code, but not connected to live Apple or Google accounts yet
- `Solmeriq Labs` is the temporary working company and store-publisher name
- source coverage will use official promoter/organization channels first
- users are anonymous by default with optional account creation
- email magic link is the first optional account method
- free tier uses quiet ads and premium removes ads
- Google AdMob is the default ad-network direction
- users can follow fighters as well as events
- watch availability is country-based with manual override
- boxing leaderboards are deferred until official-source framing is chosen
- company and publisher naming can still change later after legal and trademark checks

## Inputs needed later

- privacy policy URL
- terms of use URL
- analytics tooling choice
- crash reporting choice
- brand colors, typography, and logo direction
- subscription packaging and exact launch pricing
