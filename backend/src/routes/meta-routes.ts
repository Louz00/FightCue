import type { FastifyInstance } from "fastify";

import { sampleLeaderboards } from "../domain/mock-data.js";
import { fightCueRuntimeProfile } from "../domain/models.js";
import type { UserStateStore } from "../store/user-state-store.js";

export function registerMetaRoutes(
  app: FastifyInstance,
  { stateStore }: { stateStore: UserStateStore },
): void {
  app.get("/health", async () => ({
    ok: true,
    service: "fightcue-backend",
    persistenceBackend: stateStore.backendLabel,
    databaseRequired: process.env.FIGHTCUE_REQUIRE_DATABASE === "true",
  }));

  app.get("/v1/meta", async () => ({
    appName: "FightCue",
    publisherName: "Solmeriq Labs",
    platforms: ["android", "ios"],
    languages: ["en", "nl", "es"],
    storeReadyOnly: true,
    firstSourceCandidates: ["matchroom", "ufc", "glory"],
    persistenceBackend: stateStore.backendLabel,
    databaseRequired: process.env.FIGHTCUE_REQUIRE_DATABASE === "true",
    runtimeProfile: fightCueRuntimeProfile,
  }));

  app.get("/v1/leaderboards", async () => ({
    items: sampleLeaderboards,
  }));
}
