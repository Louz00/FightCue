import { mkdir, readFile, readdir, writeFile } from "node:fs/promises";
import path from "node:path";

import { Pool, type PoolClient } from "pg";

import { isDatabaseRequired, isFileStateFallbackAllowed } from "../config/persistence.js";
import { runSchemaMigrations } from "../db/migrations.js";
import { logWarn } from "../observability/logger.js";
import type {
  AlertPresetKey,
  PremiumState,
  PushPermissionStatus,
  PushTokenPlatform,
  SupportedLanguage,
  UserProfile,
} from "../domain/models.js";

export type PersistedUserState = {
  profile: {
    userId: string;
    language: SupportedLanguage;
    timezone: string;
    viewingCountryCode: string;
    premiumState: PremiumState;
    analyticsConsent: boolean;
    adConsentGranted: boolean;
  };
  follows: {
    fighterIds: string[];
    eventIds: string[];
  };
  alerts: {
    fighters: Record<string, AlertPresetKey[]>;
    events: Record<string, AlertPresetKey[]>;
  };
  push: {
    pushEnabled: boolean;
    permissionStatus: PushPermissionStatus;
    tokenPlatform?: PushTokenPlatform;
    tokenValue?: string;
    tokenUpdatedAt?: string;
  };
};

export interface UserStateStore {
  readonly backendLabel: "file" | "postgres";
  read(deviceId?: string): Promise<PersistedUserState>;
  listPushReadyDeviceIds(): Promise<string[]>;
  updateProfile(
    deviceId: string,
    updates: Partial<PersistedUserState["profile"]>,
  ): Promise<PersistedUserState>;
  setFollow(
    deviceId: string,
    target: "fighter" | "event",
    targetId: string,
    followed: boolean,
  ): Promise<PersistedUserState>;
  updateAlertPresets(
    deviceId: string,
    target: "fighter" | "event",
    targetId: string,
    presetKeys: AlertPresetKey[],
  ): Promise<PersistedUserState>;
  updatePushSettings(
    deviceId: string,
    updates: Partial<PersistedUserState["push"]>,
  ): Promise<PersistedUserState>;
  close?(): Promise<void>;
}

export async function createUserStateStore(
  baseProfile: UserProfile,
  initialState: Omit<PersistedUserState, "profile"> & {
    profile: Omit<PersistedUserState["profile"], "userId">;
  },
): Promise<UserStateStore> {
  const connectionString = process.env.DATABASE_URL ?? process.env.FIGHTCUE_DATABASE_URL;
  const requireDatabase = isDatabaseRequired();
  const allowFileFallback = isFileStateFallbackAllowed();

  if (!connectionString) {
    if (requireDatabase) {
      throw new Error(
        "FIGHTCUE_REQUIRE_DATABASE is true, but DATABASE_URL is not configured.",
      );
    }
    return new FileUserStateStore(baseProfile, initialState);
  }

  try {
    return await createPostgresUserStateStore(
      baseProfile,
      initialState,
      connectionString,
    );
  } catch (error) {
    if (requireDatabase || !allowFileFallback) {
      throw error;
    }
    logWarn("persistence.fallback_to_file", {
      backend: "postgres",
      fallbackBackend: "file",
      reason: getErrorMessage(error),
    });
    return new FileUserStateStore(baseProfile, initialState);
  }
}

class FileUserStateStore implements UserStateStore {
  constructor(
    private readonly baseProfile: UserProfile,
    private readonly initialState: Omit<PersistedUserState, "profile"> & {
      profile: Omit<PersistedUserState["profile"], "userId">;
    },
  ) {}

  readonly backendLabel = "file" as const;
  private writeQueue = Promise.resolve();

