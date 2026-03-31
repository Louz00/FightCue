import test from "node:test";
import assert from "node:assert/strict";

import { buildSourceHealth } from "../../src/sources/source-health.js";

test("buildSourceHealth marks live sources healthy when counts match", () => {
  const health = buildSourceHealth({
    mode: "live",
    parsedItemCount: 10,
    reportedItemCount: 10,
    checkedPageCount: 2,
  });

  assert.equal(health.status, "healthy");
  assert.equal(health.coverageGap, 0);
  assert.equal(health.coverageRatio, 1);
});

test("buildSourceHealth marks live sources degraded when parsed coverage is short", () => {
  const health = buildSourceHealth({
    mode: "live",
    parsedItemCount: 8,
    reportedItemCount: 10,
    checkedPageCount: 2,
  });

  assert.equal(health.status, "degraded");
  assert.equal(health.coverageGap, 2);
});

test("buildSourceHealth marks fallback sources explicitly", () => {
  const health = buildSourceHealth({
    mode: "fallback",
    parsedItemCount: 3,
    checkedPageCount: 0,
  });

  assert.equal(health.status, "fallback");
  assert.equal(health.coverageGap, 0);
});
