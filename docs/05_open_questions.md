# Open Questions

These are the inputs still needed from the owner to keep building without avoidable rework.

## Needed soon

1. What public developer or company name should eventually appear in the App Store and Google Play listings?
2. Do you want to keep the temporary working app ID `com.lou.fightcue`, or replace it with another reverse-domain identifier later?
3. Which real source should be implemented first after the scaffold: `Matchroom`, `UFC`, or `GLORY`?
4. What account method should optional sign-in use first: email magic link, Google, Apple, or a mix?
5. How should boxing leaderboards be defined first: official sanctioning-body rankings, promoter-specific rankings, or FightCue popularity/trending?
6. Which ad network should be the default choice for free-tier ads?

## Working assumptions for now

- `FightCue` is the final app name
- Flutter is the mobile framework
- Android and iOS are both first-class targets
- launch will focus on reliable upcoming events, not live scoring
- payments will use native store billing
- languages at launch are English, Dutch, and Spanish
- store setup is prepared in code, but not connected to live Apple or Google accounts yet
- source coverage will use official promoter/organization channels first
- users are anonymous by default with optional account creation
- free tier uses quiet ads and premium removes ads
- users can follow fighters as well as events
- watch availability is country-based with manual override

## Inputs needed later

- privacy policy URL
- terms of use URL
- analytics tooling choice
- crash reporting choice
- brand colors, typography, and logo direction
- subscription packaging and exact launch pricing
