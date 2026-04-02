import { randomUUID } from "node:crypto";
import Fastify, { type FastifyInstance } from "fastify";
import cors from "@fastify/cors";
import rateLimit from "@fastify/rate-limit";

import { isDemoSeedStateEnabled } from "./config/demo-state.js";
import { requestBodyLimitBytes } from "./config/http.js";
import {
  sampleEvents,
  sampleFollowedFighters,
  sampleUserProfile,
} from "./domain/mock-data.js";
import { DeviceAuthError, resolveRawDeviceId } from "./http/device-id.js";
import { readDeviceIdFromSignedToken } from "./http/session-token.js";
import { registerEventRoutes } from "./routes/event-routes.js";
import { registerFighterRoutes } from "./routes/fighter-routes.js";
import { registerMeRoutes } from "./routes/me-routes.js";
import { registerMetaRoutes } from "./routes/meta-routes.js";
import { registerSourceRoutes } from "./routes/source-routes.js";
import { setRequestContext } from "./observability/request-context.js";
import { PushDispatchWorker } from "./services/push-dispatch-worker.js";
import { PushDeliveryService } from "./services/push-delivery-service.js";
import { RuntimeService } from "./services/runtime-service.js";
import {
  createUserStateStore,
  type PersistedUserState,
  type UserStateStore,
} from "./store/user-state-store.js";

export function createInitialUserState({
  seedDemoContent = false,
}: {
  seedDemoContent?: boolean;
} = {}): Omit<PersistedUserState, "profile"> & {
  profile: Omit<PersistedUserState["profile"], "userId">;
} {
  return {
    profile: {
      language: sampleUserProfile.language,
      timezone: sampleUserProfile.timezone,
      viewingCountryCode: sampleUserProfile.viewingCountryCode,
      premiumState: sampleUserProfile.premiumState,
      analyticsConsent: sampleUserProfile.analyticsConsent,
      adConsentGranted: sampleUserProfile.adConsentGranted,
    },
    follows: {
      fighterIds: seedDemoContent
        ? sampleFollowedFighters.map((fighter) => fighter.id)
        : [],
      eventIds: seedDemoContent
        ? sampleEvents.filter((event) => event.isFollowed).map((event) => event.id)
        : [],
    },
    alerts: {
      fighters: {},
      events: {},
    },
    push: {
      pushEnabled: false,
      permissionStatus: "unknown",
    },
  };
}

export async function createDefaultUserStateStore(): Promise<UserStateStore> {
  return createUserStateStore(
    sampleUserProfile,
    createInitialUserState({
      seedDemoContent: isDemoSeedStateEnabled(),
    }),
  );
}

export async function buildApp({
  stateStore,
  runtimeService,
}: {
  stateStore?: UserStateStore;
  runtimeService?: RuntimeService;
} = {}): Promise<FastifyInstance> {
  const resolvedStateStore = stateStore ?? (await createDefaultUserStateStore());
  const app = Fastify({
    bodyLimit: requestBodyLimitBytes(),
    requestIdHeader: "x-request-id",
    genReqId: (request) => {
      const incoming = request.headers["x-request-id"];
      const requestId = Array.isArray(incoming) ? incoming[0] : incoming;
      return typeof requestId === "string" && requestId.length > 0
        ? requestId
        : randomUUID();
    },
    logger: {
      level: process.env.LOG_LEVEL ?? "info",
      base: {
        service: "fightcue-backend",
      },
    },
  });
  const resolvedRuntimeService = runtimeService ?? new RuntimeService(resolvedStateStore);
  const pushDeliveryService = new PushDeliveryService(resolvedStateStore);
  const pushDispatchWorker = new PushDispatchWorker(
    resolvedStateStore,
    pushDeliveryService,
  );

  await app.register(cors, {
    origin: process.env.CORS_ORIGIN ?? true,
  });

  app.addHook("onRequest", async (request, reply) => {
    setRequestContext({ requestId: request.id });
    reply.header("x-request-id", request.id);
  });

  await app.register(rateLimit, {
    max: 100,
    timeWindow: "1 minute",
    keyGenerator: (request) => {
      const tokenHeader = request.headers["x-fightcue-device-token"];
      const signedToken = Array.isArray(tokenHeader) ? tokenHeader[0] : tokenHeader;
      const tokenDeviceId =
        typeof signedToken === "string" && signedToken.length > 0
          ? readDeviceIdFromSignedToken(signedToken)
          : null;
      const deviceId = tokenDeviceId ?? resolveRawDeviceId(request);
      return `device:${deviceId}`;
    },
  });

  registerMetaRoutes(app, {
    stateStore: resolvedStateStore,
    pushDispatchWorker,
    runtimeService: resolvedRuntimeService,
  });
  registerEventRoutes(app, {
    stateStore: resolvedStateStore,
    runtimeService: resolvedRuntimeService,
  });
  registerFighterRoutes(app, {
    stateStore: resolvedStateStore,
    runtimeService: resolvedRuntimeService,
  });
  registerMeRoutes(app, {
    stateStore: resolvedStateStore,
    runtimeService: resolvedRuntimeService,
    pushDeliveryService,
  });
  registerSourceRoutes(app, {
    stateStore: resolvedStateStore,
    runtimeService: resolvedRuntimeService,
  });

  pushDispatchWorker.start();

  app.setErrorHandler((error, _request, reply) => {
    const message = error instanceof Error ? error.message : "Unexpected server error.";

    if (error instanceof DeviceAuthError) {
      return reply.code(error.statusCode).send({
        error: error.code,
        message,
      });
    }

    if ((error as { statusCode?: number }).statusCode) {
      return reply.code((error as { statusCode: number }).statusCode).send({
        error: "request_failed",
        message,
      });
    }

    app.log.error({ err: error }, "request.failed");
    return reply.code(500).send({
      error: "internal_error",
      message: "Unexpected server error.",
    });
  });

  app.addHook("onClose", async () => {
    pushDispatchWorker.stop();
    await resolvedStateStore.close?.();
  });

  return app;
}
