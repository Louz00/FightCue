import test from "node:test";
import assert from "node:assert/strict";

import { loadGloryEventsPreview } from "../../../src/sources/glory/glory-events-source.js";

test("loadGloryEventsPreview parses official GLORY API events and watch providers", async (t) => {
  const originalFetch = globalThis.fetch;
  t.after(() => {
    globalThis.fetch = originalFetch;
  });

  globalThis.fetch = async (input: string | URL | Request) => {
    const url = String(input);
    assert.match(url, /glory-api\.pinkyellow\.computer/);

    return new Response(
      JSON.stringify({
        data: [
          {
            title: "GLORY 109: Rico vs Jamal",
            starts_at: "2026-05-09T18:00:00.000Z",
            venue: "Ahoy Rotterdam",
            city: "Rotterdam",
            country: { key: "NL", label: "Netherlands" },
            url: "/events/glory-109-rico-vs-jamal",
            youtube_prelims: "https://youtube.com/watch?v=prelims",
            fight_cards: [
              {
                title: "Rico Verhoeven vs Jamal Ben Saddik",
                weight_class: { title: "Heavyweight" },
                white_corner: { title: "Rico Verhoeven" },
                black_corner: { title: "Jamal Ben Saddik" },
              },
            ],
          },
        ],
        meta: { current_page: 1, last_page: 1 },
      }),
      { status: 200, headers: { "content-type": "application/json" } },
    );
  };

  const preview = await loadGloryEventsPreview({
    timezone: "Europe/Amsterdam",
    selectedCountryCode: "NL",
  });

  assert.equal(preview.mode, "live");
  assert.equal(preview.itemCount, 1);
  assert.equal(preview.items[0]?.organizationName, "GLORY");
  assert.equal(preview.items[0]?.bouts[0]?.fighterAName, "Rico Verhoeven");
  assert.equal(preview.items[0]?.watchProviders[0]?.label, "YouTube prelims");
});
