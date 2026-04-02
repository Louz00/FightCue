import test from "node:test";
import assert from "node:assert/strict";

import { PushDispatchWorker } from "../../src/services/push-dispatch-worker.js";
import type { UserStateStore } from "../../src/store/user-state-store.js";

test("PushDispatchWorker dispatches due reminders for push-ready devices and records status", async () => {
  const seenDevices: string[] = [];

  const stateStore = {
    backendLabel: "file",
    async read() {
      throw new Error("read should not be called by this worker test");
    },
    async listPushReadyDeviceIds() {
      return ["device_a", "device_b"];
    },
    async updateProfile() {
      throw new Error("not used");
    },
    async setFollow() {
      throw new Error("not used");
    },
    async updateAlertPresets() {
      throw new Error("not used");
    },
    async updatePushSettings() {
      throw new Error("not used");
    },
  } satisfies UserStateStore;

  const pushDeliveryService = {
    async dispatchDueNotificationsForDevice(deviceId: string) {
      seenDevices.push(deviceId);
      return {
        provider: "log" as const,
        deliveryReadiness: "ready" as const,
        dueCount: 1,
        dispatchedCount: 1,
        skippedCount: 0,
        lookbackMinutes: 15,
        items: [],
        message: "ok",
      };
    },
  };

  const worker = new PushDispatchWorker(
    stateStore,
    pushDeliveryService as never,
    true,
    60_000,
    15 * 60 * 1000,
  );

  await worker.runOnce(new Date("2026-04-01T10:00:00.000Z"));

  assert.deepEqual(seenDevices, ["device_a", "device_b"]);
  assert.equal(worker.getStatus().enabled, true);
  assert.equal(worker.getStatus().healthStatus, "healthy");
  assert.equal(worker.getStatus().lastDeviceCount, 2);
  assert.equal(worker.getStatus().lastDispatchedCount, 2);
  assert.equal(typeof worker.getStatus().lastCompletedAt, "string");
  assert.equal(worker.getStatus().consecutiveFailureCount, 0);
  assert.equal(typeof worker.getStatus().lastRunDurationMs, "number");
});

test("PushDispatchWorker marks warning and degraded health after repeated failures, then recovers on success", async () => {
  let shouldFail = true;

  const stateStore = {
    backendLabel: "postgres",
    async read() {
      throw new Error("read should not be called by this worker test");
    },
    async listPushReadyDeviceIds() {
      if (shouldFail) {
        throw new Error("database unavailable");
      }

      return ["device_a"];
    },
    async updateProfile() {
      throw new Error("not used");
    },
    async setFollow() {
      throw new Error("not used");
    },
    async updateAlertPresets() {
      throw new Error("not used");
    },
    async updatePushSettings() {
      throw new Error("not used");
    },
  } satisfies UserStateStore;

  const pushDeliveryService = {
    async dispatchDueNotificationsForDevice() {
      return {
        provider: "log" as const,
        deliveryReadiness: "ready" as const,
        dueCount: 1,
        dispatchedCount: 1,
        skippedCount: 0,
        lookbackMinutes: 15,
        items: [],
        message: "ok",
      };
    },
  };

  const worker = new PushDispatchWorker(
    stateStore,
    pushDeliveryService as never,
    true,
    60_000,
    15 * 60 * 1000,
  );

  await worker.runOnce(new Date("2026-04-01T10:00:00.000Z"));
  assert.equal(worker.getStatus().healthStatus, "warning");
  assert.equal(worker.getStatus().consecutiveFailureCount, 1);
  assert.equal(worker.getStatus().lastError, "database unavailable");
  assert.equal(typeof worker.getStatus().lastFailureAt, "string");

  await worker.runOnce(new Date("2026-04-01T10:01:00.000Z"));
  assert.equal(worker.getStatus().healthStatus, "warning");
  assert.equal(worker.getStatus().consecutiveFailureCount, 2);

  await worker.runOnce(new Date("2026-04-01T10:02:00.000Z"));
  assert.equal(worker.getStatus().healthStatus, "degraded");
  assert.equal(worker.getStatus().consecutiveFailureCount, 3);

  shouldFail = false;
  await worker.runOnce(new Date("2026-04-01T10:03:00.000Z"));
  assert.equal(worker.getStatus().healthStatus, "healthy");
  assert.equal(worker.getStatus().consecutiveFailureCount, 0);
  assert.equal(worker.getStatus().lastDispatchedCount, 1);
});
