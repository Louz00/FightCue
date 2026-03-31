import type { FastifyInstance } from "fastify";

import { buildRuntimeProfile } from "../domain/runtime-data.js";
import { resolveDeviceId } from "../http/device-id.js";
import { sourceQuerySchema } from "../http/schemas.js";
import {
  EVENT_SOURCE_DEFINITIONS,
  LEADERBOARD_SOURCE_DEFINITIONS,
} from "../sources/source-registry.js";
import type { RuntimeService } from "../services/runtime-service.js";
import type { UserStateStore } from "../store/user-state-store.js";

export function registerSourceRoutes(
  app: FastifyInstance,
  {
    stateStore,
    runtimeService,
  }: {
    stateStore: UserStateStore;
    runtimeService: RuntimeService;
  },
): void {
  for (const definition of EVENT_SOURCE_DEFINITIONS) {
    app.get<{ Querystring: { timezone?: string; country?: string } }>(
      definition.routePath,
      async (request) => {
        const deviceId = resolveDeviceId(request);
        const parsedQuery = sourceQuerySchema.parse(request.query);
        const state = await stateStore.read(deviceId);
        const profile = buildRuntimeProfile(state);

        return runtimeService.getCachedEventPreview(
          definition.key,
          parsedQuery.timezone ?? profile.timezone,
          parsedQuery.country?.toUpperCase() ?? profile.viewingCountryCode,
        );
      },
    );
  }

  for (const definition of LEADERBOARD_SOURCE_DEFINITIONS) {
    app.get<{ Querystring: { timezone?: string; country?: string } }>(
      definition.routePath,
      async (request) => {
        const deviceId = resolveDeviceId(request);
        const parsedQuery = sourceQuerySchema.parse(request.query);
        const state = await stateStore.read(deviceId);
        const profile = buildRuntimeProfile(state);

        return runtimeService.getCachedLeaderboardPreview(
          definition.key,
          parsedQuery.timezone ?? profile.timezone,
          parsedQuery.country?.toUpperCase() ?? profile.viewingCountryCode,
        );
      },
    );
  }
}
