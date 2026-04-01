import type { FastifyInstance } from "fastify";

import { buildRuntimePush } from "../domain/runtime-data.js";
import { buildRuntimePushPreview } from "../domain/push-preview.js";
import { resolveDeviceId } from "../http/device-id.js";
import {
  pushDispatchQuerySchema,
  pushSettingsSchema,
  pushTokenSchema,
} from "../http/schemas.js";
import type { MeRouteContext } from "./me-route-context.js";

export function registerMePushRoutes(
  app: FastifyInstance,
  { stateStore, pushDeliveryService }: MeRouteContext,
): void {
  app.get("/v1/me/push", async (request) => {
    const deviceId = resolveDeviceId(request);
    const state = await stateStore.read(deviceId);
    return buildRuntimePush(state);
  });

  app.get("/v1/me/push/provider", async () => {
    return pushDeliveryService.getProviderStatus();
  });

  app.get("/v1/me/push/preview", async (request) => {
    const deviceId = resolveDeviceId(request);
    const state = await stateStore.read(deviceId);
    return buildRuntimePushPreview(state);
  });

  app.get<{ Querystring: { now?: string; lookbackMinutes?: number } }>(
    "/v1/me/push/due",
    async (request) => {
      const deviceId = resolveDeviceId(request);
      const query = pushDispatchQuerySchema.parse(request.query);
      return pushDeliveryService.previewDueNotificationsForDevice(deviceId, {
        now: query.now ? new Date(query.now) : undefined,
        lookbackMs:
          query.lookbackMinutes == null ? undefined : query.lookbackMinutes * 60 * 1000,
      });
    },
  );

  app.post("/v1/me/push/test", async (request) => {
    const deviceId = resolveDeviceId(request);
    return pushDeliveryService.sendTestNotificationForDevice(deviceId);
  });

  app.post<{ Querystring: { now?: string; lookbackMinutes?: number } }>(
    "/v1/me/push/dispatch-due",
    async (request) => {
      const deviceId = resolveDeviceId(request);
      const query = pushDispatchQuerySchema.parse(request.query);
      return pushDeliveryService.dispatchDueNotificationsForDevice(deviceId, {
        now: query.now ? new Date(query.now) : undefined,
        lookbackMs:
          query.lookbackMinutes == null ? undefined : query.lookbackMinutes * 60 * 1000,
      });
    },
  );

  app.put<{ Body: unknown }>("/v1/me/push/settings", async (request) => {
    const deviceId = resolveDeviceId(request);
    const updates = pushSettingsSchema.parse(request.body);
    const state = await stateStore.updatePushSettings(deviceId, updates);
    return buildRuntimePush(state);
  });

  app.put<{ Body: unknown }>("/v1/me/push/token", async (request) => {
    const deviceId = resolveDeviceId(request);
    const payload = pushTokenSchema.parse(request.body);
    const state = await stateStore.updatePushSettings(deviceId, {
      pushEnabled: payload.permissionStatus === "granted",
      permissionStatus: payload.permissionStatus,
      tokenPlatform: payload.tokenValue != null ? payload.tokenPlatform : undefined,
      tokenValue: payload.tokenValue,
    });
    return buildRuntimePush(state);
  });
}
