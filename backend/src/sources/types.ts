import type {
  EventSummary,
  LeaderboardSummary,
  SourcePreview,
} from "../domain/models.js";

export type EventSourceQuery = {
  timezone: string;
  selectedCountryCode: string;
};

export type EventSourcePreview = SourcePreview<EventSummary>;
export type LeaderboardSourceQuery = EventSourceQuery;
export type LeaderboardSourcePreview = SourcePreview<LeaderboardSummary>;
