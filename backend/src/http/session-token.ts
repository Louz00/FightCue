import { createHmac, timingSafeEqual } from "node:crypto";

const SESSION_TOKEN_VERSION = 1;
const SESSION_TOKEN_TTL_MS = 90 * 24 * 60 * 60 * 1000;
const DEFAULT_SIGNING_SECRET = "fightcue-local-signing-secret";

type SessionTokenPayload = {
  version: number;
  deviceId: string;
  issuedAt: number;
};

export function issueSignedDeviceToken(deviceId: string): string {
  const payload: SessionTokenPayload = {
    version: SESSION_TOKEN_VERSION,
    deviceId,
    issuedAt: Date.now(),
  };
  const encodedPayload = encodeBase64Url(JSON.stringify(payload));
  const signature = sign(encodedPayload);
  return `${encodedPayload}.${signature}`;
}

export function readDeviceIdFromSignedToken(token: string): string | null {
  const [encodedPayload, providedSignature] = token.split(".");

  if (!encodedPayload || !providedSignature) {
    return null;
  }

  const expectedSignature = sign(encodedPayload);
  const provided = Buffer.from(providedSignature);
  const expected = Buffer.from(expectedSignature);

  if (provided.length !== expected.length || !timingSafeEqual(provided, expected)) {
    return null;
  }

  try {
    const payload = JSON.parse(
      decodeBase64Url(encodedPayload),
    ) as Partial<SessionTokenPayload>;

    if (
      payload.version !== SESSION_TOKEN_VERSION ||
      typeof payload.deviceId !== "string" ||
      typeof payload.issuedAt !== "number"
    ) {
      return null;
    }

    if (Date.now() - payload.issuedAt > SESSION_TOKEN_TTL_MS) {
      return null;
    }

    return sanitizeDeviceId(payload.deviceId);
  } catch {
    return null;
  }
}

function sign(encodedPayload: string): string {
  return createHmac("sha256", sessionSigningSecret())
    .update(encodedPayload)
    .digest("base64url");
}

function sessionSigningSecret(): string {
  return (
    process.env.FIGHTCUE_SESSION_SIGNING_SECRET ??
    process.env.SESSION_SIGNING_SECRET ??
    DEFAULT_SIGNING_SECRET
  );
}

function encodeBase64Url(value: string): string {
  return Buffer.from(value, "utf8").toString("base64url");
}

function decodeBase64Url(value: string): string {
  return Buffer.from(value, "base64url").toString("utf8");
}

export function sanitizeDeviceId(input: string): string {
  const normalized = input.trim().toLowerCase().replace(/[^a-z0-9_-]+/g, "_");
  return normalized.length > 0 ? normalized : "device_demo_local";
}

