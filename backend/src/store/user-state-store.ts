import { isDatabaseRequired, isFileStateFallbackAllowed } from "../config/persistence.js";
import { logWarn } from "../observability/logger.js";
import type { UserProfile } from "../domain/models.js";
import { FileUserStateStore } from "./file-user-state-store.js";
import { createPostgresUserStateStore } from "./postgres-user-state-store.js";
import { getErrorMessage } from "./user-state-store.shared.js";
import type { InitialPersistedUserState, UserStateStore } from "./user-state-store.types.js";

export type { PersistedUserState, UserStateStore } from "./user-state-store.types.js";

export { createPostgresUserStateStore } from "./postgres-user-state-store.js";

export async function createUserStateStore(
  baseProfile: UserProfile,
  initialState: InitialPersistedUserState,
): Promise<UserStateStore> {
  const connectionString = process.env.DATABASE_URL ?? process.env.FIGHTCUE_DATABASE_URL;
  const requireDatabase = isDatabaseRequired();
  const allowFileFallback = isFileStateFallbackAllowed();

  if (!connectionString) {
    if (requireDatabase) {
      throw new Error(
        "FIGHTCUE_REQUIRE_DATABASE is true, but DATABASE_URL is not configured.",
      );
    }
    return new FileUserStateStore(initialState);
  }

  try {
    return await createPostgresUserStateStore(
      baseProfile,
      initialState,
      connectionString,
    );
  } catch (error) {
    if (requireDatabase || !allowFileFallback) {
      throw error;
    }
    logWarn("persistence.fallback_to_file", {
      backend: "postgres",
      fallbackBackend: "file",
      reason: getErrorMessage(error),
    });
    return new FileUserStateStore(initialState);
  }
}
