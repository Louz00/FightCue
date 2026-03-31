export function countMatchroomUpcomingCards(upcomingSectionHtml: string): number {
  return (upcomingSectionHtml.match(/<div class="fight-card">/g) ?? []).length;
}

export function buildMatchroomValidationWarnings({
  parsedItemCount,
  reportedUpcomingCount,
}: {
  parsedItemCount: number;
  reportedUpcomingCount?: number;
}): string[] {
  const warnings = [
    "Matchroom timing is currently derived from official event pages, but broadcast availability is still a pilot.",
  ];

  if (
    reportedUpcomingCount != null &&
    parsedItemCount < reportedUpcomingCount
  ) {
    warnings.push(
      `Matchroom source coverage is below the official card count (${parsedItemCount}/${reportedUpcomingCount}).`,
    );
  }

  return warnings;
}
