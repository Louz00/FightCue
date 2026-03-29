import Fastify from "fastify";
import cors from "@fastify/cors";
import rateLimit from "@fastify/rate-limit";
import dotenv from "dotenv";
import {
  fightCueRuntimeProfile,
} from "./domain/models.js";
import {
  sampleEvents,
  sampleFollowedFighters,
  sampleLeaderboards,
  sampleUserProfile,
} from "./domain/mock-data.js";

dotenv.config();

const app = Fastify({ logger: true });

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

app.get("/v1/me/profile", async () => sampleUserProfile);

app.get("/v1/me/fighters", async () => ({
  items: sampleFollowedFighters,
}));

app.get("/v1/leaderboards", async () => ({
  items: sampleLeaderboards,
}));

const port = Number(process.env.PORT || 3000);

app.listen({ port, host: "0.0.0.0" }).then(() => {
  app.log.info(`FightCue backend listening on ${port}`);
});
