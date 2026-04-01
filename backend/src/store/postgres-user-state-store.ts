import { Pool, type PoolClient } from "pg";

import { runSchemaMigrations } from "../db/migrations.js";
import type {
  AlertPresetKey,
  PremiumState,
  PushPermissionStatus,
  PushTokenPlatform,
  SupportedLanguage,
  UserProfile,
} from "../domain/models.js";
import {
  sanitizeStoreDeviceId,
  seedStateForDevice,
  toIsoTimestamp,
} from "./user-state-store.shared.js";
import type {
  InitialPersistedUserState,
  PersistedUserState,
  UserStateStore,
} from "./user-state-store.types.js";

export async function createPostgresUserStateStore(
  _baseProfile: UserProfile,
  initialState: InitialPersistedUserState,
  connection: string | Pool,
): Promise<UserStateStore> {
  const pool =
    typeof connection === "string"
      ? new Pool({ connectionString: connection })
      : connection;
  await runSchemaMigrations(pool);
  return new PostgresUserStateStore(pool, initialState);
}

export class PostgresUserStateStore implements UserStateStore {
  constructor(
    private readonly pool: Pool,
    private readonly initialState: InitialPersistedUserState,
  ) {}

  readonly backendLabel = "postgres" as const;

  async read(deviceId = "device_demo_local"): Promise<PersistedUserState> {
    return this.withUserTransaction(deviceId, async (client, userId) => {
      return this.readForUser(client, userId);
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
    const safeDeviceId = sanitizeStoreDeviceId(deviceId);
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
        tokenUpdatedAt:
          toIsoTimestamp(push?.token_updated_at) ?? seededState.push.tokenUpdatedAt,
      },
    };
  }
}
