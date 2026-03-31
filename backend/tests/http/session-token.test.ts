import test from "node:test";
import assert from "node:assert/strict";

import {
  issueSignedDeviceToken,
  readDeviceIdFromSignedToken,
  sanitizeDeviceId,
} from "../../src/http/session-token.js";

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

