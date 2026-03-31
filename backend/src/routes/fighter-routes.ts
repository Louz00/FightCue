import type { FastifyInstance } from "fastify";

import { resolveDeviceId } from "../http/device-id.js";
import type { RuntimeService } from "../services/runtime-service.js";
import type { UserStateStore } from "../store/user-state-store.js";

export function registerFighterRoutes(
  app: FastifyInstance,
  {
    stateStore,
    runtimeService,
  }: {
    stateStore: UserStateStore;
    runtimeService: RuntimeService;
  },
): void {
  app.get<{ Params: { fighterId: string } }>(
    "/v1/fighters/:fighterId",
    async (request, reply) => {
      const deviceId = resolveDeviceId(request);
      const state = await stateStore.read(deviceId);
      const runtime = await runtimeService.resolveRuntimeData(state);
      const item = runtime.fighters.find(
        (fighter) => fighter.id === request.params.fighterId,
      );

      if (!item) {
        return reply.code(404).send({
          error: "not_found",
          message: "Fighter not found",
        });
      }

      return {
        item,
        relatedEvents: runtime.events.filter((event) =>
          event.bouts.some(
            (bout) =>
              bout.fighterAId === request.params.fighterId ||
              bout.fighterBId === request.params.fighterId,
          ),
        ),
      };
    },
  );
}
