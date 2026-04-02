# UX and UI Direction

## Design goal

FightCue should feel professional, clean, premium, and calm. The app should present combat sports information with editorial confidence, strong local-time clarity, and very little visual noise.

## Current product direction

- home shows only upcoming events
- followed fighters and saved events live in a dedicated favorites area, not on home
- `GLORY` should be labeled as `Glory Kickboxing` in the UI
- saved fighters use a heart icon
- saved events use a glove icon
- watch-provider information is intentionally hidden in this design pass
- stylized original avatars should be used instead of real fighter photos
- settings should stay minimal and practical
- ads are removed only for premium users; there is no manual ad toggle

## Current page map

Primary navigation:

1. `Home`
2. `Leaderboard`
3. `Favorites`
4. `Alerts`
5. `Settings`

Supporting screens:

- `Event detail`
- `Fighter profile`
- `Premium / Paywall`

Current repo coverage already includes the same functional areas under the existing shell:

- home
- rankings
- following
- alerts
- settings
- event detail
- fighter profile
- paywall

For the next UI pass, `Following` should become `Favorites`, and `Rankings` may be presented as `Leaderboard`.

## Core UX principles

- local date and time should remain the strongest information hierarchy on event surfaces
- home must feel like an upcoming-events feed, not a dashboard
- favorites should feel personal and fast to scan
- leaderboards should feel authoritative and source-labeled
- detail screens should provide structure without becoming visually heavy
- the app should avoid clutter, noise, fake urgency, and visual over-explanation

## Home

The home screen should show only upcoming events.

Required behavior:

- no followed fighters block on home
- no saved events block on home
- multi-select filtering instead of single-select filtering
- users must be able to combine filters such as:
  - `Boxing + UFC`
  - `Boxing + Glory Kickboxing`
  - `MMA + Kickboxing`
- events should be sorted by what is coming up next
- cards should stay compact and easy to compare

Recommended event card content:

- organization
- event title
- local date
- local start time
- city and venue
- key bout or headline matchup when available
- save-event action with glove icon

Do not show watch-provider blocks on home in this pass.

## Favorites

Favorites should replace the current conceptual role of `Following`.

Recommended structure:

- segmented control or top tabs:
  - `Fighters`
  - `Events`

### Favorites -> Fighters

- fighter rows or cards use a heart icon for saved state
- each card should show:
  - avatar
  - fighter name
  - organization hint
  - record or short status line
  - next-fight status if known
- tapping a fighter opens the fighter profile

### Favorites -> Events

- event rows or cards use a glove icon for saved state
- each card should show:
  - event title
  - organization
  - local date and time
  - location
  - main event if available
- saved events should make calendar export easy to discover

## Fighter profile

The fighter profile should feel like a lightweight athlete dossier.

Required sections:

- avatar
- name and nickname
- organization
- nationality
- record
- tale of the tape
- next fight block
- related events block

Recommended tale-of-the-tape fields:

- age
- height
- reach
- weight class
- stance
- record
- nationality
- last updated label if this data can go stale

If no upcoming fight exists, show a clean `not currently booked` state instead of guessing.

## Event detail

The event detail screen should prioritize clarity and actionability.

Required sections:

- event header
- local date and time first
- venue and city
- main card / prelim structure
- save-event glove action
- calendar export action
- fighter rows with avatar support

Do not show watch-provider information in this pass.

## Leaderboard

Leaderboards should live in a dedicated section and feel editorial and trustworthy.

Rules:

- show more than five fighters
- support at least ten entries per list
- scale cleanly when the source provides more
- keep source labeling visible
- avoid mixing official source rankings with any future FightCue-owned popularity list

Useful filters:

- organization
- division / weight class
- men / women where relevant

## Alerts

Alerts should remain lightweight.

The page should manage reminder presets for:

- saved fighters
- saved events

The UX should feel supportive, not technical or overloaded.

## Settings

Settings should only contain what users actually need.

Keep:

- language
- notifications
- timezone
- premium

Avoid for now:

- manual ad on/off switches
- watch-provider settings
- dense runtime or developer-style information in the main consumer layout

## Premium / Paywall

The paywall should be calm, clean, and trustworthy.

Key message:

- free tier includes ads
- premium removes ads
- premium can also position better reminder experience and cleaner reading flow

Avoid a loud or aggressive subscription page.

## Visual direction

- white or off-white base
- strong red accent
- premium editorial sports feel
- strong typography for event time, event title, and main bout
- generous spacing
- clean card rhythm
- stylized avatars, not real photos
- no cluttered dashboard layouts
- no fake sports-betting look and feel

## AI design prompt

```text
Design a professional, clean, premium mobile app UI and UX for FightCue, a combat sports app for iOS and Android.

FightCue helps users track upcoming combat sports events in their local timezone. The product covers Boxing, UFC, MMA, Kickboxing, and specifically Glory Kickboxing.

Important product rules:
- Home must show only upcoming events.
- Do not place followed fighters or saved events on the home screen.
- Home needs multi-select filter chips, so users can combine filters like Boxing + UFC or Boxing + Glory Kickboxing.
- Use the label "Glory Kickboxing" instead of "Glory".
- Fighters can be saved with a heart icon.
- Events can be saved with a glove icon.
- Saved events must support calendar export with the correct local date and time.
- Fighter profile must show a tale of the tape and whether the fighter has an upcoming fight, including which event it is.
- Leaderboards must support at least 10 fighters per list, and scale cleanly when there are more.
- Settings must stay simple and practical.
- There must be no manual ad on/off toggle. Ads are removed only when the user has premium.
- Do not show where users can watch the fight in this design pass.
- Use stylized, original avatars instead of real fighter photos.

Required page map:
1. Home
   - Upcoming events only
   - Multi-select filter chips
   - Clean event cards with event name, organization, local date, local time, city/venue, key bout if available, and save-event glove action

2. Leaderboard
   - Ranking lists with at least 10 entries
   - Clear hierarchy for rank, fighter, record, and source
   - Must work for longer lists without feeling crowded

3. Favorites
   - Split into two tabs or segments: Fighters and Events
   - Fighters view shows liked fighters with heart icon
   - Events view shows saved events with glove icon

4. Fighter Profile
   - Avatar
   - Name, nickname if available, record, nationality, organization
   - Tale of the tape section
   - Next fight section
   - Related event cards if booked

5. Event Detail
   - Strong event header
   - Local date/time first
   - Main card and prelim structure
   - Save-event glove action
   - Calendar export action
   - Fighter rows with avatars and heart-save affordance where relevant

6. Alerts
   - Lightweight reminder management for saved fighters and saved events
   - Should feel simple, not like an enterprise settings panel

7. Settings
   - Language
   - Notifications
   - Timezone
   - Premium
   - No ad toggle

8. Premium / Paywall
   - Free vs Premium comparison
   - Premium removes ads
   - Clean and trustworthy presentation

Visual direction:
- Editorial sports product feel
- White or off-white base with strong red accents
- Premium, minimal, modern, clean
- Strong typography and time/date hierarchy
- Card-based layout with generous breathing room
- No clutter, no noisy dashboards, no gimmicky gamification
- Must feel polished on both iPhone and Android

Output requested:
- mobile-first UX structure
- navigation map
- wireframe-level screen descriptions
- polished visual direction
- key components and interaction patterns
- clean, production-ready UI concept
```
