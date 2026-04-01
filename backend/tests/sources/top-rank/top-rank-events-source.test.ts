import test from "node:test";
import assert from "node:assert/strict";

import { loadTopRankEventsPreview } from "../../../src/sources/top-rank/top-rank-events-source.js";

test("loadTopRankEventsPreview parses official Top Rank API payloads", async (t) => {
  const originalFetch = globalThis.fetch;
  t.after(() => {
    globalThis.fetch = originalFetch;
  });

  globalThis.fetch = async (input: string | URL | Request) => {
    const url = String(input);
    assert.match(url, /api\.toprank\.com/);

    return new Response(
      JSON.stringify({
        data: [
          {
            id: 101,
            slug: "zayas-vs-ennis",
            title: "Xander Zayas vs Jaron Ennis",
            type: "upcoming",
            start: "2026-06-14T00:00:00.000Z",
            location_address: "Madison Square Garden | New York, NY",
            online_streaming_link: "https://plus.espn.com/toprank/zayas-ennis",
            streaming_networks: [{ name: "ESPN+" }],
            is_show_exact_time: true,
            first_fighter: {
              full_name: "Xander Zayas",
              division: { name: "Super Welterweight" },
            },
            second_fighter: {
              full_name: "Jaron Ennis",
            },
          },
        ],
        meta: { total: 1 },
      }),
      { status: 200, headers: { "content-type": "application/json" } },
    );
  };

  const preview = await loadTopRankEventsPreview({
    timezone: "Europe/Amsterdam",
    selectedCountryCode: "NL",
  });

  assert.equal(preview.mode, "live");
  assert.equal(preview.itemCount, 1);
  assert.equal(preview.items[0]?.title, "Xander Zayas vs Jaron Ennis");
  assert.equal(preview.items[0]?.watchProviders[0]?.label, "ESPN+");
  assert.equal(preview.items[0]?.bouts[0]?.weightClass, "Super Welterweight");
});
