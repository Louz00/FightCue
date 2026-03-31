import type { FastifyInstance } from "fastify";

import {
  buildRuntimeAlerts,
  buildRuntimeEventById,
  buildRuntimeFighterById,
  buildRuntimeProfile,
} from "../domain/runtime-data.js";
import { resolveDeviceId } from "../http/device-id.js";
import {
  alertPresetSchema,
  followSchema,
  preferencesSchema,
} from "../http/schemas.js";
import type { RuntimeService } from "../services/runtime-service.js";
import type { UserStateStore } from "../store/user-state-store.js";

export function registerMeRoutes(
  app: FastifyInstance,
  {
    stateStore,
    runtimeService,
  }: {
    stateStore: UserStateStore;
    runtimeService: RuntimeService;
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
