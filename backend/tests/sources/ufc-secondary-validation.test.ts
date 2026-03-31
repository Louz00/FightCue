import test from "node:test";
import assert from "node:assert/strict";

import type { EventSummary } from "../../src/domain/models.js";
import {
  buildEspnValidationWarnings,
  normalizeUfcEventTitleForComparison,
} from "../../src/sources/ufc/ufc-secondary-validation.js";

function createEvent(title: string): EventSummary {
  return {
    id: `evt_${normalizeUfcEventTitleForComparison(title).replace(/\s+/g, "_")}`,
    organizationSlug: "ufc",
    organizationName: "UFC",
    sport: "mma",
    title,
    tagline: "Test event",
    locationLabel: "Test location",
    venueLabel: "Test venue",
    scheduledStartUtc: "2026-04-04T21:00:00.000Z",
    scheduledTimezone: "UTC",
    localDateLabel: "Sat 4 Apr",
    localTimeLabel: "21:00",
    eventLocalTimeLabel: "Sat 4 Apr • 9:00 PM UTC",
    selectedCountryCode: "NL",
    status: "scheduled",
    isFollowed: false,
    sourceLabel: "Test source",
    watchProviders: [],
    bouts: [],
  };
}

test("normalizeUfcEventTitleForComparison matches UFC and ESPN naming variants", () => {
  assert.equal(
    normalizeUfcEventTitleForComparison("Moicano vs Duncan"),
    normalizeUfcEventTitleForComparison("UFC Fight Night: Moicano vs. Duncan"),
  );
  assert.equal(
    normalizeUfcEventTitleForComparison("Prochazka vs Ulberg"),
    normalizeUfcEventTitleForComparison("UFC 327: Procházka vs. Ulberg"),
  );
});

test("buildEspnValidationWarnings stays quiet when the same upcoming cards are present", () => {
  const warnings = buildEspnValidationWarnings(
    [
      createEvent("Moicano vs Duncan"),
      createEvent("Prochazka vs Ulberg"),
    ],
    [
      {
        title: "UFC Fight Night: Moicano vs. Duncan",
        broadcastLabels: ["Paramount+"],
      },
      {
        title: "UFC 327: Procházka vs. Ulberg",
        broadcastLabels: ["CBS", "Paramount+"],
      },
    ],
  );

  assert.deepEqual(warnings, []);
});

test("buildEspnValidationWarnings reports missing ESPN cards and count drift", () => {
  const warnings = buildEspnValidationWarnings(
    [createEvent("Moicano vs Duncan")],
    [
      {
        title: "UFC Fight Night: Moicano vs. Duncan",
        broadcastLabels: ["Paramount+"],
      },
      {
        title: "UFC 327: Procházka vs. Ulberg",
        broadcastLabels: ["CBS", "Paramount+"],
      },
    ],
  );

  assert.equal(warnings.length, 2);
  assert.match(warnings[0] ?? "", /ESPN UFC schedule lists 1 upcoming event/);
  assert.match(warnings[1] ?? "", /Secondary UFC validation count differs from ESPN/);
});