  async read(deviceId = "device_demo_local"): Promise<PersistedUserState> {
    const seededState = seedStateForDevice(deviceId, this.initialState);

    try {
      const raw = await readFile(this.filePathFor(deviceId), "utf8");
      const parsed = JSON.parse(raw) as Partial<PersistedUserState>;

      return {
        profile: {
          userId: parsed.profile?.userId ?? seededState.profile.userId,
          language: parsed.profile?.language ?? seededState.profile.language,
          timezone: parsed.profile?.timezone ?? seededState.profile.timezone,
          viewingCountryCode:
            parsed.profile?.viewingCountryCode ?? seededState.profile.viewingCountryCode,
          premiumState: parsed.profile?.premiumState ?? seededState.profile.premiumState,
          analyticsConsent:
            parsed.profile?.analyticsConsent ?? seededState.profile.analyticsConsent,
          adConsentGranted:
            parsed.profile?.adConsentGranted ?? seededState.profile.adConsentGranted,
        },
        follows: {
          fighterIds: parsed.follows?.fighterIds ?? seededState.follows.fighterIds,
          eventIds: parsed.follows?.eventIds ?? seededState.follows.eventIds,
        },
        alerts: {
          fighters: parsed.alerts?.fighters ?? seededState.alerts.fighters,
          events: parsed.alerts?.events ?? seededState.alerts.events,
        },
        push: {
          pushEnabled: parsed.push?.pushEnabled ?? seededState.push.pushEnabled,
          permissionStatus:
            parsed.push?.permissionStatus ?? seededState.push.permissionStatus,
          tokenPlatform: parsed.push?.tokenPlatform ?? seededState.push.tokenPlatform,
          tokenValue: parsed.push?.tokenValue ?? seededState.push.tokenValue,
          tokenUpdatedAt:
            parsed.push?.tokenUpdatedAt ?? seededState.push.tokenUpdatedAt,
        },
      };
    } catch {
      await this.write(deviceId, seededState);
      return structuredClone(seededState);
    }
  }

  async updateProfile(
    deviceId: string,
    updates: Partial<PersistedUserState["profile"]>,
  ): Promise<PersistedUserState> {
    return this.enqueue(async () => {
      const current = await this.read(deviceId);
      const next: PersistedUserState = {
        ...current,
        profile: {
          ...current.profile,
          ...updates,
          userId: current.profile.userId,
        },
      };
      await this.write(deviceId, next);
      return next;
    });
  }

  async setFollow(
    deviceId: string,
    target: "fighter" | "event",
    targetId: string,
    followed: boolean,
  ): Promise<PersistedUserState> {
    return this.enqueue(async () => {
      const current = await this.read(deviceId);
      const key = target === "fighter" ? "fighterIds" : "eventIds";
      const set = new Set(current.follows[key]);

      if (followed) {
        set.add(targetId);
      } else {
        set.delete(targetId);
      }

      const next: PersistedUserState = {
        ...current,
        follows: {
          ...current.follows,
          [key]: [...set],
        },
      };

      await this.write(deviceId, next);
      return next;
    });
  }

  async updateAlertPresets(
    deviceId: string,
    target: "fighter" | "event",
    targetId: string,
    presetKeys: AlertPresetKey[],
  ): Promise<PersistedUserState> {
    return this.enqueue(async () => {
      const current = await this.read(deviceId);
      const key = target === "fighter" ? "fighters" : "events";
      const next: PersistedUserState = {
        ...current,
        alerts: {
          ...current.alerts,
          [key]: {
            ...current.alerts[key],
            [targetId]: [...new Set(presetKeys)],
          },
        },
      };

      await this.write(deviceId, next);
      return next;
    });
  }

  async updatePushSettings(
    deviceId: string,
    updates: Partial<PersistedUserState["push"]>,
  ): Promise<PersistedUserState> {
    return this.enqueue(async () => {
      const current = await this.read(deviceId);
      const next: PersistedUserState = {
        ...current,
        push: {
          ...current.push,
          ...updates,
          tokenUpdatedAt:
            updates.tokenValue == null && updates.tokenUpdatedAt == null
              ? current.push.tokenUpdatedAt
              : updates.tokenUpdatedAt ??
                new Date().toISOString(),
        },
      };

      if (!next.push.tokenValue) {
        next.push.tokenPlatform = undefined;
        next.push.tokenUpdatedAt = undefined;
      }

      await this.write(deviceId, next);
      return next;
    });
  }

