import type { SourceHealth, SourceMode } from "../domain/models.js";

export function buildSourceHealth({
  mode,
  parsedItemCount,
  reportedItemCount,
  checkedPageCount,
}: {
  mode: SourceMode;
  parsedItemCount: number;
  reportedItemCount?: number;
  checkedPageCount: number;
}): SourceHealth {
  const coverageGap =
    reportedItemCount == null ? 0 : Math.max(reportedItemCount - parsedItemCount, 0);
  const coverageRatio =
    reportedItemCount == null || reportedItemCount === 0
      ? undefined
      : parsedItemCount / reportedItemCount;

  if (mode === "fallback") {
    return {
      status: "fallback",
      parsedItemCount,
      reportedItemCount,
      checkedPageCount,
      coverageGap,
      coverageRatio,
    };
  }

  return {
    status: coverageGap > 0 ? "degraded" : "healthy",
    parsedItemCount,
    reportedItemCount,
    checkedPageCount,
    coverageGap,
    coverageRatio,
  };
}
