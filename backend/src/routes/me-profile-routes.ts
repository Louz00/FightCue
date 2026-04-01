import type { FastifyInstance } from "fastify";

import { buildRuntimeMonetization, buildRuntimeProfile } from "../domain/runtime-data.js";
import {
  getAdProviderStatus,
  getBillingProviderStatus,
} from "../config/monetization-providers.js";
import { resolveDeviceId } from "../http/device-id.js";
import {
  monetizationSettingsSchema,
  preferencesSchema,
} from "../http/schemas.js";
import type { MeRouteContext } from "./me-route-context.js";

export function registerMeProfileRoutes(
  app: FastifyInstance,
  { stateStore }: MeRouteContext,
): void {
  app.get("/v1/me/profile", async (request) => {
    const deviceId = resolveDeviceId(request);
    const state = await stateStore.read(deviceId);
    return buildRuntimeProfile(state);
  });

  app.get("/v1/me/preferences", async (request) => {
    const deviceId = resolveDeviceId(request);
    const state = await stateStore.read(deviceId);
    const profile = buildRuntimeProfile(state);

    return {
      language: profile.language,
      timezone: profile.timezone,
      viewingCountryCode: profile.viewingCountryCode,
      premiumState: profile.premiumState,
    };
  });

  app.put<{ Body: unknown }>("/v1/me/preferences", async (request) => {
    const deviceId = resolveDeviceId(request);
    const updates = preferencesSchema.parse(request.body);
    const state = await stateStore.updateProfile(deviceId, updates);
    const profile = buildRuntimeProfile(state);

    return {
      language: profile.language,
      timezone: profile.timezone,
      viewingCountryCode: profile.viewingCountryCode,
      premiumState: profile.premiumState,
    };
  });

  app.get("/v1/me/monetization", async (request) => {
    const deviceId = resolveDeviceId(request);
    const state = await stateStore.read(deviceId);
    return buildRuntimeMonetization(state);
  });

  app.get("/v1/me/billing/provider", async () => {
    return getBillingProviderStatus();
  });

  app.get("/v1/me/ads/provider", async () => {
    return getAdProviderStatus();
  });

  app.put<{ Body: unknown }>("/v1/me/monetization/settings", async (request) => {
    const deviceId = resolveDeviceId(request);
    const updates = monetizationSettingsSchema.parse(request.body);
    const state = await stateStore.updateProfile(deviceId, updates);
    return buildRuntimeMonetization(state);
  });
}
