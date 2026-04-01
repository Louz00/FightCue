import test from "node:test";
import assert from "node:assert/strict";

import {
  issueSignedDeviceToken,
  readDeviceIdFromSignedToken,
  sanitizeDeviceId,
} from "../../src/http/session-token.js";

test.afterEach(() => {
  delete process.env.FIGHTCUE_SESSION_SIGNING_SECRET;
  delete process.env.SESSION_SIGNING_SECRET;
  delete process.env.FIGHTCUE_ALLOW_INSECURE_LOCAL_SIGNING_SECRET;
  process.env.NODE_ENV = "test";
});

test("sanitizeDeviceId normalizes raw client ids", () => {
  assert.equal(
    sanitizeDeviceId(" Device:ABC 123 "),
    "device_abc_123",
  );
});

test("signed device tokens roundtrip the sanitized device id", () => {
  const token = issueSignedDeviceToken("device_route_test");
  assert.equal(readDeviceIdFromSignedToken(token), "device_route_test");
});

test("signed device tokens reject tampering", () => {
  const token = issueSignedDeviceToken("device_route_test");
  const tampered = `${token}tampered`;
  assert.equal(readDeviceIdFromSignedToken(tampered), null);
});

test("signed device tokens require an explicit secret outside local environments", () => {
  delete process.env.FIGHTCUE_SESSION_SIGNING_SECRET;
  delete process.env.SESSION_SIGNING_SECRET;
  process.env.NODE_ENV = "production";

  assert.throws(
    () => issueSignedDeviceToken("device_route_test"),
    /FIGHTCUE_SESSION_SIGNING_SECRET/,
  );
});

test("signed device tokens use the configured secret in production", () => {
  process.env.NODE_ENV = "production";
  process.env.FIGHTCUE_SESSION_SIGNING_SECRET = "fightcue_prod_secret";

  const token = issueSignedDeviceToken("device_route_test");
  assert.equal(readDeviceIdFromSignedToken(token), "device_route_test");
});

test("development fallback signing secret requires explicit opt-in", () => {
  process.env.NODE_ENV = "development";
  delete process.env.FIGHTCUE_SESSION_SIGNING_SECRET;
  delete process.env.SESSION_SIGNING_SECRET;
  delete process.env.FIGHTCUE_ALLOW_INSECURE_LOCAL_SIGNING_SECRET;

  assert.throws(
    () => issueSignedDeviceToken("device_route_test"),
    /FIGHTCUE_SESSION_SIGNING_SECRET/,
  );

  process.env.FIGHTCUE_ALLOW_INSECURE_LOCAL_SIGNING_SECRET = "true";
  const token = issueSignedDeviceToken("device_route_test");
  assert.equal(readDeviceIdFromSignedToken(token), "device_route_test");
});
