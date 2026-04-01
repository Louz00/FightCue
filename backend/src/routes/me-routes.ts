import type { FastifyInstance } from "fastify";

import {
  buildRuntimeAlerts,
  buildRuntimeEventById,
  buildRuntimeFighterById,
  buildRuntimeMonetization,
  buildRuntimeProfile,
  buildRuntimePush,
} from "../domain/runtime-data.js";
import { buildRuntimePushPreview } from "../domain/push-preview.js";
import { resolveDeviceId } from "../http/device-id.js";
import {
  alertPresetSchema,
  followSchema,
  monetizationSettingsSchema,
  preferencesSchema,
  pushSettingsSchema,
  pushTokenSchema,
} from "../http/schemas.js";
import type { RuntimeService } from "../services/runtime-service.js";
import type { PushDeliveryService } from "../services/push-delivery-service.js";
import type { UserStateStore } from "../store/user-state-store.js";

export function registerMeRoutes(
  app: FastifyInstance,
  {
    stateStore,
    runtimeService,
    pushDeliveryService,
  }: {
    stateStore: UserStateStore;
    runtimeService: RuntimeService;
    pushDeliveryService: PushDeliveryService;
  },
): void {
  app.get("/v1/me/profile", async (request) => {
    const deviceId = resolveDeviceId(request);
    const state = await stateStore.read(deviceId);
    return buildRuntimeProfile(state);
  });

  app.get("/v1/me/preferences", async (request) => {
    const deviceId = resolveDeviceId(request);
    const state = await stateStore.read(deviceId);
    const profile = buildRuntimeProfile(state);

    return {
      language: profile.language,
      timezone: profile.timezone,
      viewingCountryCode: profile.viewingCountryCode,
      premiumState: profile.premiumState,
    };
  });

  app.put<{ Body: unknown }>("/v1/me/preferences", async (request) => {
    const deviceId = resolveDeviceId(request);
    const updates = preferencesSchema.parse(request.body);
    const state = await stateStore.updateProfile(deviceId, updates);
    const profile = buildRuntimeProfile(state);

    return {
      language: profile.language,
      timezone: profile.timezone,
      viewingCountryCode: profile.viewingCountryCode,
      premiumState: profile.premiumState,
    };
  });

  app.get("/v1/me/fighters", async (request) => {
    const deviceId = resolveDeviceId(request);
    const state = await stateStore.read(deviceId);
    const runtime = await runtimeService.resolveRuntimeData(state);
    return {
      items: runtime.fighters.filter((fighter) => fighter.isFollowed),
    };
  });

  app.get("/v1/me/alerts", async (request) => {
    const deviceId = resolveDeviceId(request);
    const state = await stateStore.read(deviceId);
    return buildRuntimeAlerts(state);
  });

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

  app.post("/v1/me/push/test", async (request) => {
    const deviceId = resolveDeviceId(request);
    return pushDeliveryService.sendTestNotificationForDevice(deviceId);
  });

  app.get("/v1/me/monetization", async (request) => {
    const deviceId = resolveDeviceId(request);
    const state = await stateStore.read(deviceId);
    return buildRuntimeMonetization(state);
  });

  app.put<{ Body: unknown }>("/v1/me/push/settings", async (request) => {
    const deviceId = resolveDeviceId(request);
    const updates = pushSettingsSchema.parse(request.body);
    const state = await stateStore.updatePushSettings(deviceId, updates);
    return buildRuntimePush(state);
  });

  app.put<{ Body: unknown }>("/v1/me/monetization/settings", async (request) => {
    const deviceId = resolveDeviceId(request);
    const updates = monetizationSettingsSchema.parse(request.body);
    const state = await stateStore.updateProfile(deviceId, updates);
    return buildRuntimeMonetization(state);
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

  app.put<{ Params: { fighterId: string }; Body: unknown }>(
    "/v1/me/alerts/fighters/:fighterId",
    async (request, reply) => {
      const deviceId = resolveDeviceId(request);
      const presetKeys = alertPresetSchema.parse(request.body).presetKeys;
      const state = await stateStore.read(deviceId);
      const runtime = await runtimeService.resolveRuntimeData(state);
      const existing = runtime.fighters.find(
        (fighter) => fighter.id === request.params.fighterId,
      );

      if (!existing) {
        return reply.code(404).send({
          error: "not_found",
          message: "Fighter not found",
        });
      }

      const nextState = await stateStore.updateAlertPresets(
        deviceId,
        "fighter",
        request.params.fighterId,
        presetKeys,
      );

      return buildRuntimeAlerts(nextState);
    },
  );

  app.put<{ Params: { eventId: string }; Body: unknown }>(
    "/v1/me/alerts/events/:eventId",
    async (request, reply) => {
      const deviceId = resolveDeviceId(request);
      const presetKeys = alertPresetSchema.parse(request.body).presetKeys;
      const state = await stateStore.read(deviceId);
      const existing = buildRuntimeEventById(state, request.params.eventId);

      if (!existing) {
        return reply.code(404).send({
          error: "not_found",
          message: "Event not found",
        });
      }

      const nextState = await stateStore.updateAlertPresets(
        deviceId,
        "event",
        request.params.eventId,
        presetKeys,
      );

      return buildRuntimeAlerts(nextState);
    },
  );

  app.put<{ Params: { fighterId: string }; Body: unknown }>(
    "/v1/me/follows/fighters/:fighterId",
    async (request, reply) => {
      const deviceId = resolveDeviceId(request);
      const followed = followSchema.parse(request.body).followed;
      const runtime = await runtimeService.resolveRuntimeDataForDevice(deviceId);
      const existing = runtime.fighters.find(
        (fighter) => fighter.id === request.params.fighterId,
      );

      if (!existing) {
        return reply.code(404).send({
          error: "not_found",
          message: "Fighter not found",
        });
      }

      const state = await stateStore.setFollow(
        deviceId,
        "fighter",
        request.params.fighterId,
        followed,
      );
      return {
        item: buildRuntimeFighterById(state, request.params.fighterId),
      };
    },
  );

  app.put<{ Params: { eventId: string }; Body: unknown }>(
    "/v1/me/follows/events/:eventId",
    async (request, reply) => {
      const deviceId = resolveDeviceId(request);
      const followed = followSchema.parse(request.body).followed;
      const runtime = await runtimeService.resolveRuntimeDataForDevice(deviceId);
      const existing = runtime.events.find((event) => event.id === request.params.eventId);

      if (!existing) {
        return reply.code(404).send({
          error: "not_found",
          message: "Event not found",
        });
      }

      const state = await stateStore.setFollow(
        deviceId,
        "event",
        request.params.eventId,
        followed,
      );
      return {
        item: buildRuntimeEventById(state, request.params.eventId),
      };
    },
  );
}
