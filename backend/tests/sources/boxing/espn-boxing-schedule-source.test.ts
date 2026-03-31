import test from "node:test";
import assert from "node:assert/strict";

import { parseEspnBoxingScheduleHtml } from "../../../src/sources/boxing/espn-boxing-schedule-source.js";

test("parseEspnBoxingScheduleHtml parses boxing event blocks and providers", () => {
  const html = `
    <h2>Full schedule:</h2>
    <h2>April</h2>
    <h3>April 4: London (DAZN)</h3>
    <ul>
      <li><p>Deontay Wilder vs. Derek Chisora, 12 rounds, heavyweights</p></li>
      <li><p>Viddal Riley vs. Mateusz Masternak, 12 rounds, cruiserweights</p></li>
    </ul>
    <h3>April 17: New York (ESPN)</h3>
    <ul>
      <li><p><b>Title fight:</b> Alycia Baumgardner vs. Bo Mi Re Shin, 12 rounds, junior lightweights</p></li>
    </ul>
  `;

  const parsed = parseEspnBoxingScheduleHtml(
    html,
    {
      timezone: "Europe/Amsterdam",
      selectedCountryCode: "NL",
    },
    "2026-03-30T12:00:00.000Z",
    2026,
  );

  assert.equal(parsed.reportedItemCount, 2);
  assert.equal(parsed.items.length, 2);
  assert.equal(parsed.items[0]?.title, "Deontay Wilder vs Derek Chisora");
  assert.equal(parsed.items[0]?.watchProviders[0]?.label, "DAZN");
  assert.equal(parsed.items[0]?.bouts.length, 2);
  assert.equal(parsed.items[1]?.title, "Alycia Baumgardner vs Bo Mi Re Shin");
  assert.equal(parsed.items[1]?.watchProviders[0]?.label, "ESPN");
  assert.equal(parsed.items[1]?.bouts[0]?.isMainEvent, true);
});
