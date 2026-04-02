part of 'home_screen.dart';

class _HeroEventCard extends StatelessWidget {
  const _HeroEventCard({
    required this.event,
    required this.strings,
    required this.onOpenEvent,
    required this.onToggleFollow,
  });

  final EventSummary event;
  final AppStrings strings;
  final VoidCallback onOpenEvent;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final mainBout = headlineBoutForEvent(event);
    final primaryWatchProvider = primaryWatchProviderLabel(event);
    final watchLabel = primaryWatchProvider == null
        ? event.sourceLabel
        : '${strings.whereToWatch}: $primaryWatchProvider';

    return Semantics(
      button: true,
      label: '${event.title}. ${event.localDateLabel} ${event.localTimeLabel}.',
      child: InkWell(
        onTap: onOpenEvent,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(context),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.borderFor(context)),
            boxShadow: AppShadows.cardFor(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EventCardHeader(
                event: event,
                trailingLabel: strings.mainEventBannerLabel.toUpperCase(),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EventMetaLine(
                      primary: '${event.localDateLabel}  •  ${event.localTimeLabel}',
                      secondary: event.locationLabel,
                    ),
                    const SizedBox(height: 16),
                    if (mainBout == null)
                      _PendingFightCard(strings: strings)
                    else
                      _EventFaceoffPreview(
                        bout: mainBout,
                        prominent: true,
                      ),
                    const SizedBox(height: 14),
                    _WatchInfoBand(label: watchLabel),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionPill(
                            label: strings.viewEventDetails,
                            emphasized: true,
                            onTap: onOpenEvent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ActionPill(
                            label: event.isFollowed
                                ? strings.unfollowAction
                                : strings.followAction,
                            onTap: onToggleFollow,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandableEventCard extends StatelessWidget {
  const _ExpandableEventCard({
    required this.event,
    required this.strings,
    required this.onOpenEvent,
    required this.onOpenFighter,
    required this.onToggleFollow,
  });

  final EventSummary event;
  final AppStrings strings;
  final VoidCallback onOpenEvent;
  final ValueChanged<String> onOpenFighter;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final mainBout = headlineBoutForEvent(event);
    final primaryWatchProvider = primaryWatchProviderLabel(event);
    final watchLabel = primaryWatchProvider == null
        ? event.sourceLabel
        : '${strings.whereToWatch}: $primaryWatchProvider';

    return Semantics(
      container: true,
      label: '${event.title}. ${event.localDateLabel} ${event.localTimeLabel}.',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadows.cardFor(context),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EventCardHeader(
                  event: event,
                  trailingLabel: event.localDateLabel,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EventMetaLine(
                        primary: event.localTimeLabel,
                        secondary: event.locationLabel,
                      ),
                      const SizedBox(height: 14),
                      if (mainBout == null)
                        _PendingFightCard(strings: strings)
                      else
                        _EventFaceoffPreview(bout: mainBout),
                      const SizedBox(height: 12),
                      _WatchInfoBand(label: watchLabel),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Text(
                strings.expandCardHint,
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ActionPill(
                      label: strings.viewEventDetails,
                      emphasized: true,
                      onTap: onOpenEvent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionPill(
                      label: event.isFollowed
                          ? strings.unfollowAction
                          : strings.followAction,
                      onTap: onToggleFollow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                strings.openFighterHint,
                style: TextStyle(
                  color: AppColors.textSecondaryFor(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              if (event.bouts.isEmpty)
                _PendingFightCard(strings: strings)
              else
                ...event.bouts.map(
                  (bout) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _BoutPreviewTile(
                      bout: bout,
                      strings: strings,
                      onOpenFighter: onOpenFighter,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
