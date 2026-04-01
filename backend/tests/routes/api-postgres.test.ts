import test from "node:test";
import assert from "node:assert/strict";

import { newDb } from "pg-mem";

import { buildApp, createInitialUserState } from "../../src/app.js";
import { sampleUserProfile } from "../../src/domain/mock-data.js";
import { issueSignedDeviceToken } from "../../src/http/session-token.js";
import { RuntimeService } from "../../src/services/runtime-service.js";
import { createPostgresUserStateStore } from "../../src/store/user-state-store.js";

test("health and meta endpoints expose persistence backend information", async () => {
  const { app, close } = await createPostgresTestApp();

  try {
    const healthResponse = await app.inject({
      method: "GET",
      url: "/health",
    });
    assert.equal(healthResponse.statusCode, 200);
    assert.equal(healthResponse.json().persistenceBackend, "postgres");

    const metaResponse = await app.inject({
      method: "GET",
      url: "/v1/meta",
    });
    assert.equal(metaResponse.statusCode, 200);
    assert.equal(metaResponse.json().persistenceBackend, "postgres");

    const bootstrapResponse = await app.inject({
      method: "POST",
      url: "/v1/session/bootstrap",
      headers: {
        "x-fightcue-device-id": "Device Route Test",
      },
    });
    assert.equal(bootstrapResponse.statusCode, 200);
    assert.equal(bootstrapResponse.json().deviceId, "device_route_test");
    assert.equal(typeof bootstrapResponse.json().deviceToken, "string");
  } finally {
    await close();
  }
});

