part of 'event_detail_screen.dart';

class _EventDetailStatusBanner extends StatelessWidget {
  const _EventDetailStatusBanner({
    required this.fetchedResult,
    required this.hasError,
    required this.strings,
    required this.onRetry,
  });

  final ApiFetchResult<EventDetailSnapshot>? fetchedResult;
  final bool hasError;
  final AppStrings strings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (fetchedResult?.isFromCache ?? false) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: EditorialNoticeCard(
          title: strings.savedDetailTitle,
          body: strings.savedTimestampBody(
            strings.savedDetailBody,
            fetchedResult?.lastSyncedAt,
            isStale: fetchedResult?.isStaleCache ?? false,
          ),
          actionLabel: strings.retryAction,
          onAction: onRetry,
        ),
      );
    }

    if (!hasError) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: EditorialNoticeCard(
        title: strings.detailFallbackTitle,
        body: strings.detailFallbackBody,
        actionLabel: strings.retryAction,
        onAction: onRetry,
      ),
    );
  }
}

class _EventDetailBoutSection extends StatelessWidget {
  const _EventDetailBoutSection({
    required this.visibleBouts,
    required this.event,
    required this.snapshot,
    required this.strings,
    required this.onOpenFighter,
    required this.onToggleFighterFollow,
  });

  final List<BoutSummary> visibleBouts;
  final EventSummary event;
  final HomeSnapshot snapshot;
  final AppStrings strings;
  final ValueChanged<String> onOpenFighter;
  final ValueChanged<String> onToggleFighterFollow;

  @override
  Widget build(BuildContext context) {
    if (visibleBouts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _EmptyFightCardCard(strings: strings),
      );
    }

    return Column(
      children: visibleBouts.map((bout) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: _EditorialBoutTile(
            event: event,
            bout: bout,
            fighterA: snapshot.fighterById(bout.fighterAId),
            fighterB: snapshot.fighterById(bout.fighterBId),
            onOpenFighter: onOpenFighter,
            onToggleFighterFollow: onToggleFighterFollow,
          ),
        );
      }).toList(),
    );
  }
}

class _EventDetailInfoSections extends StatelessWidget {
  const _EventDetailInfoSections({
    required this.event,
    required this.strings,
  });

  final EventSummary event;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (event.watchProviders.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _PanelTitle(label: strings.watchProvidersTitle),
          ),
          const SizedBox(height: 12),
          ...event.watchProviders.map(
            (provider) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: _ProviderCard(
                provider: provider,
                strings: strings,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _PanelTitle(label: strings.eventOverviewTitle),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _OverviewCard(
            event: event,
            strings: strings,
          ),
        ),
      ],
    );
  }
}
