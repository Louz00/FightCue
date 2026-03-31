export function isFileStateFallbackAllowed(): boolean {
  return process.env.FIGHTCUE_ALLOW_FILE_STATE_FALLBACK === "true";
}

export function isDatabaseRequired(): boolean {
  const explicit = process.env.FIGHTCUE_REQUIRE_DATABASE;

  if (explicit === "true") {
    return true;
  }

  if (explicit === "false") {
    return false;
  }

  return !isFileStateFallbackAllowed();
}