test("preferences, follows, and alerts persist through postgres-backed API routes", async () => {
  const { app, close } = await createPostgresTestApp();
  const headers = {
    "x-fightcue-device-id": "device_route_test",
  };

  try {
    const initialPreferences = await app.inject({
      method: "GET",
      url: "/v1/me/preferences",
      headers,
    });
    assert.equal(initialPreferences.statusCode, 200);
    assert.equal(initialPreferences.json().language, "en");

    const updatedPreferences = await app.inject({
      method: "PUT",
      url: "/v1/me/preferences",
      headers,
      payload: {
        language: "es",
        viewingCountryCode: "US",
      },
    });
    assert.equal(updatedPreferences.statusCode, 200);
    assert.equal(updatedPreferences.json().language, "es");
    assert.equal(updatedPreferences.json().viewingCountryCode, "US");

    const unfollowResponse = await app.inject({
      method: "PUT",
      url: "/v1/me/follows/fighters/ftr_alex_pereira",
      headers,
      payload: { followed: false },
    });
    assert.equal(unfollowResponse.statusCode, 200);
    assert.equal(unfollowResponse.json().item.isFollowed, false);

    const followResponse = await app.inject({
      method: "PUT",
      url: "/v1/me/follows/fighters/ftr_chris_duncan",
      headers,
      payload: { followed: true },
    });
    assert.equal(followResponse.statusCode, 200);
    assert.equal(followResponse.json().item.isFollowed, true);

    const alertResponse = await app.inject({
      method: "PUT",
      url: "/v1/me/alerts/fighters/ftr_chris_duncan",
      headers,
      payload: { presetKeys: ["before_24h", "time_changes"] },
    });
    assert.equal(alertResponse.statusCode, 200);
    assert.deepEqual(alertResponse.json().fighters.at(-1).presetKeys, [
      "before_24h",
      "time_changes",
    ]);

    const initialPush = await app.inject({
      method: "GET",
      url: "/v1/me/push",
      headers,
    });
    assert.equal(initialPush.statusCode, 200);
    assert.equal(initialPush.json().pushEnabled, false);
    assert.equal(initialPush.json().permissionStatus, "unknown");

    const initialMonetization = await app.inject({
      method: "GET",
      url: "/v1/me/monetization",
      headers,
    });
    assert.equal(initialMonetization.statusCode, 200);
    assert.equal(initialMonetization.json().premiumState, "free");
    assert.equal(initialMonetization.json().adConsentGranted, false);
    assert.equal(initialMonetization.json().quietAdsEnabled, false);

    const updatedMonetization = await app.inject({
      method: "PUT",
      url: "/v1/me/monetization/settings",
      headers,
      payload: {
        analyticsConsent: true,
        adConsentGranted: true,
      },
    });
    assert.equal(updatedMonetization.statusCode, 200);
    assert.equal(updatedMonetization.json().analyticsConsent, true);
    assert.equal(updatedMonetization.json().adConsentGranted, true);
    assert.equal(updatedMonetization.json().quietAdsEnabled, true);

    const updatedPushSettings = await app.inject({
      method: "PUT",
      url: "/v1/me/push/settings",
      headers,
      payload: {
        pushEnabled: true,
        permissionStatus: "prompt",
      },
    });
    assert.equal(updatedPushSettings.statusCode, 200);
    assert.equal(updatedPushSettings.json().pushEnabled, true);
    assert.equal(updatedPushSettings.json().permissionStatus, "prompt");
    assert.equal(updatedPushSettings.json().tokenRegistered, false);

    const registeredPushToken = await app.inject({
      method: "PUT",
      url: "/v1/me/push/token",
      headers,
      payload: {
        permissionStatus: "granted",
        tokenPlatform: "android",
        tokenValue: "fcm_token_demo",
      },
    });
    assert.equal(registeredPushToken.statusCode, 200);
    assert.equal(registeredPushToken.json().pushEnabled, true);
    assert.equal(registeredPushToken.json().permissionStatus, "granted");
    assert.equal(registeredPushToken.json().tokenPlatform, "android");
    assert.equal(registeredPushToken.json().tokenRegistered, true);
    assert.equal(typeof registeredPushToken.json().tokenUpdatedAt, "string");

    const fightersResponse = await app.inject({
      method: "GET",
      url: "/v1/me/fighters",
      headers,
    });
    assert.equal(fightersResponse.statusCode, 200);
    const fighterIds = fightersResponse.json().items.map((item: { id: string }) => item.id);
    assert.equal(fighterIds.includes("ftr_chris_duncan"), true);
    assert.equal(fighterIds.includes("ftr_alex_pereira"), false);

    const persistedPreferences = await app.inject({
      method: "GET",
      url: "/v1/me/preferences",
      headers,
    });
    assert.equal(persistedPreferences.statusCode, 200);
    assert.equal(persistedPreferences.json().language, "es");
    assert.equal(persistedPreferences.json().viewingCountryCode, "US");

    const persistedPush = await app.inject({
      method: "GET",
      url: "/v1/me/push",
      headers,
    });
    assert.equal(persistedPush.statusCode, 200);
    assert.equal(persistedPush.json().permissionStatus, "granted");
    assert.equal(persistedPush.json().tokenRegistered, true);

    const pushPreview = await app.inject({
      method: "GET",
      url: "/v1/me/push/preview",
      headers,
    });
    assert.equal(pushPreview.statusCode, 200);
    assert.equal(pushPreview.json().deliveryReadiness, "ready");
    assert.equal(pushPreview.json().scheduledCount >= 1, true);
    assert.equal(Array.isArray(pushPreview.json().items), true);

    const pushProvider = await app.inject({
      method: "GET",
      url: "/v1/me/push/provider",
      headers,
    });
    assert.equal(pushProvider.statusCode, 200);
    assert.equal(pushProvider.json().provider, "log");
    assert.equal(pushProvider.json().supportsDelivery, true);

    const pushTest = await app.inject({
      method: "POST",
      url: "/v1/me/push/test",
      headers,
    });
    assert.equal(pushTest.statusCode, 200);
    assert.equal(pushTest.json().dispatched, true);
    assert.equal(pushTest.json().provider, "log");
    assert.equal(typeof pushTest.json().providerMessageId, "string");

    const persistedMonetization = await app.inject({
      method: "GET",
      url: "/v1/me/monetization",
      headers,
    });
    assert.equal(persistedMonetization.statusCode, 200);
    assert.equal(persistedMonetization.json().analyticsConsent, true);
    assert.equal(persistedMonetization.json().adConsentGranted, true);
    assert.equal(persistedMonetization.json().quietAdsEnabled, true);
  } finally {
    await close();
  }
});

