import Fastify from "fastify";
import cors from "@fastify/cors";
import rateLimit from "@fastify/rate-limit";
import dotenv from "dotenv";

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
}));

app.get("/v1/events", async () => ({
  items: [
    {
      id: "evt_demo_ufc_001",
      organization: "UFC",
      sport: "mma",
      title: "Demo Event",
      scheduledStartUtc: "2026-04-12T01:00:00Z",
      scheduledTimezone: "America/New_York",
      status: "scheduled",
      isPremiumLocked: false,
    },
  ],
  nextCursor: null,
}));

const port = Number(process.env.PORT || 3000);

app.listen({ port, host: "0.0.0.0" }).then(() => {
  app.log.info(`FightCue backend listening on ${port}`);
});
