import test from "node:test";
import assert from "node:assert/strict";

import { parseRingRatingsHtml } from "../../../src/sources/boxing/ring-boxing-ratings-source.js";

test("parseRingRatingsHtml parses champion and ranked contenders", () => {
  const html = `
    <div class="text-md" role="heading" aria-level="3">CHAMPION – OLEKSANDR USYK</div>
    <div class="text-sm">RECORD<!-- -->: 24-0 (15 KOs)</div>
    <div class="text-md" role="heading" aria-level="3">No. 2 – JOSEPH PARKER</div>
    <div class="text-sm">RECORD<!-- -->: 36-3 (24 KOs)</div>
    <div class="text-md" role="heading" aria-level="3">No. 3 – AGIT KABAYEL</div>
    <div class="text-sm">RECORD<!-- -->: 26-0 (17 KOs)</div>
  `;

  const parsed = parseRingRatingsHtml(html, "Heavyweight");

  assert.ok(parsed);
  assert.equal(parsed?.organizationName, "The Ring");
  assert.equal(parsed?.entries.length, 3);
  assert.equal(parsed?.entries[0]?.fighterName, "OLEKSANDR USYK");
  assert.equal(parsed?.entries[0]?.rank, 0);
  assert.equal(parsed?.entries[0]?.isChampion, true);
  assert.equal(parsed?.entries[1]?.rank, 2);
  assert.equal(parsed?.entries[1]?.recordLabel, "36-3 (24 KOs)");
});