test("home endpoint deduplicates overlapping boxing cards and prioritizes richer official sources", async () => {
  const { app, close } = await createPostgresTestApp({
    configureRuntimeService(runtimeService) {
      runtimeService.getCachedEventPreview = async (source) => {
        switch (source) {
          case "top_rank":
            return buildBoxingPreview("top_rank", [
              createBoxingEvent({
                id: "evt_top_rank_zayas_ennis",
                organizationSlug: "top_rank",
                organizationName: "Top Rank",
                title: "Xander Zayas vs Jaron Ennis",
                scheduledStartUtc: "2026-06-27T16:00:00.000Z",
                fighterAName: "Xander Zayas",
                fighterBName: "Jaron Ennis",
              }),
            ]);
          case "pbc":
            return buildBoxingPreview("pbc", [
              createBoxingEvent({
                id: "evt_pbc_benavidez_zurdo",
                organizationSlug: "pbc",
                organizationName: "Premier Boxing Champions",
                title: "David Benavidez vs Gilberto Ramirez",
                scheduledStartUtc: "2026-05-02T00:00:00.000Z",
                fighterAName: "David Benavidez",
                fighterBName: "Gilberto Ramirez",
              }),
            ]);
          case "golden_boy":
            return buildBoxingPreview("golden_boy", [
              createBoxingEvent({
                id: "evt_golden_boy_benavidez_zurdo",
                organizationSlug: "golden_boy",
                organizationName: "Golden Boy",
                title: "David \"The Monster\" Benavidez vs Gilberto \"Zurdo\" Ramirez",
                scheduledStartUtc: "2026-05-02T03:00:00.000Z",
                fighterAName: "David \"The Monster\" Benavidez",
                fighterBName: "Gilberto \"Zurdo\" Ramirez",
              }),
            ]);
          case "espn_boxing":
            return buildBoxingPreview("espn_boxing", [
              createBoxingEvent({
                id: "evt_espn_benavidez_zurdo",
                organizationSlug: "espn_boxing",
                organizationName: "ESPN Boxing",
                title: "David Benavidez vs Gilberto Ramirez",
                scheduledStartUtc: "2026-05-02T12:00:00.000Z",
                fighterAName: "David Benavidez",
                fighterBName: "Gilberto Ramirez",
              }),
              createBoxingEvent({
                id: "evt_espn_wilder_chisora",
                organizationSlug: "espn_boxing",
                organizationName: "ESPN Boxing",
                title: "Deontay Wilder vs Derek Chisora",
                scheduledStartUtc: "2026-04-04T12:00:00.000Z",
                fighterAName: "Deontay Wilder",
                fighterBName: "Derek Chisora",
              }),
            ]);
          default:
            return createEmptyPreview(source);
        }
      };
    },
  });

  try {
    const response = await app.inject({
      method: "GET",
      url: "/v1/home",
      headers: {
        "x-fightcue-device-id": "boxing_dedup_route_test",
      },
    });

    assert.equal(response.statusCode, 200);
    const boxingEvents = response
      .json()
      .events.filter((event: { sport: string }) => event.sport === "boxing");

    assert.equal(boxingEvents.some((event: { id: string }) => event.id === "evt_top_rank_zayas_ennis"), true);
    assert.equal(
      boxingEvents.filter((event: { title: string }) => /Benavidez/i.test(event.title)).length,
      1,
    );
    assert.equal(
      boxingEvents.some((event: { organizationSlug: string }) => event.organizationSlug === "golden_boy"),
      false,
    );
    assert.equal(
      boxingEvents.some(
        (event: { organizationSlug: string; title: string }) =>
          event.organizationSlug === "pbc" && /Benavidez/i.test(event.title),
      ),
      true,
    );
    assert.equal(
      boxingEvents.some(
        (event: { organizationSlug: string; title: string }) =>
          event.organizationSlug === "espn_boxing" && /Benavidez/i.test(event.title),
      ),
      false,
    );
    assert.equal(
      boxingEvents.some(
        (event: { organizationSlug: string; title: string }) =>
          event.organizationSlug === "espn_boxing" && /Wilder/i.test(event.title),
      ),
      true,
    );
  } finally {
    await close();
  }
});

test("home endpoint reuses a short-lived runtime snapshot for repeated identical requests", async () => {
  let ufcCalls = 0;
  let topRankCalls = 0;

  const { app, close } = await createPostgresTestApp({
    configureRuntimeService(runtimeService) {
      runtimeService.getCachedEventPreview = async (source) => {
        if (source === "ufc") {
          ufcCalls += 1;
        }
        if (source === "top_rank") {
          topRankCalls += 1;
        }
        return createEmptyPreview(source);
      };
    },
  });

  try {
    const headers = {
      "x-fightcue-device-id": "runtime_cache_route_test",
    };

    const firstResponse = await app.inject({
      method: "GET",
      url: "/v1/home",
      headers,
    });
    const secondResponse = await app.inject({
      method: "GET",
      url: "/v1/home",
      headers,
    });

    assert.equal(firstResponse.statusCode, 200);
    assert.equal(secondResponse.statusCode, 200);
    assert.equal(ufcCalls, 1);
    assert.equal(topRankCalls, 1);
  } finally {
    await close();
  }
});

