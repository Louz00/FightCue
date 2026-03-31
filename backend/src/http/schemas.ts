import { z } from "zod";

export const sourceQuerySchema = z.object({
  timezone: z.string().optional(),
  country: z
    .string()
    .trim()
    .min(2)
    .max(2)
    .optional(),
});

export const preferencesSchema = z.object({
  language: z.enum(["en", "nl", "es"]).optional(),
  timezone: z.string().trim().min(3).max(60).optional(),
  viewingCountryCode: z
    .string()
    .trim()
    .min(2)
    .max(2)
    .transform((value) => value.toUpperCase())
    .optional(),
});

export const followSchema = z.object({
  followed: z.boolean(),
});

export const alertPresetSchema = z.object({
  presetKeys: z
    .array(z.enum(["before_24h", "before_1h", "time_changes", "watch_updates"]))
    .max(4),
});

export const pushSettingsSchema = z.object({
  pushEnabled: z.boolean().optional(),
  permissionStatus: z.enum(["unknown", "prompt", "granted", "denied"]).optional(),
});

export const pushTokenSchema = z.object({
  permissionStatus: z.enum(["unknown", "prompt", "granted", "denied"]),
  tokenPlatform: z.enum(["android", "ios", "web"]).optional(),
  tokenValue: z.string().trim().min(1).max(4096).optional(),
});

export const monetizationSettingsSchema = z.object({
  analyticsConsent: z.boolean().optional(),
  adConsentGranted: z.boolean().optional(),
});
