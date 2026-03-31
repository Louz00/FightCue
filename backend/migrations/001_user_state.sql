CREATE TABLE IF NOT EXISTS users (
  user_id TEXT PRIMARY KEY,
  device_id TEXT NOT NULL UNIQUE,
  is_anonymous BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_preferences (
  user_id TEXT PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
  language TEXT NOT NULL CHECK (language IN ('en', 'nl', 'es')),
  timezone TEXT NOT NULL,
  viewing_country_code TEXT NOT NULL,
  premium_state TEXT NOT NULL CHECK (premium_state IN ('free', 'premium')),
  analytics_consent BOOLEAN NOT NULL DEFAULT FALSE,
  ad_consent_granted BOOLEAN NOT NULL DEFAULT FALSE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_follows (
  user_id TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  target TEXT NOT NULL CHECK (target IN ('fighter', 'event')),
  target_id TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, target, target_id)
);

CREATE INDEX IF NOT EXISTS user_follows_lookup_idx
  ON user_follows (user_id, target);

CREATE TABLE IF NOT EXISTS user_alert_presets (
  user_id TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  target TEXT NOT NULL CHECK (target IN ('fighter', 'event')),
  target_id TEXT NOT NULL,
  preset_key TEXT NOT NULL CHECK (
    preset_key IN ('before_24h', 'before_1h', 'time_changes', 'watch_updates')
  ),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, target, target_id, preset_key)
);

CREATE INDEX IF NOT EXISTS user_alert_presets_lookup_idx
  ON user_alert_presets (user_id, target, target_id);
