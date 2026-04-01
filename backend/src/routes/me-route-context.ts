import type { RuntimeService } from "../services/runtime-service.js";
import type { PushDeliveryService } from "../services/push-delivery-service.js";
import type { UserStateStore } from "../store/user-state-store.js";

export type MeRouteContext = {
  stateStore: UserStateStore;
  runtimeService: RuntimeService;
  pushDeliveryService: PushDeliveryService;
};
