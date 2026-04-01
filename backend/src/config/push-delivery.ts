import type { PushProviderType } from "../domain/models.js";

export function getConfiguredPushProvider(): PushProviderType {
  const raw = (process.env.FIGHTCUE_PUSH_PROVIDER ?? "log").trim().toLowerCase();
  switch (raw) {
    case "disabled":
      return "disabled";
    case "firebase":
      return "firebase";
    case "log":
    default:
      return "log";
  }
}

export type FirebasePushConfig = {
  projectId?: string;
  serviceAccountJson?: string;
  googleApplicationCredentials?: string;
};

export function getFirebasePushConfig(): FirebasePushConfig {
  return {
    projectId:
      process.env.FIGHTCUE_FIREBASE_PROJECT_ID ??
      process.env.FIREBASE_PROJECT_ID ??
      undefined,
    serviceAccountJson:
      process.env.FIGHTCUE_FIREBASE_SERVICE_ACCOUNT_JSON ??
      process.env.FIREBASE_SERVICE_ACCOUNT_JSON ??
      undefined,
    googleApplicationCredentials:
      process.env.GOOGLE_APPLICATION_CREDENTIALS ?? undefined,
  };
}

export function isFirebasePushConfigured(
  config: FirebasePushConfig = getFirebasePushConfig(),
): boolean {
  return Boolean(config.serviceAccountJson || config.googleApplicationCredentials);
}
