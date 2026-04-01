import test from "node:test";
import assert from "node:assert/strict";

import { buildApp, createInitialUserState } from "../src/app.js";
import { FileUserStateStore } from "../src/store/file-user-state-store.js";

test("createInitialUserState starts clean by default", () => {
  const state = createInitialUserState();

  assert.deepEqual(state.follows.fighterIds, []);
  assert.deepEqual(state.follows.eventIds, []);
  assert.deepEqual(state.alerts.fighters, {});
  assert.deepEqual(state.alerts.events, {});
});

test("createInitialUserState can still seed demo content explicitly", () => {
  const state = createInitialUserState({ seedDemoContent: true });

  assert.equal(state.follows.fighterIds.length > 0, true);
  assert.equal(state.follows.eventIds.length > 0, true);
});

test("app echoes request IDs on responses", async () => {
  const app = await buildApp({
    stateStore: new FileUserStateStore(createInitialUserState()),
  });

  try {
    const response = await app.inject({
      method: "GET",
      url: "/health",
      headers: {
        "x-request-id": "req_test_123",
      },
    });

    assert.equal(response.statusCode, 200);
    assert.equal(response.headers["x-request-id"], "req_test_123");
  } finally {
    await app.close();
  }
});
