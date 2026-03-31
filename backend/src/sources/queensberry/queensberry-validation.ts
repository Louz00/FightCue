export function countQueensberryHeroCards(html: string): number {
  return (
    html.match(
      /class="custom-image-banner-section events-page-banner event-third-banner mob-page-banner-wrapper"/g,
    ) ?? []
  ).length;
}

export function buildQueensberryValidationWarnings({
  parsedItemCount,
  reportedUpcomingCount,
}: {
  parsedItemCount: number;
  reportedUpcomingCount?: number;
}): string[] {
  const warnings = [
    "Queensberry watch-provider coverage is still being enriched from official event copy and may be incomplete for some cards.",
  ];

  if (
    reportedUpcomingCount != null &&
    parsedItemCount < reportedUpcomingCount
  ) {
    warnings.push(
      `Queensberry source coverage is below the official hero-card count (${parsedItemCount}/${reportedUpcomingCount}).`,
    );
  }

  return warnings;
}
