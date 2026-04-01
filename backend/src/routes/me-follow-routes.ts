import type { FastifyInstance } from "fastify";

import {
  buildRuntimeEventById,
  buildRuntimeFighterById,
} from "../domain/runtime-data.js";
import { resolveDeviceId } from "../http/device-id.js";
import { followSchema } from "../http/schemas.js";
import type { MeRouteContext } from "./me-route-context.js";

export function registerMeFollowRoutes(
  app: FastifyInstance,
  { stateStore, runtimeService }: MeRouteContext,
): void {
  app.get("/v1/me/fighters", async (request) => {
    const deviceId = resolveDeviceId(request);
    const state = await stateStore.read(deviceId);
    const runtime = await runtimeService.resolveRuntimeData(state);
    return {
      items: runtime.fighters.filter((fighter) => fighter.isFollowed),
    };
  });

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
