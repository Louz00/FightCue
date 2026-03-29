import type { EventSummary, SourcePreview } from "../domain/models.js";

export type EventSourceQuery = {
  timezone: string;
  selectedCountryCode: string;
};

export type EventSourcePreview = SourcePreview<EventSummary>;
