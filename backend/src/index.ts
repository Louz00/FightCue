import Fastify from "fastify";
import cors from "@fastify/cors";
import rateLimit from "@fastify/rate-limit";
import dotenv from "dotenv";
import { z } from "zod";

import { fightCueRuntimeProfile } from "./domain/models.js";
import {
  getEventById,
  getEventsForFighter,
  getFighterById,
  sampleEvents,
  sampleFollowedFighters,
  sampleLeaderboards,
  sampleUserProfile,
} from "./domain/mock-data.js";
import { loadUfcEventsPreview } from "./sources/ufc/ufc-events-source.js";

dotenv.config();

const app = Fastify({ logger: true });

const sourceQuerySchema = z.object({
  timezone: z.string().optional(),
  country: z
    .string()
    .trim()
    .min(2)
    .max(2)
    .optional(),
});

await app.register(cors, {
  origin: process.env.CORS_ORIGIN ?? true,
});

await app.register(rateLimit, {
  max: 100,
  timeWindow: "1 minute",
});

app.get("/health", async () => ({
  ok: true,
  service: "fightcue-backend",
}));

app.get("/v1/meta", async () => ({
  appName: "FightCue",
  publisherName: "Solmeriq Labs",
  platforms: ["android", "ios"],
  languages: ["en", "nl", "es"],
  storeReadyOnly: true,
  firstSourceCandidates: ["matchroom", "ufc", "glory"],
  runtimeProfile: fightCueRuntimeProfile,
}));

app.get("/v1/events", async () => ({
  items: sampleEvents,
  nextCursor: null,
}));

app.get<{ Params: { eventId: string } }>("/v1/events/:eventId", async (request, reply) => {
  const item = getEventById(request.params.eventId);

  if (!item) {
    return reply.code(404).send({
      error: "not_found",
      message: "Event not found",
    });
  }

  return { item };
});

app.get("/v1/me/profile", async () => sampleUserProfile);

app.get("/v1/me/fighters", async () => ({
  items: sampleFollowedFighters,
}));

app.get<{ Params: { fighterId: string } }>(
  "/v1/fighters/:fighterId",
  async (request, reply) => {
    const item = getFighterById(request.params.fighterId);

    if (!item) {
      return reply.code(404).send({
        error: "not_found",
        message: "Fighter not found",
      });
    }

    return {
      item,
      relatedEvents: getEventsForFighter(request.params.fighterId),
    };
  },
);

app.get("/v1/leaderboards", async () => ({
  items: sampleLeaderboards,
}));

app.get<{ Querystring: { timezone?: string; country?: string } }>(
  "/v1/sources/ufc/events",
  async (request) => {
    const parsedQuery = sourceQuerySchema.parse(request.query);

    return loadUfcEventsPreview({
      timezone: parsedQuery.timezone ?? sampleUserProfile.timezone,
      selectedCountryCode:
        parsedQuery.country?.toUpperCase() ?? sampleUserProfile.viewingCountryCode,
    });
  },
);

const port = Number(process.env.PORT || 3000);

app.listen({ port, host: "0.0.0.0" }).then(() => {
  app.log.info(`FightCue backend listening on ${port}`);
});
