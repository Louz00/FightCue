import type { FastifyInstance } from "fastify";

import { buildRuntimeProfile } from "../domain/runtime-data.js";
import { resolveDeviceId } from "../http/device-id.js";
import { sourceQuerySchema } from "../http/schemas.js";
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
  app.get<{ Querystring: { timezone?: string; country?: string } }>(
    "/v1/sources/ufc/events",
    async (request) => {
      const deviceId = resolveDeviceId(request);
      const parsedQuery = sourceQuerySchema.parse(request.query);
      const state = await stateStore.read(deviceId);
      const profile = buildRuntimeProfile(state);

      return runtimeService.getCachedUfcPreview(
        parsedQuery.timezone ?? profile.timezone,
        parsedQuery.country?.toUpperCase() ?? profile.viewingCountryCode,
      );
    },
  );

  app.get<{ Querystring: { timezone?: string; country?: string } }>(
    "/v1/sources/glory/events",
    async (request) => {
      const deviceId = resolveDeviceId(request);
      const parsedQuery = sourceQuerySchema.parse(request.query);
      const state = await stateStore.read(deviceId);
      const profile = buildRuntimeProfile(state);

      return runtimeService.getCachedGloryPreview(
        parsedQuery.timezone ?? profile.timezone,
        parsedQuery.country?.toUpperCase() ?? profile.viewingCountryCode,
      );
    },
  );

  app.get<{ Querystring: { timezone?: string; country?: string } }>(
    "/v1/sources/matchroom/events",
    async (request) => {
      const deviceId = resolveDeviceId(request);
      const parsedQuery = sourceQuerySchema.parse(request.query);
      const state = await stateStore.read(deviceId);
      const profile = buildRuntimeProfile(state);

      return runtimeService.getCachedMatchroomPreview(
        parsedQuery.timezone ?? profile.timezone,
        parsedQuery.country?.toUpperCase() ?? profile.viewingCountryCode,
      );
    },
  );

  app.get<{ Querystring: { timezone?: string; country?: string } }>(
    "/v1/sources/pbc/events",
    async (request) => {
      const deviceId = resolveDeviceId(request);
      const parsedQuery = sourceQuerySchema.parse(request.query);
      const state = await stateStore.read(deviceId);
      const profile = buildRuntimeProfile(state);

      return runtimeService.getCachedPbcPreview(
        parsedQuery.timezone ?? profile.timezone,
        parsedQuery.country?.toUpperCase() ?? profile.viewingCountryCode,
      );
    },
  );

  app.get<{ Querystring: { timezone?: string; country?: string } }>(
    "/v1/sources/golden-boy/events",
    async (request) => {
      const deviceId = resolveDeviceId(request);
      const parsedQuery = sourceQuerySchema.parse(request.query);
      const state = await stateStore.read(deviceId);
      const profile = buildRuntimeProfile(state);

      return runtimeService.getCachedGoldenBoyPreview(
        parsedQuery.timezone ?? profile.timezone,
        parsedQuery.country?.toUpperCase() ?? profile.viewingCountryCode,
      );
    },
  );

  app.get<{ Querystring: { timezone?: string; country?: string } }>(
    "/v1/sources/boxxer/events",
    async (request) => {
      const deviceId = resolveDeviceId(request);
      const parsedQuery = sourceQuerySchema.parse(request.query);
      const state = await stateStore.read(deviceId);
      const profile = buildRuntimeProfile(state);

      return runtimeService.getCachedBoxxerPreview(
        parsedQuery.timezone ?? profile.timezone,
        parsedQuery.country?.toUpperCase() ?? profile.viewingCountryCode,
      );
    },
  );

  app.get<{ Querystring: { timezone?: string; country?: string } }>(
    "/v1/sources/queensberry/events",
    async (request) => {
      const deviceId = resolveDeviceId(request);
      const parsedQuery = sourceQuerySchema.parse(request.query);
      const state = await stateStore.read(deviceId);
      const profile = buildRuntimeProfile(state);

      return runtimeService.getCachedQueensberryPreview(
        parsedQuery.timezone ?? profile.timezone,
        parsedQuery.country?.toUpperCase() ?? profile.viewingCountryCode,
      );
    },
  );

  app.get<{ Querystring: { timezone?: string; country?: string } }>(
    "/v1/sources/top-rank/events",
    async (request) => {
      const deviceId = resolveDeviceId(request);
      const parsedQuery = sourceQuerySchema.parse(request.query);
      const state = await stateStore.read(deviceId);
      const profile = buildRuntimeProfile(state);

      return runtimeService.getCachedTopRankPreview(
        parsedQuery.timezone ?? profile.timezone,
        parsedQuery.country?.toUpperCase() ?? profile.viewingCountryCode,
      );
    },
  );

  app.get<{ Querystring: { timezone?: string; country?: string } }>(
    "/v1/sources/espn/boxing-schedule",
    async (request) => {
      const deviceId = resolveDeviceId(request);
      const parsedQuery = sourceQuerySchema.parse(request.query);
      const state = await stateStore.read(deviceId);
      const profile = buildRuntimeProfile(state);

      return runtimeService.getCachedEspnBoxingPreview(
        parsedQuery.timezone ?? profile.timezone,
        parsedQuery.country?.toUpperCase() ?? profile.viewingCountryCode,
      );
    },
  );

  app.get<{ Querystring: { timezone?: string; country?: string } }>(
    "/v1/sources/espn/boxing-rankings",
    async (request) => {
      const deviceId = resolveDeviceId(request);
      const parsedQuery = sourceQuerySchema.parse(request.query);
      const state = await stateStore.read(deviceId);
      const profile = buildRuntimeProfile(state);

      return runtimeService.getCachedEspnBoxingRankingsPreview(
        parsedQuery.timezone ?? profile.timezone,
        parsedQuery.country?.toUpperCase() ?? profile.viewingCountryCode,
      );
    },
  );

  app.get<{ Querystring: { timezone?: string; country?: string } }>(
    "/v1/sources/ring/boxing-ratings",
    async (request) => {
      const deviceId = resolveDeviceId(request);
      const parsedQuery = sourceQuerySchema.parse(request.query);
      const state = await stateStore.read(deviceId);
      const profile = buildRuntimeProfile(state);

      return runtimeService.getCachedRingBoxingRatingsPreview(
        parsedQuery.timezone ?? profile.timezone,
        parsedQuery.country?.toUpperCase() ?? profile.viewingCountryCode,
      );
    },
  );
}
