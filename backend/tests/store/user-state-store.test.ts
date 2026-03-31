import test from "node:test";
import assert from "node:assert/strict";

import { newDb } from "pg-mem";

import {
  createPostgresUserStateStore,
  createUserStateStore,
  type PersistedUserState,
} from "../../src/store/user-state-store.js";
import {
  sampleEvents,
  sampleFollowedFighters,
  sampleUserProfile,
} from "../../src/domain/mock-data.js";

const initialState = {
  profile: {
    language: sampleUserProfile.language,
    timezone: sampleUserProfile.timezone,
    viewingCountryCode: sampleUserProfile.viewingCountryCode,
    premiumState: sampleUserProfile.premiumState,
    analyticsConsent: sampleUserProfile.analyticsConsent,
    adConsentGranted: sampleUserProfile.adConsentGranted,
  },
  follows: {
    fighterIds: sampleFollowedFighters.map((fighter) => fighter.id),
    eventIds: sampleEvents.filter((event) => event.isFollowed).map((event) => event.id),
  },
  alerts: {
    fighters: {},
    events: {},
  },
} satisfies Omit<PersistedUserState, "profile"> & {
  profile: Omit<PersistedUserState["profile"], "userId">;
};

test("createUserStateStore fails fast when database is required but not configured", async () => {
  const originalDatabaseUrl = process.env.DATABASE_URL;
  const originalRequireDatabase = process.env.FIGHTCUE_REQUIRE_DATABASE;

  delete process.env.DATABASE_URL;
  process.env.FIGHTCUE_REQUIRE_DATABASE = "true";

  try {
    await assert.rejects(
      () => createUserStateStore(sampleUserProfile, initialState),
      /DATABASE_URL is not configured/,
    );
  } finally {
    if (originalDatabaseUrl === undefined) {
      delete process.env.DATABASE_URL;
    } else {
      process.env.DATABASE_URL = originalDatabaseUrl;
    }

    if (originalRequireDatabase === undefined) {
      delete process.env.FIGHTCUE_REQUIRE_DATABASE;
    } else {
      process.env.FIGHTCUE_REQUIRE_DATABASE = originalRequireDatabase;
    }
  }
});

test("postgres user state store persists preferences, follows, and alerts per device", async () => {
  const db = newDb();
  const { Pool } = db.adapters.createPg();
  const pool = new Pool();
  const store = await createPostgresUserStateStore(sampleUserProfile, initialState, pool);

  try {
    const initial = await store.read("device_alpha");
    assert.equal(initial.profile.userId, "usr_device_alpha");
    assert.equal(initial.profile.language, "en");
    assert.equal(initial.follows.fighterIds.includes("ftr_alex_pereira"), true);

    await store.updateProfile("device_alpha", {
      language: "nl",
      viewingCountryCode: "GB",
    });
    await store.setFollow("device_alpha", "fighter", "ftr_chris_duncan", true);
    await store.setFollow("device_alpha", "event", "evt_glory_107", true);
    await store.updateAlertPresets("device_alpha", "fighter", "ftr_chris_duncan", [
      "before_1h",
      "time_changes",
    ]);

    const updated = await store.read("device_alpha");
    assert.equal(updated.profile.language, "nl");
    assert.equal(updated.profile.viewingCountryCode, "GB");
    assert.equal(updated.follows.fighterIds.includes("ftr_chris_duncan"), true);
    assert.equal(updated.follows.eventIds.includes("evt_glory_107"), true);
    assert.deepEqual(updated.alerts.fighters.ftr_chris_duncan, [
      "before_1h",
      "time_changes",
    ]);

    const secondDevice = await store.read("device_beta");
    assert.equal(secondDevice.profile.userId, "usr_device_beta");
    assert.equal(secondDevice.profile.language, "en");
    assert.equal(secondDevice.follows.fighterIds.includes("ftr_chris_duncan"), false);
  } finally {
    await store.close?.();
  }
});
