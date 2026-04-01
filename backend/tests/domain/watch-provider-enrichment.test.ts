import test from "node:test";
import assert from "node:assert/strict";

import { sampleEvents } from "../../src/domain/mock-data.js";
import { enrichWatchProvidersForCountry } from "../../src/domain/watch-provider-enrichment.js";
import type { EventSummary } from "../../src/domain/models.js";

test("enrichWatchProvidersForCountry applies event-specific country overrides", () => {
  const event = sampleEvents.find((entry) => entry.id === "evt_ufc_327");
  assert.ok(event);

  const providers = enrichWatchProvidersForCountry(event, "US");
  const espnPpv = providers.find((provider) => provider.label === "ESPN+ PPV");

  assert.equal(providers.some((provider) => provider.label === "ESPN+ PPV"), true);
  assert.equal(providers.every((provider) => provider.countryCode === "US"), true);
  assert.equal(espnPpv?.verificationSource, "event_override");
});

test("enrichWatchProvidersForCountry falls back to official event page when no providers exist", () => {
  const event = sampleEvents.find((entry) => entry.id === "evt_glory_107");
  assert.ok(event);

  const providers = enrichWatchProvidersForCountry(event, "NL");

  assert.equal(providers.length, 1);
  assert.equal(providers[0]?.label, "GLORY event page");
  assert.equal(providers[0]?.providerUrl, event.officialUrl);
  assert.equal(providers[0]?.verificationSource, "organization_default");
});

test("enrichWatchProvidersForCountry preserves source-provided providers over weaker defaults", () => {
  const event = sampleEvents.find((entry) => entry.id === "evt_ufc_fight_night_moicano_duncan");
  assert.ok(event);

  const providers = enrichWatchProvidersForCountry(event, "NL");
  const provider = providers.find((entry) => entry.label === "UFC Fight Pass");

  assert.ok(provider);
  assert.equal(provider.verificationSource, "source");
});

test("enrichWatchProvidersForCountry uses conservative organization defaults for unmatched countries", () => {
  const event = sampleEvents.find((entry) => entry.id === "evt_glory_107");
  assert.ok(event);

  const providers = enrichWatchProvidersForCountry(event, "US");

  assert.equal(providers.length, 1);
  assert.equal(providers[0]?.label, "GLORY event page");
  assert.equal(providers[0]?.confidence, "unknown");
  assert.equal(providers[0]?.verificationSource, "organization_default");
});

test("enrichWatchProvidersForCountry falls back to the official page when no source or org defaults exist", () => {
  const customEvent: EventSummary = {
    id: "evt_custom_unknown",
    organizationSlug: "custom",
    organizationName: "Custom Org",
    sport: "boxing",
    title: "Custom Event",
    tagline: "Test",
    locationLabel: "Test City",
    venueLabel: "Test Venue",
    scheduledStartUtc: "2026-04-01T20:00:00.000Z",
    scheduledTimezone: "UTC",
    localDateLabel: "Wed 1 Apr",
    localTimeLabel: "20:00",
    eventLocalTimeLabel: "20:00 UTC",
    selectedCountryCode: "NL",
    status: "scheduled",
    isFollowed: false,
    sourceLabel: "Custom source",
    officialUrl: "https://example.com/custom-event",
    watchProviders: [],
    bouts: [],
  };

  const providers = enrichWatchProvidersForCountry(customEvent, "NL");

  assert.equal(providers.length, 1);
  assert.equal(providers[0]?.label, "Custom Org event page");
  assert.equal(providers[0]?.verificationSource, "official_page_fallback");
});

test("enrichWatchProvidersForCountry lets a stronger event override beat a weak source provider", () => {
  const event = sampleEvents.find((entry) => entry.id === "evt_ufc_327");
  assert.ok(event);

  const providers = enrichWatchProvidersForCountry(
    {
      ...event,
      watchProviders: [
        {
          label: "ESPN+ PPV",
          kind: "ppv",
          countryCode: "US",
          confidence: "unknown",
          lastVerifiedAt: "2026-04-01T08:00:00.000Z",
          verificationSource: "source",
        },
      ],
    },
    "US",
  );
  const provider = providers.find((entry) => entry.label === "ESPN+ PPV");

  assert.ok(provider);
  assert.equal(provider.verificationSource, "event_override");
  assert.equal(provider.confidence, "likely");
});

test("enrichWatchProvidersForCountry keeps a strong source provider over a weaker override", () => {
  const event = sampleEvents.find((entry) => entry.id === "evt_ufc_327");
  assert.ok(event);

  const providers = enrichWatchProvidersForCountry(
    {
      ...event,
      watchProviders: [
        {
          label: "ESPN+ PPV",
          kind: "ppv",
          countryCode: "US",
          confidence: "confirmed",
          lastVerifiedAt: "2026-04-01T08:00:00.000Z",
          verificationSource: "source",
          providerUrl: "https://plus.espn.com/ufc-327",
        },
      ],
    },
    "US",
  );
  const provider = providers.find((entry) => entry.label === "ESPN+ PPV");

  assert.ok(provider);
  assert.equal(provider.verificationSource, "source");
  assert.equal(provider.confidence, "confirmed");
  assert.equal(provider.providerUrl, "https://plus.espn.com/ufc-327");
});
