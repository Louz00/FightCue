import type {
  AlertPresetKey,
  PremiumState,
  PushPermissionStatus,
  PushTokenPlatform,
  SupportedLanguage,
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

export type InitialPersistedUserState = Omit<PersistedUserState, "profile"> & {
  profile: Omit<PersistedUserState["profile"], "userId">;
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