test("stateful routes reject invalid signed device tokens", async () => {
  const { app, close } = await createPostgresTestApp();

  try {
    const response = await app.inject({
      method: "GET",
      url: "/v1/home",
      headers: {
        "x-fightcue-device-id": "device_route_test",
        "x-fightcue-device-token": "invalid.token",
      },
    });

    assert.equal(response.statusCode, 401);
    assert.equal(response.json().error, "device_token_invalid");
  } finally {
    await close();
  }
});

test("strict signed-token mode rejects raw device-id fallback on stateful routes", async () => {
  const previous = process.env.FIGHTCUE_REQUIRE_SIGNED_DEVICE_TOKEN;
  process.env.FIGHTCUE_REQUIRE_SIGNED_DEVICE_TOKEN = "true";
  const { app, close } = await createPostgresTestApp();

  try {
    const response = await app.inject({
      method: "GET",
      url: "/v1/home",
      headers: {
        "x-fightcue-device-id": "device_route_test",
      },
    });

    assert.equal(response.statusCode, 401);
    assert.equal(response.json().error, "device_token_required");
  } finally {
    await close();
    restoreEnv("FIGHTCUE_REQUIRE_SIGNED_DEVICE_TOKEN", previous);
  }
});

test("strict signed-token mode accepts a valid token on stateful routes", async () => {
  const previous = process.env.FIGHTCUE_REQUIRE_SIGNED_DEVICE_TOKEN;
  process.env.FIGHTCUE_REQUIRE_SIGNED_DEVICE_TOKEN = "true";
  const { app, close } = await createPostgresTestApp();
  const deviceId = "device_route_test";

  try {
    const response = await app.inject({
      method: "GET",
      url: "/v1/home",
      headers: {
        "x-fightcue-device-id": deviceId,
        "x-fightcue-device-token": issueSignedDeviceToken(deviceId),
      },
    });

    assert.equal(response.statusCode, 200);
  } finally {
    await close();
    restoreEnv("FIGHTCUE_REQUIRE_SIGNED_DEVICE_TOKEN", previous);
  }
});

test("firebase push provider reports misconfiguration without crashing test sends", async () => {
  const previousProvider = process.env.FIGHTCUE_PUSH_PROVIDER;
  const previousInlineCredentials = process.env.FIGHTCUE_FIREBASE_SERVICE_ACCOUNT_JSON;
  const previousGoogleCredentials = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  const previousProjectId = process.env.FIGHTCUE_FIREBASE_PROJECT_ID;

  process.env.FIGHTCUE_PUSH_PROVIDER = "firebase";
  delete process.env.FIGHTCUE_FIREBASE_SERVICE_ACCOUNT_JSON;
  delete process.env.GOOGLE_APPLICATION_CREDENTIALS;
  process.env.FIGHTCUE_FIREBASE_PROJECT_ID = "fightcue-test";

  const { app, close } = await createPostgresTestApp();
  const headers = {
    "x-fightcue-device-id": "device_route_test",
  };

  try {
    await app.inject({
      method: "PUT",
      url: "/v1/me/push/token",
      headers,
      payload: {
        permissionStatus: "granted",
        tokenPlatform: "android",
        tokenValue: "fcm_token_demo",
      },
    });

    const pushProvider = await app.inject({
      method: "GET",
      url: "/v1/me/push/provider",
      headers,
    });
    assert.equal(pushProvider.statusCode, 200);
    assert.equal(pushProvider.json().provider, "firebase");
    assert.equal(pushProvider.json().configured, false);

    const pushTest = await app.inject({
      method: "POST",
      url: "/v1/me/push/test",
      headers,
    });
    assert.equal(pushTest.statusCode, 200);
    assert.equal(pushTest.json().provider, "firebase");
    assert.equal(pushTest.json().dispatched, false);
    assert.match(
      pushTest.json().message,
      /Firebase push delivery is not configured/i,
    );
  } finally {
    await close();
    if (previousProvider == null) {
      delete process.env.FIGHTCUE_PUSH_PROVIDER;
    } else {
      process.env.FIGHTCUE_PUSH_PROVIDER = previousProvider;
    }
    if (previousInlineCredentials == null) {
      delete process.env.FIGHTCUE_FIREBASE_SERVICE_ACCOUNT_JSON;
    } else {
      process.env.FIGHTCUE_FIREBASE_SERVICE_ACCOUNT_JSON = previousInlineCredentials;
    }
    if (previousGoogleCredentials == null) {
      delete process.env.GOOGLE_APPLICATION_CREDENTIALS;
    } else {
      process.env.GOOGLE_APPLICATION_CREDENTIALS = previousGoogleCredentials;
    }
    if (previousProjectId == null) {
      delete process.env.FIGHTCUE_FIREBASE_PROJECT_ID;
    } else {
      process.env.FIGHTCUE_FIREBASE_PROJECT_ID = previousProjectId;
    }
  }
});

