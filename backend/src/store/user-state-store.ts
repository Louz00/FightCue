import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";

import type {
  PremiumState,
  SupportedLanguage,
  UserProfile,
} from "../domain/models.js";

export type PersistedUserState = {
  profile: {
    language: SupportedLanguage;
    timezone: string;
    viewingCountryCode: string;
    premiumState: PremiumState;
    analyticsConsent: boolean;
    adConsentGranted: boolean;
  };
  follows: {
    fighterIds: string[];
    eventIds: string[];
  };
};

export class UserStateStore {
  constructor(
    private readonly baseProfile: UserProfile,
    private readonly initialState: PersistedUserState,
  ) {}

  private readonly filePath = path.resolve(process.cwd(), ".data", "user-state.json");
  private writeQueue = Promise.resolve();

  async read(): Promise<PersistedUserState> {
    try {
      const raw = await readFile(this.filePath, "utf8");
      const parsed = JSON.parse(raw) as Partial<PersistedUserState>;

      return {
        profile: {
          language:
            parsed.profile?.language ?? this.initialState.profile.language,
          timezone:
            parsed.profile?.timezone ?? this.initialState.profile.timezone,
          viewingCountryCode:
            parsed.profile?.viewingCountryCode ??
            this.initialState.profile.viewingCountryCode,
          premiumState:
            parsed.profile?.premiumState ??
            this.initialState.profile.premiumState,
          analyticsConsent:
            parsed.profile?.analyticsConsent ??
            this.initialState.profile.analyticsConsent,
          adConsentGranted:
            parsed.profile?.adConsentGranted ??
            this.initialState.profile.adConsentGranted,
        },
        follows: {
          fighterIds: parsed.follows?.fighterIds ?? this.initialState.follows.fighterIds,
          eventIds: parsed.follows?.eventIds ?? this.initialState.follows.eventIds,
        },
      };
    } catch {
      await this.write(this.initialState);
      return structuredClone(this.initialState);
    }
  }

  async updateProfile(
    updates: Partial<PersistedUserState["profile"]>,
  ): Promise<PersistedUserState> {
    return this.enqueue(async () => {
      const current = await this.read();
      const next: PersistedUserState = {
        ...current,
        profile: {
          ...current.profile,
          ...updates,
        },
      };
      await this.write(next);
      return next;
    });
  }

  async setFollow(
    target: "fighter" | "event",
    targetId: string,
    followed: boolean,
  ): Promise<PersistedUserState> {
    return this.enqueue(async () => {
      const current = await this.read();
      const key = target === "fighter" ? "fighterIds" : "eventIds";
      const set = new Set(current.follows[key]);

      if (followed) {
        set.add(targetId);
      } else {
        set.delete(targetId);
      }

      const next: PersistedUserState = {
        ...current,
        follows: {
          ...current.follows,
          [key]: [...set],
        },
      };

      await this.write(next);
      return next;
    });
  }

  private async write(state: PersistedUserState): Promise<void> {
    await mkdir(path.dirname(this.filePath), { recursive: true });
    await writeFile(this.filePath, JSON.stringify(state, null, 2), "utf8");
  }

  private async enqueue<T>(task: () => Promise<T>): Promise<T> {
    const result = this.writeQueue.then(task);
    this.writeQueue = result.then(
      () => undefined,
      () => undefined,
    );
    return result;
  }
}
