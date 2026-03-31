import type { FastifyRequest } from "fastify";

const DEFAULT_DEVICE_ID = "device_demo_local";

export function resolveDeviceId(request: FastifyRequest): string {
  const rawHeader = request.headers["x-fightcue-device-id"];
  const firstValue = Array.isArray(rawHeader) ? rawHeader[0] : rawHeader;

  if (!firstValue) {
    return DEFAULT_DEVICE_ID;
  }

  const normalized = firstValue.trim().toLowerCase().replace(/[^a-z0-9_-]+/g, "_");
  return normalized.length > 0 ? normalized : DEFAULT_DEVICE_ID;
}
