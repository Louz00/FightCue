import { mkdir, readFile, readdir, writeFile } from "node:fs/promises";
import path from "node:path";

import type { AlertPresetKey } from "../domain/models.js";
import { logError } from "../observability/logger.js";
import {
  sanitizeStoreDeviceId,
  seedStateForDevice,
} from "./user-state-store.shared.js";
import type {
  InitialPersistedUserState,
  PersistedUserState,
  StoreHealthSnapshot,
  UserStateStore,
} from "./user-state-store.types.js";

export class FileUserStateStore implements UserStateStore {
  constructor(
    private readonly initialState: InitialPersistedUserState,
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
    } catch (error) {
      if (isMissingFileError(error)) {
        await this.write(deviceId, seededState);
        return structuredClone(seededState);
      }

      logError("persistence.file_read_failed", {
        backend: this.backendLabel,
        deviceId: sanitizeStoreDeviceId(deviceId),
        reason: error instanceof Error ? error.message : "Unknown file read error",
      });

      throw error;
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
              : updates.tokenUpdatedAt ?? new Date().toISOString(),
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

  async getHealth(): Promise<StoreHealthSnapshot> {
    return {
      status: "healthy",
      backend: this.backendLabel,
    };
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
    const safeDeviceId = sanitizeStoreDeviceId(deviceId);
    return path.resolve(process.cwd(), ".data", "users", `${safeDeviceId}.json`);
  }
}

function isMissingFileError(error: unknown): boolean {
  return (
    typeof error === "object" &&
    error != null &&
    "code" in error &&
    (error as { code?: string }).code === "ENOENT"
  );
}
