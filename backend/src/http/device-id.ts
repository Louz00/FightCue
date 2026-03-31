import type { FastifyRequest } from "fastify";

import { isSignedDeviceTokenRequired } from "../config/device-auth.js";
import {
  readDeviceIdFromSignedToken,
  sanitizeDeviceId,
} from "./session-token.js";

const DEFAULT_DEVICE_ID = "device_demo_local";

export class DeviceAuthError extends Error {
  constructor(
    message: string,
    readonly code:
      | "device_token_invalid"
      | "device_token_required"
      | "device_id_mismatch",
  ) {
    super(message);
    this.name = "DeviceAuthError";
  }

  readonly statusCode = 401;
}

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
  const rawDeviceId = resolveRawDeviceId(request);

  if (typeof signedToken === "string" && signedToken.length > 0) {
    const resolvedFromToken = readDeviceIdFromSignedToken(signedToken);

    if (!resolvedFromToken) {
      throw new DeviceAuthError(
        "Signed device token is invalid or expired.",
        "device_token_invalid",
      );
    }

    if (rawDeviceId !== DEFAULT_DEVICE_ID && rawDeviceId !== resolvedFromToken) {
      throw new DeviceAuthError(
        "Signed device token does not match the provided device id.",
        "device_id_mismatch",
      );
    }

    return resolvedFromToken;
  }

  if (isSignedDeviceTokenRequired()) {
    throw new DeviceAuthError(
      "Signed device token is required for this request.",
      "device_token_required",
    );
  }

  return rawDeviceId;
}
