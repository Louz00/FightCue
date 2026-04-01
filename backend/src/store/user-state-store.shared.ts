import type { InitialPersistedUserState, PersistedUserState } from "./user-state-store.types.js";

export function seedStateForDevice(
  deviceId: string,
  initialState: InitialPersistedUserState,
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

export function sanitizeStoreDeviceId(deviceId: string): string {
  return deviceId.replace(/[^a-z0-9_-]+/gi, "_");
}

export function buildUserIdForDevice(deviceId: string): string {
  return `usr_${sanitizeStoreDeviceId(deviceId)}`;
}

export function toIsoTimestamp(
  value: Date | string | null | undefined,
): string | undefined {
  if (value == null) {
    return undefined;
  }
  if (value instanceof Date) {
    return value.toISOString();
  }
  return value;
}

export function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }

  return "Unknown persistence error";
}
