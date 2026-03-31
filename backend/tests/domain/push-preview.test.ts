import test from "node:test";
import assert from "node:assert/strict";

import { buildRuntimePushPreview } from "../../src/domain/push-preview.js";
import type { PersistedUserState } from "../../src/store/user-state-store.js";

test("buildRuntimePushPreview schedules upcoming event and fighter reminders", () => {
  const state = createState({
    follows: {
      fighterIds: ["ftr_alex_pereira"],
      eventIds: ["evt_matchroom_taylor_serrano"],
    },
    alerts: {
      fighters: {
        ftr_alex_pereira: ["before_24h", "time_changes"],
      },
      events: {
        evt_matchroom_taylor_serrano: ["before_24h", "watch_updates"],
      },
    },
    push: {
      pushEnabled: true,
      permissionStatus: "granted",
      tokenPlatform: "ios",
      tokenValue: "apns_token_demo",
      tokenUpdatedAt: "2026-03-31T21:00:00.000Z",
    },
  });

  const preview = buildRuntimePushPreview(state, new Date("2026-03-31T12:00:00.000Z"));

  assert.equal(preview.deliveryReadiness, "ready");
  assert.equal(preview.scheduledCount >= 2, true);
  assert.equal(preview.signalCount >= 2, true);
  assert.equal(preview.items.some((item) => item.reason === "before_24h"), true);
  assert.equal(preview.items.some((item) => item.reason === "watch_updates"), true);
  assert.equal(preview.items.some((item) => item.reason === "time_changes"), true);
});

test("buildRuntimePushPreview reports token_missing when permission is granted without a token", () => {
  const state = createState({
    push: {
      pushEnabled: true,
      permissionStatus: "granted",
    },
  });

  const preview = buildRuntimePushPreview(state, new Date("2026-03-31T12:00:00.000Z"));

  assert.equal(preview.deliveryReadiness, "token_missing");
});

function createState(
  overrides: Partial<PersistedUserState>,
): PersistedUserState {
  return {
    profile: {
      userId: "usr_test_preview",
      language: "en",
      timezone: "Europe/Amsterdam",
      viewingCountryCode: "NL",
      premiumState: "free",
      analyticsConsent: false,
      adConsentGranted: false,
      ...overrides.profile,
    },
    follows: {
      fighterIds: [],
      eventIds: [],
      ...overrides.follows,
    },
    alerts: {
      fighters: {},
      events: {},
      ...overrides.alerts,
    },
    push: {
      pushEnabled: false,
      permissionStatus: "unknown",
      ...overrides.push,
    },
  };
}
