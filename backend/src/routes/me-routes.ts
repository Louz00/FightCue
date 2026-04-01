import type { FastifyInstance } from "fastify";

import type { RuntimeService } from "../services/runtime-service.js";
import type { PushDeliveryService } from "../services/push-delivery-service.js";
import type { UserStateStore } from "../store/user-state-store.js";
import { registerMeAlertRoutes } from "./me-alert-routes.js";
import { registerMeFollowRoutes } from "./me-follow-routes.js";
import type { MeRouteContext } from "./me-route-context.js";
import { registerMeProfileRoutes } from "./me-profile-routes.js";
import { registerMePushRoutes } from "./me-push-routes.js";

export function registerMeRoutes(
  app: FastifyInstance,
  {
    stateStore,
    runtimeService,
    pushDeliveryService,
  }: {
    stateStore: UserStateStore;
    runtimeService: RuntimeService;
    pushDeliveryService: PushDeliveryService;
  },
): void {
  const context: MeRouteContext = {
    stateStore,
    runtimeService,
    pushDeliveryService,
  };

  registerMeProfileRoutes(app, context);
  registerMeFollowRoutes(app, context);
  registerMeAlertRoutes(app, context);
  registerMePushRoutes(app, context);
}
