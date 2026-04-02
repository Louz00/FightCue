import { getPushWorkerIntervalMs, getPushWorkerLookbackMs, isPushWorkerEnabled } from "../config/push-worker.js";
import { logError, logInfo } from "../observability/logger.js";
import type { UserStateStore } from "../store/user-state-store.js";
import type { PushDeliveryService } from "./push-delivery-service.js";

export type PushDispatchWorkerStatus = {
  enabled: boolean;
  running: boolean;
  inFlight: boolean;
  healthStatus: "disabled" | "idle" | "healthy" | "warning" | "degraded";
  intervalSeconds: number;
  lookbackMinutes: number;
  lastRunAt?: string;
  lastCompletedAt?: string;
  lastFailureAt?: string;
  lastError?: string;
  lastDeviceCount?: number;
  lastDispatchedCount?: number;
  lastRunDurationMs?: number;
  consecutiveFailureCount: number;
};

export class PushDispatchWorker {
  private timer?: NodeJS.Timeout;
  private inFlight = false;
  private lastRunAt?: string;
  private lastCompletedAt?: string;
  private lastFailureAt?: string;
  private lastError?: string;
  private lastDeviceCount?: number;
  private lastDispatchedCount?: number;
  private lastRunDurationMs?: number;
  private consecutiveFailureCount = 0;

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

    const startedAt = Date.now();
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
      this.lastRunDurationMs = Date.now() - startedAt;
      this.consecutiveFailureCount = 0;

      logInfo("push.worker_completed", {
        deviceCount: deviceIds.length,
        dispatchedCount,
        intervalSeconds: this.intervalMs / 1000,
        lookbackMinutes: this.lookbackMs / (60 * 1000),
        durationMs: this.lastRunDurationMs,
      });
    } catch (error) {
      this.lastError = error instanceof Error ? error.message : "Unknown push worker error";
      this.lastFailureAt = new Date().toISOString();
      this.lastRunDurationMs = Date.now() - startedAt;
      this.consecutiveFailureCount += 1;
      logError("push.worker_failed", {
        reason: this.lastError,
        consecutiveFailureCount: this.consecutiveFailureCount,
        durationMs: this.lastRunDurationMs,
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
      healthStatus: this.getHealthStatus(),
      intervalSeconds: this.intervalMs / 1000,
      lookbackMinutes: this.lookbackMs / (60 * 1000),
      lastRunAt: this.lastRunAt,
      lastCompletedAt: this.lastCompletedAt,
      lastFailureAt: this.lastFailureAt,
      lastError: this.lastError,
      lastDeviceCount: this.lastDeviceCount,
      lastDispatchedCount: this.lastDispatchedCount,
      lastRunDurationMs: this.lastRunDurationMs,
      consecutiveFailureCount: this.consecutiveFailureCount,
    };
  }

  private getHealthStatus(): PushDispatchWorkerStatus["healthStatus"] {
    if (!this.enabled) {
      return "disabled";
    }

    if (this.consecutiveFailureCount >= 3) {
      return "degraded";
    }

    if (this.consecutiveFailureCount > 0) {
      return "warning";
    }

    if (this.lastCompletedAt != null) {
      return "healthy";
    }

    return "idle";
  }
}
