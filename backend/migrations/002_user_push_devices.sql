CREATE TABLE IF NOT EXISTS user_push_devices (
  user_id TEXT PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
  push_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  permission_status TEXT NOT NULL CHECK (
    permission_status IN ('unknown', 'prompt', 'granted', 'denied')
  ) DEFAULT 'unknown',
  token_platform TEXT CHECK (
    token_platform IS NULL OR token_platform IN ('android', 'ios', 'web')
  ),
  token_value TEXT,
  token_updated_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
