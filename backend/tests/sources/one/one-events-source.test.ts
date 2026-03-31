import test from "node:test";
import assert from "node:assert/strict";

import { parseOneEventsHtml } from "../../../src/sources/one/one-events-source.js";

test("parseOneEventsHtml parses ONE upcoming event cards", () => {
  const html = `
    <div class="simple-post-card is-event is-image-zoom-area">
      <div class="image position-relative"></div>
      <div class="content">
        <div>
          <a class="title" href="https://www.onefc.com/events/onefightnight42/" title="ONE Fight Night 42: Mann vs. Dzhabrailov on Prime Video">
            <h3>ONE Fight Night 42: Mann vs. Dzhabrailov on Prime Video</h3>
          </a>
        </div>
        <div>
          <div class="datetime" data-timestamp="1775869200" data-pattern="M j (D) g:iA T"></div>
          <div class="location">Lumpinee Stadium, Bangkok</div>
        </div>
      </div>
    </div>
  `;

  const parsed = parseOneEventsHtml(
    html,
    {
      timezone: "Europe/Amsterdam",
      selectedCountryCode: "NL",
    },
    "2026-03-31T12:00:00.000Z",
  );

  assert.equal(parsed.reportedItemCount, 1);
  assert.equal(parsed.items.length, 1);
  assert.equal(parsed.items[0]?.organizationName, "ONE Championship");
  assert.equal(parsed.items[0]?.watchProviders[0]?.label, "Prime Video");
  assert.equal(parsed.items[0]?.bouts[0]?.fighterAName, "Mann");
  assert.equal(parsed.items[0]?.bouts[0]?.fighterBName, "Dzhabrailov");
});
