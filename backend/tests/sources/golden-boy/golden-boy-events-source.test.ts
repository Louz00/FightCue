import test from "node:test";
import assert from "node:assert/strict";

import { loadGoldenBoyEventsPreview } from "../../../src/sources/golden-boy/golden-boy-events-source.js";

test("loadGoldenBoyEventsPreview parses main hero event and detail metadata", async (t) => {
  const originalFetch = globalThis.fetch;
  t.after(() => {
    globalThis.fetch = originalFetch;
  });

  globalThis.fetch = async (input: string | URL | Request) => {
    const url = String(input);

    if (url === "https://www.goldenboy.com/events/") {
      return new Response(
        `
        <section class="bg-dark-grad pattern-overlay-4 hero">
          <h2 class="display-4 fw-normal text-white">May 9: Ryan Garcia vs. Isaac Cruz</h2>
          <p class="mb-4 display-7 text-white">Las Vegas | MGM Grand</p>
          <a class="btn btn-success" href="https://tickets.example/goldenboy">GET TICKETS</a>
          <a class="btn btn-light" href="https://dazn.com/garcia-cruz">WATCH ON DAZN</a>
          <a class="btn btn-primary" href="https://www.goldenboy.com/events/garcia-vs-cruz/">VIEW BOUTS</a>
        </section>
        `,
        { status: 200, headers: { "content-type": "text/html" } },
      );
    }

    if (url === "https://www.goldenboy.com/events/garcia-vs-cruz/") {
      return new Response(
        `
        <h5 class="text-white bout-fighter-name ">Ryan Garcia</h5>
        <h5 class="text-white blue-title bout-fighter-name">Isaac Cruz</h5>
        <div class="col-12 text-center mb-4 text-primary title-org">Golden Boy | Super Lightweight |</div>
        <div class="col-12 text-center text-primary bout-type"><span class="">DAZN |</span></div>
        `,
        { status: 200, headers: { "content-type": "text/html" } },
      );
    }

    throw new Error(`Unexpected URL ${url}`);
  };

  const preview = await loadGoldenBoyEventsPreview({
    timezone: "Europe/Amsterdam",
    selectedCountryCode: "NL",
  });

  assert.equal(preview.mode, "live");
  assert.equal(preview.itemCount, 1);
  assert.equal(preview.items[0]?.title, "Ryan Garcia vs Isaac Cruz");
  assert.equal(preview.items[0]?.watchProviders[0]?.label, "DAZN");
  assert.equal(preview.items[0]?.bouts[0]?.weightClass, "Super Lightweight");
});
