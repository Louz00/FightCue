import type { FastifyInstance } from "fastify";

import { buildEventCalendarIcs } from "../domain/runtime-data.js";
import { resolveDeviceId } from "../http/device-id.js";
import type { RuntimeService } from "../services/runtime-service.js";
import type { UserStateStore } from "../store/user-state-store.js";

export function registerEventRoutes(
  app: FastifyInstance,
  {
    stateStore,
    runtimeService,
  }: {
    stateStore: UserStateStore;
    runtimeService: RuntimeService;
  },
): void {
  app.get("/v1/home", async (request) => {
    const deviceId = resolveDeviceId(request);
    const state = await stateStore.read(deviceId);
    return runtimeService.resolveRuntimeData(state);
  });

  app.get("/v1/events", async (request) => {
    const deviceId = resolveDeviceId(request);
    const state = await stateStore.read(deviceId);
    const runtime = await runtimeService.resolveRuntimeData(state);
    return {
      items: runtime.events,
      nextCursor: null,
    };
  });

  app.get<{ Params: { eventId: string } }>("/v1/events/:eventId", async (request, reply) => {
    const deviceId = resolveDeviceId(request);
    const state = await stateStore.read(deviceId);
    const runtime = await runtimeService.resolveRuntimeData(state);
    const item = runtime.events.find((event) => event.id === request.params.eventId);

    if (!item) {
      return reply.code(404).send({
        error: "not_found",
        message: "Event not found",
      });
    }

    return {
      item,
      calendarExportPath: `/v1/events/${request.params.eventId}/calendar.ics`,
    };
  });

  app.get<{ Params: { eventId: string } }>(
    "/v1/events/:eventId/calendar.ics",
    async (request, reply) => {
      const deviceId = resolveDeviceId(request);
      const state = await stateStore.read(deviceId);
      const runtime = await runtimeService.resolveRuntimeData(state);
      const item = runtime.events.find((event) => event.id === request.params.eventId);

      if (!item) {
        return reply.code(404).send({
          error: "not_found",
          message: "Event not found",
        });
      }

      return reply
        .header("content-type", "text/calendar; charset=utf-8")
        .header(
          "content-disposition",
          `attachment; filename="${request.params.eventId}.ics"`,
        )
        .send(buildEventCalendarIcs(item));
    },
  );
}
