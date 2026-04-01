import { applicationDefault, cert, getApp, getApps, initializeApp } from "firebase-admin/app";
import { getMessaging } from "firebase-admin/messaging";

import {
  getConfiguredPushProvider,
  getFirebasePushConfig,
  isFirebasePushConfigured,
  type FirebasePushConfig,
} from "../config/push-delivery.js";
import {
  DEFAULT_PUSH_DISPATCH_LOOKBACK_MS,
  buildRuntimeDuePushSummary,
  buildRuntimePushPreview,
} from "../domain/push-preview.js";
import type {
  PushDispatchItemSummary,
  PushDispatchSummary,
  PushProviderStatusSummary,
  PushProviderType,
  PushTestDispatchSummary,
} from "../domain/models.js";
import { logInfo } from "../observability/logger.js";
import type { UserStateStore } from "../store/user-state-store.js";

type PushDispatchPayload = {
  reminderId: string;
  deviceId: string;
  tokenValue: string;
  title: string;
  body: string;
  kind: "test" | "scheduled";
};

type PushDispatchReceipt = {
  providerMessageId: string;
};

interface PushDispatchProvider {
  readonly provider: PushProviderType;
  readonly supportsDelivery: boolean;
  readonly configured: boolean;
  readonly description: string;
  send(payload: PushDispatchPayload): Promise<PushDispatchReceipt>;
}

class DisabledPushDispatchProvider implements PushDispatchProvider {
  readonly provider = "disabled" as const;
  readonly supportsDelivery = false;
  readonly configured = false;
  readonly description = "Push delivery is disabled for this environment.";

  async send(_payload: PushDispatchPayload): Promise<PushDispatchReceipt> {
    throw new Error("Push delivery provider is disabled.");
  }
}

class LogPushDispatchProvider implements PushDispatchProvider {
  readonly provider = "log" as const;
  readonly supportsDelivery = true;
  readonly configured = true;
  readonly description =
    "FightCue logs test push payloads locally until real APNs/FCM credentials are configured.";

  async send(payload: PushDispatchPayload): Promise<PushDispatchReceipt> {
    const providerMessageId = `log_${Date.now()}`;
    logInfo(payload.kind === "test" ? "push.test_dispatched" : "push.due_dispatched", {
      provider: this.provider,
      providerMessageId,
      deviceId: payload.deviceId,
      tokenSuffix: payload.tokenValue.slice(-8),
      title: payload.title,
      body: payload.body,
      reminderId: payload.reminderId,
      dispatchKind: payload.kind,
    });
    return { providerMessageId };
  }
}

class FirebasePushDispatchProvider implements PushDispatchProvider {
  readonly provider = "firebase" as const;
  readonly supportsDelivery = true;
  readonly configured: boolean;
  readonly description: string;

  constructor(private readonly config: FirebasePushConfig) {
    this.configured = isFirebasePushConfigured(config);
    this.description = this.configured
      ? "Firebase Cloud Messaging is configured for direct device push delivery."
      : "Firebase delivery is selected, but service account credentials are still missing.";
  }

  async send(payload: PushDispatchPayload): Promise<PushDispatchReceipt> {
    if (!this.configured) {
      throw new Error(
        "Firebase push delivery is not configured. Set FIGHTCUE_FIREBASE_SERVICE_ACCOUNT_JSON or GOOGLE_APPLICATION_CREDENTIALS.",
      );
    }

    const app = getOrInitializeFirebaseApp(this.config);
    const response = await getMessaging(app).send({
      token: payload.tokenValue,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: {
        source: "fightcue",
        type: payload.kind === "test" ? "test_reminder" : "scheduled_reminder",
        deviceId: payload.deviceId,
        reminderId: payload.reminderId,
      },
      android: {
        priority: "high",
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    });
    return { providerMessageId: response };
  }
}

export class PushDeliveryService {
  private readonly provider: PushDispatchProvider;
  private readonly dispatchedReminderIds = new Map<string, number>();

  constructor(private readonly stateStore: UserStateStore) {
    this.provider = createPushDispatchProvider();
  }

  getProviderStatus(): PushProviderStatusSummary {
    return {
      provider: this.provider.provider,
      supportsDelivery: this.provider.supportsDelivery,
      configured: this.provider.configured,
      description: this.provider.description,
    };
  }

  async sendTestNotificationForDevice(
    deviceId: string,
  ): Promise<PushTestDispatchSummary> {
    const state = await this.stateStore.read(deviceId);
    const preview = buildRuntimePushPreview(state, new Date());

    const title = "FightCue test reminder";
    const body = "Push delivery is connected for this device.";

    if (preview.deliveryReadiness !== "ready" || !state.push.tokenValue) {
      return {
        provider: this.provider.provider,
        deliveryReadiness: preview.deliveryReadiness,
        dispatched: false,
        title,
        body,
        tokenPlatform: state.push.tokenPlatform,
        message: buildBlockedMessage(preview.deliveryReadiness),
      };
    }

    try {
      const receipt = await this.provider.send({
        reminderId: `push_test_${deviceId}`,
        deviceId,
        tokenValue: state.push.tokenValue,
        title,
        body,
        kind: "test",
      });

      return {
        provider: this.provider.provider,
        deliveryReadiness: preview.deliveryReadiness,
        dispatched: true,
        title,
        body,
        tokenPlatform: state.push.tokenPlatform,
        providerMessageId: receipt.providerMessageId,
        message:
          this.provider.provider === "firebase"
            ? "FightCue handed the test reminder to Firebase for delivery."
            : "FightCue queued a test reminder for this device.",
      };
    } catch (error) {
      logInfo("push.test_dispatch_blocked", {
        provider: this.provider.provider,
        deviceId,
        reason: error instanceof Error ? error.message : "unknown_error",
      });
      return {
        provider: this.provider.provider,
        deliveryReadiness: preview.deliveryReadiness,
        dispatched: false,
        title,
        body,
        tokenPlatform: state.push.tokenPlatform,
        message:
          error instanceof Error
            ? error.message
            : "FightCue could not hand the test reminder to the active push provider.",
      };
    }
  }

