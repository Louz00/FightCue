import type { FastifyInstance } from "fastify";

import {
  buildRuntimeAlerts,
  buildRuntimeEventById,
} from "../domain/runtime-data.js";
import { resolveDeviceId } from "../http/device-id.js";
import { alertPresetSchema } from "../http/schemas.js";
import type { MeRouteContext } from "./me-route-context.js";

export function registerMeAlertRoutes(
  app: FastifyInstance,
  { stateStore, runtimeService }: MeRouteContext,
): void {
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
}
