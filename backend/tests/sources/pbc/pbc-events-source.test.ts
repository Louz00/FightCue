import test from "node:test";
import assert from "node:assert/strict";

import {
  countPbcFightRows,
  parsePbcScheduleHtml,
} from "../../../src/sources/pbc/pbc-events-source.js";

test("parsePbcScheduleHtml parses PBC rows with provider and main bout", () => {
  const html = `
    <div class="fight-row">
      <h4 class="schedule-date"><span><abbr title="April">Apr</abbr></span> 17, 2026</h4>
      <span class="time">8 PM ET</span>
      <h5>LIVE ON Prime Video</h5>
      <li class="arena">MGM Grand, Las Vegas</li>
      <a href="https://watch.example/pbc">Watch Live on Prime Video<i class="fa fa-angle-right"></i></a>
      <a href="/fight-night/garcia-vs-cruz" class="regular-button white">View Fight Night</a>
      <span>Gervonta Davis</span><em><abbr title="versus">vs</abbr></em><span>Shakur Stevenson</span>
    </div>
  `;

  assert.equal(countPbcFightRows(html), 1);

  const items = parsePbcScheduleHtml(
    html,
    {
      timezone: "Europe/Amsterdam",
      selectedCountryCode: "NL",
    },
    "2026-04-01T08:00:00.000Z",
  );

  assert.equal(items.length, 1);
  assert.equal(items[0]?.title, "Gervonta Davis vs Shakur Stevenson");
  assert.equal(items[0]?.watchProviders[0]?.label, "Prime Video");
  assert.equal(
    items[0]?.officialUrl,
    "https://www.premierboxingchampions.com/fight-night/garcia-vs-cruz",
  );
});