  async previewDueNotificationsForDevice(
    deviceId: string,
    {
      now = new Date(),
      lookbackMs = DEFAULT_PUSH_DISPATCH_LOOKBACK_MS,
    }: {
      now?: Date;
      lookbackMs?: number;
    } = {},
  ) {
    const state = await this.stateStore.read(deviceId);
    return buildRuntimeDuePushSummary(state, now, lookbackMs);
  }

  async dispatchDueNotificationsForDevice(
    deviceId: string,
    {
      now = new Date(),
      lookbackMs = DEFAULT_PUSH_DISPATCH_LOOKBACK_MS,
    }: {
      now?: Date;
      lookbackMs?: number;
    } = {},
  ): Promise<PushDispatchSummary> {
    this.pruneDispatchHistory(now.getTime());

    const state = await this.stateStore.read(deviceId);
    const due = buildRuntimeDuePushSummary(state, now, lookbackMs);

    if (due.deliveryReadiness !== "ready" || !state.push.tokenValue) {
      return {
        provider: this.provider.provider,
        deliveryReadiness: due.deliveryReadiness,
        dueCount: due.dueCount,
        dispatchedCount: 0,
        skippedCount: due.dueCount,
        lookbackMinutes: due.lookbackMinutes,
        items: due.items.map((item) => ({
          ...item,
          dispatched: false,
          message: buildBlockedMessage(due.deliveryReadiness),
        })),
        message: buildBlockedMessage(due.deliveryReadiness),
      };
    }

    const items: PushDispatchItemSummary[] = [];

    for (const item of due.items) {
      if (this.dispatchedReminderIds.has(item.id)) {
        items.push({
          ...item,
          dispatched: false,
          message: "FightCue already dispatched this reminder in the current worker window.",
        });
        continue;
      }

      try {
        const receipt = await this.provider.send({
          reminderId: item.id,
          deviceId,
          tokenValue: state.push.tokenValue,
          title: item.title,
          body: item.body,
          kind: "scheduled",
        });
        this.dispatchedReminderIds.set(item.id, now.getTime());
        logInfo("push.reminder_dispatched", {
          provider: this.provider.provider,
          deviceId,
          reminderId: item.id,
          providerMessageId: receipt.providerMessageId,
          targetType: item.targetType,
          targetId: item.targetId,
          eventId: item.eventId,
          reason: item.reason,
        });
        items.push({
          ...item,
          dispatched: true,
          providerMessageId: receipt.providerMessageId,
          message: "FightCue queued this due reminder for delivery.",
        });
      } catch (error) {
        const message =
          error instanceof Error
            ? error.message
            : "FightCue could not dispatch this due reminder.";
        logInfo("push.reminder_dispatch_blocked", {
          provider: this.provider.provider,
          deviceId,
          reminderId: item.id,
          reason: message,
        });
        items.push({
          ...item,
          dispatched: false,
          message,
        });
      }
    }

    const dispatchedCount = items.filter((item) => item.dispatched).length;
    const skippedCount = items.length - dispatchedCount;

    return {
      provider: this.provider.provider,
      deliveryReadiness: due.deliveryReadiness,
      dueCount: due.dueCount,
      dispatchedCount,
      skippedCount,
      lookbackMinutes: due.lookbackMinutes,
      items,
      message:
        dispatchedCount > 0
          ? `FightCue dispatched ${dispatchedCount} due reminder${dispatchedCount === 1 ? "" : "s"}.`
          : "No new due reminders were dispatched.",
    };
  }

  private pruneDispatchHistory(nowMs: number): void {
    const retentionMs = 30 * 60 * 1000;
    for (const [reminderId, dispatchedAtMs] of this.dispatchedReminderIds.entries()) {
      if (dispatchedAtMs < nowMs - retentionMs) {
        this.dispatchedReminderIds.delete(reminderId);
      }
    }
  }
}

function createPushDispatchProvider(): PushDispatchProvider {
  const provider = getConfiguredPushProvider();
  switch (provider) {
    case "disabled":
      return new DisabledPushDispatchProvider();
    case "firebase":
      return new FirebasePushDispatchProvider(getFirebasePushConfig());
    case "log":
    default:
      return new LogPushDispatchProvider();
  }
}

function buildBlockedMessage(
  readiness: PushTestDispatchSummary["deliveryReadiness"],
): string {
  switch (readiness) {
    case "disabled":
      return "Push reminders are currently turned off for this device.";
    case "permission_required":
      return "Notification permission is still required before FightCue can send reminders.";
    case "token_missing":
      return "This device still needs a registered push token before reminders can be sent.";
    default:
      return "FightCue could not queue a test reminder for this device.";
  }
}

function getOrInitializeFirebaseApp(config: FirebasePushConfig) {
  if (getApps().length > 0) {
    return getApp();
  }

  if (config.serviceAccountJson) {
    const parsed = JSON.parse(config.serviceAccountJson) as Record<string, string>;
    return initializeApp({
      credential: cert(parsed),
      projectId: config.projectId ?? parsed.project_id,
    });
  }

  return initializeApp({
    credential: applicationDefault(),
    projectId: config.projectId,
  });
}
