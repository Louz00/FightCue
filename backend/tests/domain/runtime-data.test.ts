import test from "node:test";
import assert from "node:assert/strict";

import { sampleEvents, sampleUserProfile } from "../../src/domain/mock-data.js";
import {
  buildEventCalendarIcs,
  buildRuntimeEvents,
  mergeExternalEvents,
} from "../../src/domain/runtime-data.js";
import type { PersistedUserState } from "../../src/store/user-state-store.js";

const baseState: PersistedUserState = {
  profile: {
    userId: "usr_test_device",
    language: sampleUserProfile.language,
    timezone: sampleUserProfile.timezone,
    viewingCountryCode: sampleUserProfile.viewingCountryCode,
    premiumState: sampleUserProfile.premiumState,
    analyticsConsent: sampleUserProfile.analyticsConsent,
    adConsentGranted: sampleUserProfile.adConsentGranted,
  },
  follows: {
    fighterIds: ["ftr_renato_moicano"],
    eventIds: ["evt_ufc_fight_night_moicano_duncan"],
  },
  alerts: {
    fighters: {},
    events: {},
  },
};

test("buildEventCalendarIcs renders a valid event payload", () => {
  const event = sampleEvents.find((item) => item.id === "evt_ufc_327");

  assert.ok(event);

  const ics = buildEventCalendarIcs(event);

  assert.match(ics, /BEGIN:VCALENDAR/);
  assert.match(ics, /BEGIN:VEVENT/);
  assert.match(ics, /SUMMARY:UFC: Pereira vs Ankalaev/);
  assert.match(ics, /URL:https:\/\/www\.ufc\.com\/events/);
  assert.match(ics, /END:VCALENDAR/);
});

test("mergeExternalEvents preserves stable IDs and follow state for matching UFC events", () => {
  const baseEvents = buildRuntimeEvents(baseState);
  const moicanoEvent = sampleEvents.find(
    (item) => item.id === "evt_ufc_fight_night_moicano_duncan",
  );

  assert.ok(moicanoEvent);

  const liveReplacement = {
    ...moicanoEvent,
    id: "evt_ufc_live_moicano_duncan",
    title: "UFC Fight Night: Moicano vs Duncan",
    watchProviders: [],
  };

  const merged = mergeExternalEvents(
    baseState,
    baseEvents,
    [liveReplacement],
    "ufc",
  );

  const mergedEvent = merged.find(
    (event) => event.id === "evt_ufc_fight_night_moicano_duncan",
  );

  assert.ok(mergedEvent);
  assert.equal(mergedEvent.title, "UFC Fight Night: Moicano vs Duncan");
  assert.equal(mergedEvent.isFollowed, true);
  assert.equal(mergedEvent.bouts[0]?.includesFollowedFighter, true);
});
