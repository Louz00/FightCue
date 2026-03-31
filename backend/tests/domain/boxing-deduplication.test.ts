import test from "node:test";
import assert from "node:assert/strict";

import { filterUniqueBoxingEventsAgainstExisting } from "../../src/domain/boxing-deduplication.js";
import type { EventSummary } from "../../src/domain/models.js";

test("filterUniqueBoxingEventsAgainstExisting removes ESPN duplicates of official boxing events", () => {
  const existingEvents = [
    createBoxingEvent({
      id: "evt_matchroom_1",
      organizationSlug: "matchroom",
      organizationName: "Matchroom",
      title: "Smith vs Morrell",
      scheduledStartUtc: "2026-04-18T19:00:00Z",
      fighterAName: "Callum Smith",
      fighterBName: "David Morrell",
    }),
  ];
  const candidateEvents = [
    createBoxingEvent({
      id: "evt_espn_1",
      organizationSlug: "espn_boxing",
      organizationName: "ESPN Boxing",
      title: "Callum Smith vs David Morrell",
      scheduledStartUtc: "2026-04-18T12:00:00Z",
      fighterAName: "David Morrell",
      fighterBName: "Callum Smith",
    }),
    createBoxingEvent({
      id: "evt_espn_2",
      organizationSlug: "espn_boxing",
      organizationName: "ESPN Boxing",
      title: "Wilder vs Chisora",
      scheduledStartUtc: "2026-04-04T12:00:00Z",
      fighterAName: "Deontay Wilder",
      fighterBName: "Derek Chisora",
    }),
  ];

  const filtered = filterUniqueBoxingEventsAgainstExisting(
    existingEvents,
    candidateEvents,
  );

  assert.equal(filtered.length, 1);
  assert.equal(filtered[0]?.id, "evt_espn_2");
});

test("filterUniqueBoxingEventsAgainstExisting matches surname-only promoter titles to full-name editorial titles", () => {
  const existingEvents = [
    createBoxingEvent({
      id: "evt_matchroom_2",
      organizationSlug: "matchroom",
      organizationName: "Matchroom",
      title: "Smith vs Morrell",
      scheduledStartUtc: "2026-04-18T19:00:00Z",
      fighterAName: "Smith",
      fighterBName: "Morrell",
    }),
  ];
  const candidateEvents = [
    createBoxingEvent({
      id: "evt_espn_3",
      organizationSlug: "espn_boxing",
      organizationName: "ESPN Boxing",
      title: "Callum Smith vs David Morrell",
      scheduledStartUtc: "2026-04-18T12:00:00Z",
      fighterAName: "Callum Smith",
      fighterBName: "David Morrell",
    }),
  ];

  const filtered = filterUniqueBoxingEventsAgainstExisting(
    existingEvents,
    candidateEvents,
  );

  assert.equal(filtered.length, 0);
});

test("filterUniqueBoxingEventsAgainstExisting matches the same local event date across different source timezones", () => {
  const existingEvents = [
    createBoxingEvent({
      id: "evt_pbc_1",
      organizationSlug: "pbc",
      organizationName: "Premier Boxing Champions",
      title: "David Benavidez vs Gilberto Ramirez",
      scheduledStartUtc: "2026-05-03T00:00:00Z",
      scheduledTimezone: "America/New_York",
      fighterAName: "David Benavidez",
      fighterBName: "Gilberto Ramirez",
    }),
  ];
  const candidateEvents = [
    createBoxingEvent({
      id: "evt_golden_boy_1",
      organizationSlug: "golden_boy",
      organizationName: "Golden Boy",
      title: "David \"The Monster\" Benavidez vs Gilberto \"Zurdo\" Ramirez",
      scheduledStartUtc: "2026-05-03T03:00:00Z",
      scheduledTimezone: "America/Los_Angeles",
      fighterAName: "David \"The Monster\" Benavidez",
      fighterBName: "Gilberto \"Zurdo\" Ramirez",
    }),
  ];

  const filtered = filterUniqueBoxingEventsAgainstExisting(
    existingEvents,
    candidateEvents,
  );

  assert.equal(filtered.length, 0);
});

function createBoxingEvent({
  id,
  organizationSlug,
  organizationName,
  title,
  scheduledStartUtc,
  fighterAName,
  fighterBName,
  scheduledTimezone = "UTC",
}: {
  id: string;
  organizationSlug: string;
  organizationName: string;
  title: string;
  scheduledStartUtc: string;
  scheduledTimezone?: string;
  fighterAName: string;
  fighterBName: string;
}): EventSummary {
  return {
    id,
    organizationSlug,
    organizationName,
    sport: "boxing",
    title,
    tagline: "test",
    locationLabel: "Test City",
    venueLabel: "Test Venue",
    scheduledStartUtc,
    scheduledTimezone,
    localDateLabel: "Test Date",
    localTimeLabel: "TBA",
    eventLocalTimeLabel: "TBA",
    selectedCountryCode: "NL",
    status: "scheduled",
    isFollowed: false,
    sourceLabel: "test",
    watchProviders: [],
    bouts: [
      {
        id: `bout_${id}`,
        slotLabel: "Main event",
        fighterAId: `ftr_${fighterAName}`,
        fighterAName,
        fighterBId: `ftr_${fighterBName}`,
        fighterBName,
        isMainEvent: true,
        includesFollowedFighter: false,
      },
    ],
  };
}