  async listPushReadyDeviceIds(): Promise<string[]> {
    const usersDirectory = path.resolve(process.cwd(), ".data", "users");
    let entries: string[] = [];

    try {
      entries = await readdir(usersDirectory);
    } catch {
      return [];
    }

    const deviceIds: string[] = [];
    for (const entry of entries) {
      if (!entry.endsWith(".json")) {
        continue;
      }
      const deviceId = entry.replace(/\.json$/u, "");
      const state = await this.read(deviceId);
      if (
        state.push.pushEnabled &&
        state.push.permissionStatus === "granted" &&
        state.push.tokenValue
      ) {
        deviceIds.push(deviceId);
      }
    }

    return deviceIds;
  }

  private async write(deviceId: string, state: PersistedUserState): Promise<void> {
    const filePath = this.filePathFor(deviceId);
    await mkdir(path.dirname(filePath), { recursive: true });
    await writeFile(filePath, JSON.stringify(state, null, 2), "utf8");
  }

  private async enqueue<T>(task: () => Promise<T>): Promise<T> {
    const result = this.writeQueue.then(task);
    this.writeQueue = result.then(
      () => undefined,
      () => undefined,
    );
    return result;
  }

  private filePathFor(deviceId: string): string {
    const safeDeviceId = sanitizeDeviceId(deviceId);
    return path.resolve(process.cwd(), ".data", "users", `${safeDeviceId}.json`);
  }
}

export async function createPostgresUserStateStore(
  baseProfile: UserProfile,
  initialState: Omit<PersistedUserState, "profile"> & {
    profile: Omit<PersistedUserState["profile"], "userId">;
  },
  connection: string | Pool,
): Promise<UserStateStore> {
  const pool = typeof connection === "string" ? new Pool({ connectionString: connection }) : connection;
  await runSchemaMigrations(pool);
  return new PostgresUserStateStore(pool, baseProfile, initialState);
}

class PostgresUserStateStore implements UserStateStore {
  constructor(
    private readonly pool: Pool,
    private readonly baseProfile: UserProfile,
    private readonly initialState: Omit<PersistedUserState, "profile"> & {
      profile: Omit<PersistedUserState["profile"], "userId">;
    },
  ) {}

  readonly backendLabel = "postgres" as const;

