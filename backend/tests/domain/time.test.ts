import test from "node:test";
import assert from "node:assert/strict";

import { compareEventsByStart, formatForTimezone, normalizeTimeZone } from "../../src/domain/time.js";
import { sampleEvents, sampleUserProfile } from "../../src/domain/mock-data.js";

test("normalizeTimeZone falls back to the runtime default for invalid values", () => {
  assert.equal(normalizeTimeZone("Mars/Olympus"), sampleUserProfile.timezone);
});

test("formatForTimezone formats a stable local date and time", () => {
  const result = formatForTimezone(
    new Date("2026-04-05T00:00:00Z"),
    "Europe/Amsterdam",
  );

  assert.equal(result.localDateLabel, "Sun 5 Apr");
  assert.equal(result.localTimeLabel, "02:00");
});

test("compareEventsByStart sorts chronologically", () => {
  const sorted = [...sampleEvents].sort(compareEventsByStart);

  assert.equal(sorted[0]?.id, "evt_ufc_fight_night_moicano_duncan");
  assert.equal(sorted.at(-1)?.id, "evt_ufc_327");
});
