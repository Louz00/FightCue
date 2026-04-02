import type { FastifyInstance } from "fastify";

import { isDemoSeedStateEnabled } from "../config/demo-state.js";
import { isSignedDeviceTokenRequired } from "../config/device-auth.js";
import { requestBodyLimitBytes } from "../config/http.js";
import { isDatabaseRequired, isFileStateFallbackAllowed } from "../config/persistence.js";
import { sampleLeaderboards } from "../domain/mock-data.js";
import { fightCueRuntimeProfile } from "../domain/models.js";
import { resolveRawDeviceId } from "../http/device-id.js";
import { issueSignedDeviceToken } from "../http/session-token.js";
import type { PushDispatchWorker } from "../services/push-dispatch-worker.js";
import type { RuntimeService } from "../services/runtime-service.js";
import type { UserStateStore } from "../store/user-state-store.js";

export function registerMetaRoutes(
  app: FastifyInstance,
  {
    stateStore,
    pushDispatchWorker,
    runtimeService,
  }: {
    stateStore: UserStateStore;
    pushDispatchWorker: PushDispatchWorker;
    runtimeService: RuntimeService;
  },
): void {
  app.get("/health", async () => {
    const persistenceHealth = await stateStore.getHealth?.();
    const pushWorkerStatus = pushDispatchWorker.getStatus();
    return {
      ok:
        persistenceHealth?.status !== "degraded" &&
        pushWorkerStatus.healthStatus !== "degraded",
      service: "fightcue-backend",
      persistenceBackend: stateStore.backendLabel,
      persistenceHealth,
      databaseRequired: isDatabaseRequired(),
      fileFallbackAllowed: isFileStateFallbackAllowed(),
      signedDeviceTokenRequired: isSignedDeviceTokenRequired(),
      demoSeedStateEnabled: isDemoSeedStateEnabled(),
      requestBodyLimitBytes: requestBodyLimitBytes(),
      pushWorker: pushWorkerStatus,
      runtimeObservability: runtimeService.getObservabilitySnapshot(),
    };
  });

  app.get("/v1/meta", async () => {
    const persistenceHealth = await stateStore.getHealth?.();
    return {
      appName: "FightCue",
      publisherName: "Solmeriq Labs",
      platforms: ["android", "ios"],
      languages: ["en", "nl", "es"],
      storeReadyOnly: true,
      firstSourceCandidates: ["matchroom", "ufc", "glory"],
      persistenceBackend: stateStore.backendLabel,
      persistenceHealth,
      databaseRequired: isDatabaseRequired(),
      fileFallbackAllowed: isFileStateFallbackAllowed(),
      signedDeviceTokenRequired: isSignedDeviceTokenRequired(),
      demoSeedStateEnabled: isDemoSeedStateEnabled(),
      requestBodyLimitBytes: requestBodyLimitBytes(),
      pushWorker: pushDispatchWorker.getStatus(),
      runtimeObservability: runtimeService.getObservabilitySnapshot(),
      runtimeProfile: fightCueRuntimeProfile,
    };
  });

  app.get("/v1/leaderboards", async () => ({
    items: sampleLeaderboards,
  }));

  app.post("/v1/session/bootstrap", async (request) => {
    const deviceId = resolveRawDeviceId(request);

    return {
      deviceId,
      deviceToken: issueSignedDeviceToken(deviceId),
      tokenType: "anonymous_hmac",
      expiresInDays: 90,
    };
  });
}
