import test from "node:test";
import assert from "node:assert/strict";

import {
  extractBoxxerDateFromText,
  isLikelyUpcomingBoxxerEvent,
  mapBoxxerPostToSummary,
} from "../../../src/sources/boxxer/boxxer-events-source.js";

test("mapBoxxerPostToSummary parses a confirmed BOXXER main event with broadcast labels", () => {
  const event = mapBoxxerPostToSummary(
    {
      id: 35549,
      slug: "awaken-the-dragon-lauren-price-vs-stephanie-aquino-4-apr-2026-utilita-arena-cardiff",
      link: "https://www.boxxer.com/events/awaken-the-dragon-lauren-price-vs-stephanie-aquino-4-apr-2026-utilita-arena-cardiff/",
      date: "2026-01-30T08:34:47",
      title: {
        rendered:
          "AWAKEN THE DRAGON &#8211; Lauren Price vs Stephanie Pineiro, 4 Apr 2026, Utilita Arena Cardiff",
      },
      content: {
        rendered:
          "<p><b>Lauren Price MBE</b> will defend her world titles against <b>Stephanie Pineiro Aquino</b> on <b>Saturday, April 4</b> at the <b>Utilita Arena</b> in <b>Cardiff</b>. This event will be broadcast live and free-to-air on <b>BBC Two</b> and <b>BBC iPlayer</b>.</p><a href=\"https://www.ticketmaster.co.uk/example\">Buy Tickets from Ticketmaster</a>",
      },
    },
    {
      timezone: "Europe/Amsterdam",
      selectedCountryCode: "NL",
    },
    "2026-03-31T00:00:00.000Z",
  );

  assert.ok(event);
  assert.equal(event.title, "Lauren Price vs Stephanie Pineiro");
  assert.equal(event.scheduledTimezone, "Europe/London");
  assert.equal(event.venueLabel, "Utilita Arena Cardiff");
  assert.deepEqual(
    event.watchProviders.map((provider) => provider.label),
    ["BBC Two", "BBC iPlayer"],
  );
});

test("mapBoxxerPostToSummary falls back to a headliner when the opponent is not announced yet", () => {
  const event = mapBoxxerPostToSummary(
    {
      id: 35772,
      slug: "boxxer-expands-into-the-netherlands-with-major-event-in-rotterdam-headlined-by-gradus-kraus",
      link: "https://www.boxxer.com/events/boxxer-expands-into-the-netherlands-with-major-event-in-rotterdam-headlined-by-gradus-kraus/",
      date: "2026-03-27T15:57:04",
      title: {
        rendered:
          "BOXXER expands into the Netherlands with major event in Rotterdam headlined by Gradus Kraus",
      },
      content: {
        rendered:
          "<p>BOXXER continues its international expansion with the announcement of its first event in the Netherlands on <b>Saturday, May 9</b> at the <b>Topsportcentrum</b> in <b>Rotterdam</b>.</p><p>The event will be headlined by light heavyweight star <b>Gradus Kraus</b>.</p>",
      },
    },
    {
      timezone: "Europe/Amsterdam",
      selectedCountryCode: "NL",
    },
    "2026-03-31T00:00:00.000Z",
  );

  assert.ok(event);
  assert.equal(event.title, "Gradus Kraus vs TBA");
  assert.equal(event.scheduledTimezone, "Europe/Amsterdam");
  assert.equal(event.bouts[0]?.fighterBName, "TBA");
  assert.equal(event.bouts[0]?.weightClass, "Light Heavyweight");
});

test("extractBoxxerDateFromText parses both title and editorial date formats", () => {
  assert.deepEqual(
    extractBoxxerDateFromText("31 Jan 2026, Copper Box Arena, London", {
      fallbackYear: 2026,
    }),
    {
      year: 2026,
      month: 1,
      day: 31,
    },
  );
  assert.deepEqual(
    extractBoxxerDateFromText("Saturday, May 9 at the Topsportcentrum", {
      fallbackYear: 2026,
    }),
    {
      year: 2026,
      month: 5,
      day: 9,
    },
  );
});

test("isLikelyUpcomingBoxxerEvent ignores older historical BOXXER event posts", () => {
  assert.equal(
    isLikelyUpcomingBoxxerEvent({
      id: 34933,
      slug: "champions-are-made-frazer-clarke-vs-jeamie-tkv-29-nov-2025-vaillant-live-derby",
      link: "https://www.boxxer.com/events/champions-are-made-frazer-clarke-vs-jeamie-tkv-29-nov-2025-vaillant-live-derby/",
      date: "2025-09-25T08:45:07",
      title: {
        rendered:
          "CHAMPIONS ARE MADE &#8211; Frazer Clarke vs Jeamie TKV &#8211; 29 Nov 2025, Vaillant Live, Derby",
      },
    }),
    false,
  );
});