async function createPostgresTestApp({
  configureRuntimeService,
}: {
  configureRuntimeService?: (runtimeService: RuntimeService) => void;
} = {}) {
  const db = newDb();
  const { Pool } = db.adapters.createPg();
  const pool = new Pool();
  const stateStore = await createPostgresUserStateStore(
    sampleUserProfile,
    createInitialUserState(),
    pool,
  );
  const runtimeService = createOfflineRuntimeService(stateStore);
  configureRuntimeService?.(runtimeService);
  const app = await buildApp({ stateStore, runtimeService });

  return {
    app,
    close: async () => {
      await app.close();
    },
  };
}

function createOfflineRuntimeService(
  stateStore: Awaited<ReturnType<typeof createPostgresUserStateStore>>,
) {
  const runtimeService = new RuntimeService(stateStore);
  runtimeService.getCachedEventPreview = async (source) => createEmptyPreview(source);

  return runtimeService;
}

function createEmptyPreview(source: string) {
  return {
    source,
    mode: "fallback" as const,
    officialUrl: `https://example.com/${source}`,
    timezone: "Europe/Amsterdam",
    selectedCountryCode: "NL",
    fetchedAt: "2026-03-30T00:00:00.000Z",
    itemCount: 0,
    health: {
      status: "fallback" as const,
      parsedItemCount: 0,
      checkedPageCount: 0,
      coverageGap: 0,
    },
    warnings: [`${source} disabled for route tests`],
    items: [],
  };
}

function buildBoxingPreview(source: string, items: ReturnType<typeof createBoxingEvent>[]) {
  return {
    source,
    mode: "live" as const,
    officialUrl: `https://example.com/${source}`,
    timezone: "Europe/Amsterdam",
    selectedCountryCode: "NL",
    fetchedAt: "2026-03-31T00:00:00.000Z",
    itemCount: items.length,
    health: {
      status: "healthy" as const,
      parsedItemCount: items.length,
      reportedItemCount: items.length,
      checkedPageCount: 1,
      coverageGap: 0,
      coverageRatio: 1,
    },
    warnings: [],
    items,
  };
}

function createBoxingEvent({
  id,
  organizationSlug,
  organizationName,
  title,
  scheduledStartUtc,
  fighterAName,
  fighterBName,
}: {
  id: string;
  organizationSlug: string;
  organizationName: string;
  title: string;
  scheduledStartUtc: string;
  fighterAName: string;
  fighterBName: string;
}) {
  return {
    id,
    organizationSlug,
    organizationName,
    sport: "boxing" as const,
    title,
    tagline: "test",
    locationLabel: "Test City",
    venueLabel: "Test Venue",
    scheduledStartUtc,
    scheduledTimezone: "UTC",
    localDateLabel: "Test Date",
    localTimeLabel: "TBA",
    eventLocalTimeLabel: "TBA",
    selectedCountryCode: "NL",
    status: "scheduled" as const,
    isFollowed: false,
    sourceLabel: "test",
    watchProviders: [],
    bouts: [
      {
        id: `bout_${id}`,
        slotLabel: "Main event",
        fighterAId: `ftr_${fighterAName}`,
        fighterAName,
        fighterBId: `ftr_${fighterBName}`,
        fighterBName,
        isMainEvent: true,
        includesFollowedFighter: false,
      },
    ],
  };
}

function restoreEnv(key: string, previous: string | undefined) {
  if (previous === undefined) {
    delete process.env[key];
    return;
  }

  process.env[key] = previous;
}
