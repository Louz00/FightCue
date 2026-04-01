import { getPushWorkerIntervalMs, getPushWorkerLookbackMs, isPushWorkerEnabled } from "../config/push-worker.js";
import { logError, logInfo } from "../observability/logger.js";
import type { UserStateStore } from "../store/user-state-store.js";
import type { PushDeliveryService } from "./push-delivery-service.js";

export type PushDispatchWorkerStatus = {
  enabled: boolean;
  running: boolean;
  inFlight: boolean;
  intervalSeconds: number;
  lookbackMinutes: number;
  lastRunAt?: string;
  lastCompletedAt?: string;
  lastError?: string;
  lastDeviceCount?: number;
  lastDispatchedCount?: number;
};

export class PushDispatchWorker {
  private timer?: NodeJS.Timeout;
  private inFlight = false;
  private lastRunAt?: string;
  private lastCompletedAt?: string;
  private lastError?: string;
  private lastDeviceCount?: number;
  private lastDispatchedCount?: number;

  constructor(
    private readonly stateStore: UserStateStore,
    private readonly pushDeliveryService: PushDeliveryService,
    private readonly enabled = isPushWorkerEnabled(),
    private readonly intervalMs = getPushWorkerIntervalMs(),
    private readonly lookbackMs = getPushWorkerLookbackMs(),
  ) {}

  start(): void {
    if (!this.enabled || this.timer) {
      return;
    }

    this.timer = setInterval(() => {
      void this.runOnce();
    }, this.intervalMs);

    logInfo("push.worker_started", {
      intervalSeconds: this.intervalMs / 1000,
      lookbackMinutes: this.lookbackMs / (60 * 1000),
    });
  }

  async runOnce(now = new Date()): Promise<void> {
    if (!this.enabled || this.inFlight) {
      return;
    }

    this.inFlight = true;
    this.lastRunAt = now.toISOString();
    this.lastError = undefined;

    try {
      const deviceIds = await this.stateStore.listPushReadyDeviceIds();
      let dispatchedCount = 0;

      for (const deviceId of deviceIds) {
        const result = await this.pushDeliveryService.dispatchDueNotificationsForDevice(deviceId, {
          now,
          lookbackMs: this.lookbackMs,
        });
        dispatchedCount += result.dispatchedCount;
      }

      this.lastDeviceCount = deviceIds.length;
      this.lastDispatchedCount = dispatchedCount;
      this.lastCompletedAt = new Date().toISOString();

      logInfo("push.worker_completed", {
        deviceCount: deviceIds.length,
        dispatchedCount,
        intervalSeconds: this.intervalMs / 1000,
        lookbackMinutes: this.lookbackMs / (60 * 1000),
      });
    } catch (error) {
      this.lastError = error instanceof Error ? error.message : "Unknown push worker error";
      logError("push.worker_failed", {
        reason: this.lastError,
      });
    } finally {
      this.inFlight = false;
    }
  }

  stop(): void {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = undefined;
      logInfo("push.worker_stopped");
    }
  }

  getStatus(): PushDispatchWorkerStatus {
    return {
      enabled: this.enabled,
      running: this.timer != null,
      inFlight: this.inFlight,
      intervalSeconds: this.intervalMs / 1000,
      lookbackMinutes: this.lookbackMs / (60 * 1000),
      lastRunAt: this.lastRunAt,
      lastCompletedAt: this.lastCompletedAt,
      lastError: this.lastError,
      lastDeviceCount: this.lastDeviceCount,
      lastDispatchedCount: this.lastDispatchedCount,
    };
  }
}
