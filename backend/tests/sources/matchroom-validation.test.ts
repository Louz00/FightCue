import test from "node:test";
import assert from "node:assert/strict";

import {
  buildMatchroomValidationWarnings,
  countMatchroomUpcomingCards,
} from "../../src/sources/matchroom/matchroom-validation.js";

test("countMatchroomUpcomingCards counts official fight-card blocks", () => {
  const html = `
    <h2>Upcoming</h2>
    <div class="events">
      <div class="fight-card">one</div>
      <div class="fight-card">two</div>
      <div class="fight-card">three</div>
    </div>
  `;

  assert.equal(countMatchroomUpcomingCards(html), 3);
});

test("buildMatchroomValidationWarnings reports coverage drift", () => {
  const warnings = buildMatchroomValidationWarnings({
    parsedItemCount: 6,
    reportedUpcomingCount: 8,
  });

  assert.equal(
    warnings.includes(
      "Matchroom source coverage is below the official card count (6/8).",
    ),
    true,
  );
});