  async read(deviceId = "device_demo_local"): Promise<PersistedUserState> {
    return this.withUserTransaction(deviceId, async (client, userId) => {
      const preferencesResult = await client.query<{
        language: SupportedLanguage;
        timezone: string;
        viewing_country_code: string;
        premium_state: PremiumState;
        analytics_consent: boolean;
        ad_consent_granted: boolean;
      }>(
        `SELECT language, timezone, viewing_country_code, premium_state,
                analytics_consent, ad_consent_granted
           FROM user_preferences
          WHERE user_id = $1`,
        [userId],
      );

      const followRows = await client.query<{
        target: "fighter" | "event";
        target_id: string;
      }>(
        `SELECT target, target_id
           FROM user_follows
          WHERE user_id = $1`,
        [userId],
      );

      const alertRows = await client.query<{
        target: "fighter" | "event";
        target_id: string;
        preset_key: AlertPresetKey;
      }>(
        `SELECT target, target_id, preset_key
           FROM user_alert_presets
          WHERE user_id = $1
       ORDER BY target, target_id, preset_key`,
        [userId],
      );

      const pushResult = await client.query<{
        push_enabled: boolean;
        permission_status: PushPermissionStatus;
        token_platform: PushTokenPlatform | null;
        token_value: string | null;
        token_updated_at: Date | string | null;
      }>(
        `SELECT push_enabled, permission_status, token_platform, token_value, token_updated_at
           FROM user_push_devices
          WHERE user_id = $1`,
        [userId],
      );

      const preferences = preferencesResult.rows[0];
      const push = pushResult.rows[0];
      const state = seedStateForDevice(deviceId, this.initialState);
      const fighters: string[] = [];
      const events: string[] = [];

      for (const row of followRows.rows) {
        if (row.target === "fighter") {
          fighters.push(row.target_id);
        } else {
          events.push(row.target_id);
        }
      }

      const fighterAlerts: Record<string, AlertPresetKey[]> = {};
      const eventAlerts: Record<string, AlertPresetKey[]> = {};

      for (const row of alertRows.rows) {
        const targetMap = row.target === "fighter" ? fighterAlerts : eventAlerts;
        targetMap[row.target_id] ??= [];
        targetMap[row.target_id].push(row.preset_key);
      }

      return {
        profile: {
          userId,
          language: preferences?.language ?? state.profile.language,
          timezone: preferences?.timezone ?? state.profile.timezone,
          viewingCountryCode:
            preferences?.viewing_country_code ?? state.profile.viewingCountryCode,
          premiumState: preferences?.premium_state ?? state.profile.premiumState,
          analyticsConsent:
            preferences?.analytics_consent ?? state.profile.analyticsConsent,
          adConsentGranted:
            preferences?.ad_consent_granted ?? state.profile.adConsentGranted,
        },
        follows: {
          fighterIds: fighters,
          eventIds: events,
        },
        alerts: {
          fighters: fighterAlerts,
          events: eventAlerts,
        },
        push: {
          pushEnabled: push?.push_enabled ?? state.push.pushEnabled,
          permissionStatus:
            push?.permission_status ?? state.push.permissionStatus,
          tokenPlatform: push?.token_platform ?? state.push.tokenPlatform,
          tokenValue: push?.token_value ?? state.push.tokenValue,
          tokenUpdatedAt: toIsoTimestamp(push?.token_updated_at) ?? state.push.tokenUpdatedAt,
        },
      };
    });
  }

  async updateProfile(
    deviceId: string,
    updates: Partial<PersistedUserState["profile"]>,
  ): Promise<PersistedUserState> {
    return this.withUserTransaction(deviceId, async (client, userId) => {
      await client.query(
        `UPDATE user_preferences
            SET language = COALESCE($2, language),
                timezone = COALESCE($3, timezone),
                viewing_country_code = COALESCE($4, viewing_country_code),
                premium_state = COALESCE($5, premium_state),
                analytics_consent = COALESCE($6, analytics_consent),
                ad_consent_granted = COALESCE($7, ad_consent_granted),
                updated_at = NOW()
          WHERE user_id = $1`,
        [
          userId,
          updates.language ?? null,
          updates.timezone ?? null,
          updates.viewingCountryCode ?? null,
          updates.premiumState ?? null,
          updates.analyticsConsent ?? null,
          updates.adConsentGranted ?? null,
        ],
      );

      return this.readForUser(client, userId);
    });
  }

  async setFollow(
    deviceId: string,
    target: "fighter" | "event",
    targetId: string,
    followed: boolean,
  ): Promise<PersistedUserState> {
    return this.withUserTransaction(deviceId, async (client, userId) => {
      if (followed) {
        await client.query(
          `INSERT INTO user_follows (user_id, target, target_id)
                VALUES ($1, $2, $3)
          ON CONFLICT (user_id, target, target_id) DO NOTHING`,
          [userId, target, targetId],
        );
      } else {
        await client.query(
          `DELETE FROM user_follows
            WHERE user_id = $1
              AND target = $2
              AND target_id = $3`,
          [userId, target, targetId],
        );
      }

      return this.readForUser(client, userId);
    });
  }

