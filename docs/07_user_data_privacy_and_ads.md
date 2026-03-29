# User Data, Privacy, and Ads

## Identity model

- the app should work without mandatory account creation
- every install receives an anonymous app user profile
- optional account creation can later link that profile for sync and restore
- premium purchase handling should work without forcing account signup
- optional account improves cross-device continuity and future cloud sync

## Data categories we should store

### Operational data

- anonymous app user ID
- app version
- language
- timezone
- selected viewing country
- followed fighters
- followed events
- alert preferences
- push token
- premium entitlement state
- consent settings

### Optional account data

- account identifier
- sign-in provider
- minimal login metadata

### Event metadata

- event timezone
- normalized UTC start time
- organization
- fight card
- watch providers by country
- ranking references where applicable

## Data we should avoid by default

- precise GPS location
- contacts
- microphone
- photo library access unrelated to the product
- unnecessary advertising identifiers
- any personal data not clearly tied to a product function

## Privacy rules

- collect only what is needed to operate follows, alerts, purchases, and watch preferences
- default to anonymous usage
- make optional account truly optional
- provide clear consent controls for analytics and advertising where required
- keep privacy disclosures easy to find in settings
- support future delete/export flows in the backend design

## Security rules

- secrets only in environment variables or secret managers
- validate all public API input
- store premium entitlements server-side
- use least-privilege credentials
- rate limit public endpoints
- keep audit logs for sensitive verification actions

## Ads policy

- ads only appear in the free tier
- premium users see no ads
- ads must stay quiet and non-disruptive
- no intrusive interstitials during event detail, alerts, or key fight flows
- ads should not visually overpower timing and watch information
- ad consent must respect jurisdictional requirements

## Recommended ad placement pattern

- feed placements between event groups or lower in long lists
- avoid placing ads above the fold on the first home view
- avoid inserting ads inside the expanded fight-card content
- avoid placing ads directly next to critical CTA buttons like Follow, Alert, or Calendar
