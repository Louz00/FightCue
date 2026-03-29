import Fastify from "fastify";
import cors from "@fastify/cors";
import rateLimit from "@fastify/rate-limit";
import dotenv from "dotenv";
import { z } from "zod";

import { fightCueRuntimeProfile } from "./domain/models.js";
import {
  sampleEvents,
  sampleFollowedFighters,
  sampleLeaderboards,
  sampleUserProfile,
} from "./domain/mock-data.js";
import {
  buildRuntimeEventById,
  buildRuntimeEvents,
  buildRuntimeEventsForFighter,
  buildRuntimeFighterById,
  buildRuntimeFighters,
  buildRuntimeHome,
  buildRuntimeProfile,
} from "./domain/runtime-data.js";
import { loadUfcEventsPreview } from "./sources/ufc/ufc-events-source.js";
import { UserStateStore } from "./store/user-state-store.js";

dotenv.config();

const app = Fastify({ logger: true });

const stateStore = new UserStateStore(sampleUserProfile, {
  profile: {
    language: sampleUserProfile.language,
    timezone: sampleUserProfile.timezone,
    viewingCountryCode: sampleUserProfile.viewingCountryCode,
    premiumState: sampleUserProfile.premiumState,
    analyticsConsent: sampleUserProfile.analyticsConsent,
    adConsentGranted: sampleUserProfile.adConsentGranted,
  },
  follows: {
    fighterIds: sampleFollowedFighters.map((fighter) => fighter.id),
    eventIds: sampleEvents.filter((event) => event.isFollowed).map((event) => event.id),
  },
});

const sourceQuerySchema = z.object({
  timezone: z.string().optional(),
  country: z
    .string()
    .trim()
    .min(2)
    .max(2)
    .optional(),
});

const preferencesSchema = z.object({
  language: z.enum(["en", "nl", "es"]).optional(),
  timezone: z.string().trim().min(3).max(60).optional(),
  viewingCountryCode: z
    .string()
    .trim()
    .min(2)
    .max(2)
    .transform((value) => value.toUpperCase())
    .optional(),
});

const followSchema = z.object({
  followed: z.boolean(),
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

app.get("/v1/home", async () => {
  const state = await stateStore.read();
  return buildRuntimeHome(state);
});

app.get("/v1/events", async () => {
  const state = await stateStore.read();
  return {
    items: buildRuntimeEvents(state),
    nextCursor: null,
  };
});

app.get<{ Params: { eventId: string } }>("/v1/events/:eventId", async (request, reply) => {
  const state = await stateStore.read();
  const item = buildRuntimeEventById(state, request.params.eventId);

  if (!item) {
    return reply.code(404).send({
      error: "not_found",
      message: "Event not found",
    });
  }

  return { item };
});

app.get("/v1/me/profile", async () => {
  const state = await stateStore.read();
  return buildRuntimeProfile(state);
});

app.get("/v1/me/preferences", async () => {
  const state = await stateStore.read();
  const profile = buildRuntimeProfile(state);

  return {
    language: profile.language,
    timezone: profile.timezone,
    viewingCountryCode: profile.viewingCountryCode,
    premiumState: profile.premiumState,
  };
});

app.put<{ Body: unknown }>("/v1/me/preferences", async (request) => {
  const updates = preferencesSchema.parse(request.body);
  const state = await stateStore.updateProfile(updates);
  const profile = buildRuntimeProfile(state);

  return {
    language: profile.language,
    timezone: profile.timezone,
    viewingCountryCode: profile.viewingCountryCode,
    premiumState: profile.premiumState,
  };
});

app.get("/v1/me/fighters", async () => {
  const state = await stateStore.read();
  return {
    items: buildRuntimeFighters(state).filter((fighter) => fighter.isFollowed),
  };
});

app.put<{ Params: { fighterId: string }; Body: unknown }>(
  "/v1/me/follows/fighters/:fighterId",
  async (request, reply) => {
    const followed = followSchema.parse(request.body).followed;
    const existing = buildRuntimeFighterById(await stateStore.read(), request.params.fighterId);

    if (!existing) {
      return reply.code(404).send({
        error: "not_found",
        message: "Fighter not found",
      });
    }

    const state = await stateStore.setFollow("fighter", request.params.fighterId, followed);
    return {
      item: buildRuntimeFighterById(state, request.params.fighterId),
    };
  },
);

app.put<{ Params: { eventId: string }; Body: unknown }>(
  "/v1/me/follows/events/:eventId",
  async (request, reply) => {
    const followed = followSchema.parse(request.body).followed;
    const existing = buildRuntimeEventById(await stateStore.read(), request.params.eventId);

    if (!existing) {
      return reply.code(404).send({
        error: "not_found",
        message: "Event not found",
      });
    }

    const state = await stateStore.setFollow("event", request.params.eventId, followed);
    return {
      item: buildRuntimeEventById(state, request.params.eventId),
    };
  },
);

app.get<{ Params: { fighterId: string } }>(
  "/v1/fighters/:fighterId",
  async (request, reply) => {
    const state = await stateStore.read();
    const item = buildRuntimeFighterById(state, request.params.fighterId);

    if (!item) {
      return reply.code(404).send({
        error: "not_found",
        message: "Fighter not found",
      });
    }

    return {
      item,
      relatedEvents: buildRuntimeEventsForFighter(state, request.params.fighterId),
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
    const state = await stateStore.read();
    const profile = buildRuntimeProfile(state);

    return loadUfcEventsPreview({
      timezone: parsedQuery.timezone ?? profile.timezone,
      selectedCountryCode:
        parsedQuery.country?.toUpperCase() ?? profile.viewingCountryCode,
    });
  },
);

const port = Number(process.env.PORT || 3000);

app.listen({ port, host: "0.0.0.0" }).then(() => {
  app.log.info(`FightCue backend listening on ${port}`);
});
