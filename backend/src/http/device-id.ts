import type { FastifyRequest } from "fastify";

import {
  readDeviceIdFromSignedToken,
  sanitizeDeviceId,
} from "./session-token.js";

const DEFAULT_DEVICE_ID = "device_demo_local";

export function resolveRawDeviceId(request: FastifyRequest): string {
  const rawHeader = request.headers["x-fightcue-device-id"];
  const firstValue = Array.isArray(rawHeader) ? rawHeader[0] : rawHeader;

  if (!firstValue) {
    return DEFAULT_DEVICE_ID;
  }

  return sanitizeDeviceId(firstValue);
}

export function resolveDeviceId(request: FastifyRequest): string {
  const tokenHeader = request.headers["x-fightcue-device-token"];
  const signedToken = Array.isArray(tokenHeader) ? tokenHeader[0] : tokenHeader;
  const resolvedFromToken =
    typeof signedToken === "string" ? readDeviceIdFromSignedToken(signedToken) : null;

  if (resolvedFromToken) {
    return resolvedFromToken;
  }

  return resolveRawDeviceId(request);
}
