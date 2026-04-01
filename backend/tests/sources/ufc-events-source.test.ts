import test from "node:test";
import assert from "node:assert/strict";

import { loadUfcEventsPreview } from "../../src/sources/ufc/ufc-events-source.js";

test("loadUfcEventsPreview parses upcoming events and keeps ESPN validation quiet on match", async (t) => {
  const originalFetch = globalThis.fetch;
  t.after(() => {
    globalThis.fetch = originalFetch;
  });

  globalThis.fetch = async (input: string | URL | Request) => {
    const url = String(input);

    if (url === "https://www.ufc.com/events") {
      return new Response(
        `
        <section id="events-list-upcoming">
          <div class="althelete-total">1 Events</div>
          <div class="l-listing__item views-row">
            <div class="c-card-event--result__headline"><a href="/event/ufc-fight-night-moicano-duncan">UFC Fight Night: Moicano vs Duncan</a></div>
            <div data-main-card-timestamp="1775959200" data-main-card="Sat, Apr 5 / 8:00 PM EDT"></div>
            <div class="field--name-taxonomy-term-title"><h5>UFC APEX</h5></div>
            <p class="address"><span>Las Vegas</span><br />United States</p>
            <a href="https://www.espn.com/watch/ufc-fight-night">Watch on ESPN+</a>
            <div data-fight-card-name="Main Card" data-fight-label="Renato Moicano vs Chris Duncan"></div>
          </div>
        </section>
        `,
        { status: 200, headers: { "content-type": "text/html" } },
      );
    }

    if (url === "https://www.espn.com/mma/schedule/_/league/ufc") {
      return new Response(
        `
        <script>window['__espnfitt__']={"page":{"content":{"events":{"apr-2026":[{"name":"UFC Fight Night: Moicano vs. Duncan","date":"2026-04-05T00:00:00.000Z","broadcasts":[{"name":"ESPN+"}]}]}}}};</script>
        `,
        { status: 200, headers: { "content-type": "text/html" } },
      );
    }

    throw new Error(`Unexpected URL ${url}`);
  };

  const preview = await loadUfcEventsPreview({
    timezone: "Europe/Amsterdam",
    selectedCountryCode: "NL",
  });

  assert.equal(preview.mode, "live");
  assert.equal(preview.itemCount, 1);
  assert.equal(preview.items[0]?.title, "UFC Fight Night: Moicano vs Duncan");
  assert.equal(preview.items[0]?.watchProviders[0]?.label, "ESPN+");
  assert.equal(
    preview.warnings.some((warning) => warning.includes("missing from ESPN")),
    false,
  );
});
