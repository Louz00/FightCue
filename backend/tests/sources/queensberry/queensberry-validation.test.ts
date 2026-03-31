import test from "node:test";
import assert from "node:assert/strict";

import {
  buildQueensberryValidationWarnings,
  countQueensberryHeroCards,
} from "../../../src/sources/queensberry/queensberry-validation.js";

test("countQueensberryHeroCards counts official hero banner cards", () => {
  const html = `
    <section class="custom-image-banner-section events-page-banner event-third-banner mob-page-banner-wrapper"></section>
    <section class="custom-image-banner-section events-page-banner event-third-banner mob-page-banner-wrapper"></section>
    <section class="custom-image-banner-section events-page-banner event-third-banner mob-page-banner-wrapper"></section>
  `;

  assert.equal(countQueensberryHeroCards(html), 3);
});

test("buildQueensberryValidationWarnings reports coverage drift", () => {
  const warnings = buildQueensberryValidationWarnings({
    parsedItemCount: 3,
    reportedUpcomingCount: 4,
  });

  assert.equal(
    warnings.includes(
      "Queensberry source coverage is below the official hero-card count (3/4).",
    ),
    true,
  );
});