  async updateAlertPresets(
    deviceId: string,
    target: "fighter" | "event",
    targetId: string,
    presetKeys: AlertPresetKey[],
  ): Promise<PersistedUserState> {
    return this.withUserTransaction(deviceId, async (client, userId) => {
      await client.query(
        `DELETE FROM user_alert_presets
          WHERE user_id = $1
            AND target = $2
            AND target_id = $3`,
        [userId, target, targetId],
      );

      for (const presetKey of [...new Set(presetKeys)]) {
        await client.query(
          `INSERT INTO user_alert_presets (user_id, target, target_id, preset_key)
                VALUES ($1, $2, $3, $4)`,
          [userId, target, targetId, presetKey],
        );
      }

      return this.readForUser(client, userId);
    });
  }

  async updatePushSettings(
    deviceId: string,
    updates: Partial<PersistedUserState["push"]>,
  ): Promise<PersistedUserState> {
    return this.withUserTransaction(deviceId, async (client, userId) => {
      const current = await this.readForUser(client, userId);
      const nextPush = {
        ...current.push,
        ...updates,
      };

      if (!nextPush.tokenValue) {
        nextPush.tokenPlatform = undefined;
        nextPush.tokenUpdatedAt = undefined;
      } else if (updates.tokenValue != null || updates.tokenUpdatedAt != null) {
        nextPush.tokenUpdatedAt = updates.tokenUpdatedAt ?? new Date().toISOString();
      }

      await client.query(
        `INSERT INTO user_push_devices (
           user_id,
           push_enabled,
           permission_status,
           token_platform,
           token_value,
           token_updated_at
         )
         VALUES ($1, $2, $3, $4, $5, $6)
         ON CONFLICT (user_id) DO UPDATE
             SET push_enabled = COALESCE($2, user_push_devices.push_enabled),
                 permission_status = COALESCE($3, user_push_devices.permission_status),
                 token_platform = $4,
                 token_value = $5,
                 token_updated_at = $6,
                 updated_at = NOW()`,
        [
          userId,
          nextPush.pushEnabled,
          nextPush.permissionStatus,
          nextPush.tokenPlatform ?? null,
          nextPush.tokenValue ?? null,
          nextPush.tokenUpdatedAt ?? null,
        ],
      );

      return this.readForUser(client, userId);
    });
  }

  async listPushReadyDeviceIds(): Promise<string[]> {
    const result = await this.pool.query<{ device_id: string }>(
      `SELECT users.device_id
         FROM users
         JOIN user_push_devices ON user_push_devices.user_id = users.user_id
        WHERE user_push_devices.push_enabled = TRUE
          AND user_push_devices.permission_status = 'granted'
          AND user_push_devices.token_value IS NOT NULL
          AND user_push_devices.token_value <> ''`,
    );

    return result.rows.map((row) => row.device_id);
  }

  async close(): Promise<void> {
    await this.pool.end();
  }

