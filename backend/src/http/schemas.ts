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
