import test from "node:test";
import assert from "node:assert/strict";

import { loadQueensberryEventsPreview } from "../../../src/sources/queensberry/queensberry-events-source.js";

test("loadQueensberryEventsPreview parses hero cards and provider labels", async (t) => {
  const originalFetch = globalThis.fetch;
  t.after(() => {
    globalThis.fetch = originalFetch;
  });

  globalThis.fetch = async (input: string | URL | Request) => {
    const url = String(input);

    if (url === "https://queensberry.co.uk/pages/events") {
      return new Response(
        `
        <section class="custom-image-banner-section events-page-banner event-third-banner mob-page-banner-wrapper">
          <h2><span>Fabio</span> Wardley</h2>
          <h2><span>Daniel</span> Dubois</h2>
          <div class="banner-fight-events">
            <p>British Heavyweight Title</p>
            <h5>Tottenham Hotspur Stadium, London</h5>
            <h6>12 | 07 | 2026</h6>
            <div class="banner-second-button">
              <a href="https://queensberry.co.uk/blogs/events/wardley-vs-dubois">Event Info</a>
            </div>
          </div>
        </section>
        `,
        { status: 200, headers: { "content-type": "text/html" } },
      );
    }

    if (url === "https://queensberry.co.uk/blogs/events/wardley-vs-dubois") {
      return new Response(
        `
        <title>Fabio Wardley vs Daniel Dubois | DAZN PPV</title>
        <p>Watch live worldwide on DAZN PPV.</p>
        `,
        { status: 200, headers: { "content-type": "text/html" } },
      );
    }

    throw new Error(`Unexpected URL ${url}`);
  };

  const preview = await loadQueensberryEventsPreview({
    timezone: "Europe/Amsterdam",
    selectedCountryCode: "NL",
  });

  assert.equal(preview.mode, "live");
  assert.equal(preview.itemCount, 1);
  assert.equal(preview.items[0]?.title, "Fabio Wardley vs Daniel Dubois");
  assert.equal(preview.items[0]?.watchProviders[0]?.label, "DAZN PPV");
});