  private async withUserTransaction<T>(
    deviceId: string,
    task: (client: PoolClient, userId: string) => Promise<T>,
  ): Promise<T> {
    const client = await this.pool.connect();

    try {
      await client.query("BEGIN");
      const userId = await this.ensureUserInitialized(client, deviceId);
      const result = await task(client, userId);
      await client.query("COMMIT");
      return result;
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  }

  private async ensureUserInitialized(
    client: PoolClient,
    deviceId: string,
  ): Promise<string> {
    const seededState = seedStateForDevice(deviceId, this.initialState);
    const preferredUserId = seededState.profile.userId;
    const safeDeviceId = sanitizeDeviceId(deviceId);
    const existingUserResult = await client.query<{ user_id: string }>(
      `SELECT user_id
         FROM users
        WHERE device_id = $1`,
      [safeDeviceId],
    );

    if (existingUserResult.rows[0]?.user_id) {
      const userId = existingUserResult.rows[0].user_id;

      await client.query(
        `UPDATE users
            SET last_seen_at = NOW()
          WHERE user_id = $1`,
        [userId],
      );

      return userId;
    }

    await client.query(
      `INSERT INTO users (user_id, device_id, is_anonymous)
            VALUES ($1, $2, TRUE)`,
      [preferredUserId, safeDeviceId],
    );
    const userId = preferredUserId;

    await client.query(
      `INSERT INTO user_preferences (
         user_id,
         language,
         timezone,
         viewing_country_code,
         premium_state,
         analytics_consent,
         ad_consent_granted
       )
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       ON CONFLICT (user_id) DO NOTHING`,
      [
        userId,
        seededState.profile.language,
        seededState.profile.timezone,
        seededState.profile.viewingCountryCode,
        seededState.profile.premiumState,
        seededState.profile.analyticsConsent,
        seededState.profile.adConsentGranted,
      ],
    );

    await client.query(
      `INSERT INTO user_push_devices (
         user_id,
         push_enabled,
         permission_status,
         token_platform,
         token_value,
         token_updated_at
       )
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (user_id) DO NOTHING`,
      [
        userId,
        seededState.push.pushEnabled,
        seededState.push.permissionStatus,
        seededState.push.tokenPlatform ?? null,
        seededState.push.tokenValue ?? null,
        seededState.push.tokenUpdatedAt ?? null,
      ],
    );

    for (const fighterId of seededState.follows.fighterIds) {
      await client.query(
        `INSERT INTO user_follows (user_id, target, target_id)
              VALUES ($1, 'fighter', $2)
        ON CONFLICT (user_id, target, target_id) DO NOTHING`,
        [userId, fighterId],
      );
    }

    for (const eventId of seededState.follows.eventIds) {
      await client.query(
        `INSERT INTO user_follows (user_id, target, target_id)
              VALUES ($1, 'event', $2)
        ON CONFLICT (user_id, target, target_id) DO NOTHING`,
        [userId, eventId],
      );
    }

    for (const [fighterId, presetKeys] of Object.entries(seededState.alerts.fighters)) {
      for (const presetKey of [...new Set(presetKeys)]) {
        await client.query(
          `INSERT INTO user_alert_presets (user_id, target, target_id, preset_key)
                VALUES ($1, 'fighter', $2, $3)
          ON CONFLICT (user_id, target, target_id, preset_key) DO NOTHING`,
          [userId, fighterId, presetKey],
        );
      }
    }

    for (const [eventId, presetKeys] of Object.entries(seededState.alerts.events)) {
      for (const presetKey of [...new Set(presetKeys)]) {
        await client.query(
          `INSERT INTO user_alert_presets (user_id, target, target_id, preset_key)
                VALUES ($1, 'event', $2, $3)
          ON CONFLICT (user_id, target, target_id, preset_key) DO NOTHING`,
          [userId, eventId, presetKey],
        );
      }
    }

    return userId;
  }

  private async readForUser(
    client: PoolClient,
    userId: string,
  ): Promise<PersistedUserState> {
    const deviceResult = await client.query<{ device_id: string }>(
      `SELECT device_id FROM users WHERE user_id = $1`,
      [userId],
    );
    const deviceId = deviceResult.rows[0]?.device_id ?? "device_demo_local";
    const seededState = seedStateForDevice(deviceId, this.initialState);

    const preferencesResult = await client.query<{
      language: SupportedLanguage;
      timezone: string;
      viewing_country_code: string;
      premium_state: PremiumState;
      analytics_consent: boolean;
      ad_consent_granted: boolean;
    }>(
      `SELECT language, timezone, viewing_country_code, premium_state,
              analytics_consent, ad_consent_granted
         FROM user_preferences
        WHERE user_id = $1`,
      [userId],
    );

    const followsResult = await client.query<{
      target: "fighter" | "event";
      target_id: string;
    }>(
      `SELECT target, target_id
         FROM user_follows
        WHERE user_id = $1`,
      [userId],
    );

    const alertRows = await client.query<{
      target: "fighter" | "event";
      target_id: string;
      preset_key: AlertPresetKey;
    }>(
      `SELECT target, target_id, preset_key
         FROM user_alert_presets
        WHERE user_id = $1
     ORDER BY target, target_id, preset_key`,
      [userId],
    );

    const pushResult = await client.query<{
      push_enabled: boolean;
      permission_status: PushPermissionStatus;
      token_platform: PushTokenPlatform | null;
      token_value: string | null;
      token_updated_at: Date | string | null;
    }>(
      `SELECT push_enabled, permission_status, token_platform, token_value, token_updated_at
         FROM user_push_devices
        WHERE user_id = $1`,
      [userId],
    );

    const fighterIds: string[] = [];
    const eventIds: string[] = [];
    for (const row of followsResult.rows) {
      if (row.target === "fighter") {
        fighterIds.push(row.target_id);
      } else {
        eventIds.push(row.target_id);
      }
    }

    const fighterAlerts: Record<string, AlertPresetKey[]> = {};
    const eventAlerts: Record<string, AlertPresetKey[]> = {};
    for (const row of alertRows.rows) {
      const targetMap = row.target === "fighter" ? fighterAlerts : eventAlerts;
      targetMap[row.target_id] ??= [];
      targetMap[row.target_id].push(row.preset_key);
    }

    const preferences = preferencesResult.rows[0];
    const push = pushResult.rows[0];

    return {
      profile: {
        userId,
        language: preferences?.language ?? seededState.profile.language,
        timezone: preferences?.timezone ?? seededState.profile.timezone,
        viewingCountryCode:
          preferences?.viewing_country_code ?? seededState.profile.viewingCountryCode,
        premiumState: preferences?.premium_state ?? seededState.profile.premiumState,
        analyticsConsent:
          preferences?.analytics_consent ?? seededState.profile.analyticsConsent,
        adConsentGranted:
          preferences?.ad_consent_granted ?? seededState.profile.adConsentGranted,
      },
      follows: {
        fighterIds,
        eventIds,
      },
      alerts: {
        fighters: fighterAlerts,
        events: eventAlerts,
      },
      push: {
        pushEnabled: push?.push_enabled ?? seededState.push.pushEnabled,
        permissionStatus: push?.permission_status ?? seededState.push.permissionStatus,
        tokenPlatform: push?.token_platform ?? seededState.push.tokenPlatform,
        tokenValue: push?.token_value ?? seededState.push.tokenValue,
        tokenUpdatedAt: toIsoTimestamp(push?.token_updated_at) ?? seededState.push.tokenUpdatedAt,
      },
    };
  }
}

function seedStateForDevice(
  deviceId: string,
  initialState: Omit<PersistedUserState, "profile"> & {
    profile: Omit<PersistedUserState["profile"], "userId">;
  },
): PersistedUserState {
  return {
    profile: {
      userId: buildUserIdForDevice(deviceId),
      language: initialState.profile.language,
      timezone: initialState.profile.timezone,
      viewingCountryCode: initialState.profile.viewingCountryCode,
      premiumState: initialState.profile.premiumState,
      analyticsConsent: initialState.profile.analyticsConsent,
      adConsentGranted: initialState.profile.adConsentGranted,
    },
    follows: {
      fighterIds: [...initialState.follows.fighterIds],
      eventIds: [...initialState.follows.eventIds],
    },
    alerts: {
      fighters: structuredClone(initialState.alerts.fighters),
      events: structuredClone(initialState.alerts.events),
    },
    push: {
      pushEnabled: initialState.push.pushEnabled,
      permissionStatus: initialState.push.permissionStatus,
      tokenPlatform: initialState.push.tokenPlatform,
      tokenValue: initialState.push.tokenValue,
      tokenUpdatedAt: initialState.push.tokenUpdatedAt,
    },
  };
}

function sanitizeDeviceId(deviceId: string): string {
  return deviceId.replace(/[^a-z0-9_-]+/gi, "_");
}

function buildUserIdForDevice(deviceId: string): string {
  return `usr_${sanitizeDeviceId(deviceId)}`;
}

function toIsoTimestamp(value: Date | string | null | undefined): string | undefined {
  if (value == null) {
    return undefined;
  }
  if (value instanceof Date) {
    return value.toISOString();
  }
  return value;
}

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }

  return "Unknown persistence error";
}
