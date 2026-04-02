part of 'following_screen.dart';

class _FollowingContent extends StatefulWidget {
  const _FollowingContent({
    required this.snapshotListenable,
    required this.cachedFallbackListenable,
    required this.lastSyncedAtListenable,
    required this.strings,
    required this.onOpenEvent,
    required this.onOpenFighter,
    required this.onToggleEventFollow,
    required this.onToggleFighterFollow,
  });

  final ValueListenable<HomeSnapshot> snapshotListenable;
  final ValueListenable<bool> cachedFallbackListenable;
  final ValueListenable<DateTime?> lastSyncedAtListenable;
  final AppStrings strings;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<String> onOpenFighter;
  final ValueChanged<String> onToggleEventFollow;
  final ValueChanged<String> onToggleFighterFollow;

  @override
  State<_FollowingContent> createState() => _FollowingContentState();
}

class _FollowingContentState extends State<_FollowingContent> {
  bool _showFighters = true;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeSnapshot>(
      valueListenable: widget.snapshotListenable,
      builder: (context, snapshot, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: widget.cachedFallbackListenable,
          builder: (context, usingCachedFallback, __) {
            return ValueListenableBuilder<DateTime?>(
              valueListenable: widget.lastSyncedAtListenable,
              builder: (context, lastSyncedAt, ___) {
                final isStale = usingCachedFallback &&
                    lastSyncedAt != null &&
                    DateTime.now().toUtc().difference(lastSyncedAt.toUtc()) >
                        ApiFetchResult.staleThreshold;
                final totalSaved =
                    snapshot.followedFighters.length + snapshot.followedEvents.length;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  children: [
                    EditorialPageHero(
                      eyebrow: widget.strings.following.toUpperCase(),
                      title: widget.strings.followingTitle,
                      body: widget.strings.followingSubtitle,
                      trailingLabel: '$totalSaved',
                    ),
                    const SizedBox(height: 24),
                    if (usingCachedFallback) ...[
                      EditorialNoticeCard(
                        title: widget.strings.savedPreviewTitle,
                        body: widget.strings.savedTimestampBody(
                          widget.strings.savedPreviewBody,
                          lastSyncedAt,
                          isStale: isStale,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _FavoritesSegmentedControl(
                      strings: widget.strings,
                      showFighters: _showFighters,
                      fightersCount: snapshot.followedFighters.length,
                      eventsCount: snapshot.followedEvents.length,
                      onSelectFighters: () => setState(() => _showFighters = true),
                      onSelectEvents: () => setState(() => _showFighters = false),
                    ),
                    const SizedBox(height: 16),
                    _FavoritesUtilityStrip(
                      showFighters: _showFighters,
                      fightersCount: snapshot.followedFighters.length,
                      eventsCount: snapshot.followedEvents.length,
                    ),
                    const SizedBox(height: 16),
                    EditorialSectionTitle(
                      label: _showFighters
                          ? widget.strings.followedFightersTitle
                          : widget.strings.followedEventsTitle,
                    ),
                    const SizedBox(height: 12),
                    if (_showFighters && snapshot.followedFighters.isEmpty)
                      _EmptyStateCard(
                        title: widget.strings.followedFightersEmptyTitle,
                        body: widget.strings.followedFightersEmptyBody,
                      )
                    else if (_showFighters)
                      ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _FeaturedFighterCard(
                            fighter: snapshot.followedFighters.first,
                            strings: widget.strings,
                            onOpenFighter: () =>
                                widget.onOpenFighter(snapshot.followedFighters.first.id),
                            onToggleFollow: () => widget.onToggleFighterFollow(
                              snapshot.followedFighters.first.id,
                            ),
                          ),
                        ),
                        ...snapshot.followedFighters.skip(1).map(
                          (fighter) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _FollowedFighterTile(
                              fighter: fighter,
                              strings: widget.strings,
                              onOpenFighter: () => widget.onOpenFighter(fighter.id),
                              onToggleFollow: () => widget.onToggleFighterFollow(fighter.id),
                            ),
                          ),
                        ),
                      ]
                    else if (snapshot.followedEvents.isEmpty)
                      _EmptyStateCard(
                        title: widget.strings.followedEventsEmptyTitle,
                        body: widget.strings.followedEventsEmptyBody,
                      )
                    else
                      ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _FeaturedEventCard(
                            event: snapshot.followedEvents.first,
                            strings: widget.strings,
                            onOpenEvent: () =>
                                widget.onOpenEvent(snapshot.followedEvents.first.id),
                            onToggleFollow: () => widget.onToggleEventFollow(
                              snapshot.followedEvents.first.id,
                            ),
                          ),
                        ),
                        ...snapshot.followedEvents.skip(1).map(
                          (event) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _FollowedEventCard(
                              event: event,
                              strings: widget.strings,
                              onOpenEvent: () => widget.onOpenEvent(event.id),
                              onToggleFollow: () =>
                                  widget.onToggleEventFollow(event.id),
                            ),
                          ),
                        ),
                      ],
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _FavoritesUtilityStrip extends StatelessWidget {
  const _FavoritesUtilityStrip({
    required this.showFighters,
    required this.fightersCount,
    required this.eventsCount,
  });

  final bool showFighters;
  final int fightersCount;
  final int eventsCount;

  @override
  Widget build(BuildContext context) {
    final leadLabel = showFighters ? 'Saved roster' : 'Saved calendar';
    final leadValue = showFighters ? '$fightersCount fighters' : '$eventsCount events';
    final supportLabel = showFighters ? 'Event bookmarks' : 'Tracked fighters';
    final supportValue = showFighters ? '$eventsCount ready' : '$fightersCount linked';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FavoritesUtilityMetric(
              label: leadLabel,
              value: leadValue,
            ),
          ),
          Container(
            width: 1,
            height: 38,
            color: AppColors.border,
          ),
          Expanded(
            child: _FavoritesUtilityMetric(
              label: supportLabel,
              value: supportValue,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesUtilityMetric extends StatelessWidget {
  const _FavoritesUtilityMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesSegmentedControl extends StatelessWidget {
  const _FavoritesSegmentedControl({
    required this.strings,
    required this.showFighters,
    required this.fightersCount,
    required this.eventsCount,
    required this.onSelectFighters,
    required this.onSelectEvents,
  });

  final AppStrings strings;
  final bool showFighters;
  final int fightersCount;
  final int eventsCount;
  final VoidCallback onSelectFighters;
  final VoidCallback onSelectEvents;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FavoritesTabPill(
              label: strings.followedFightersTitle,
              count: fightersCount,
              selected: showFighters,
              onTap: onSelectFighters,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _FavoritesTabPill(
              label: strings.followedEventsTitle,
              count: eventsCount,
              selected: !showFighters,
              onTap: onSelectEvents,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesTabPill extends StatelessWidget {
  const _FavoritesTabPill({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected ? AppColors.accent : Colors.transparent;
    final foreground = selected ? Colors.white : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withValues(alpha: 0.18) : AppColors.surface,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowedFighterTile extends StatelessWidget {
  const _FollowedFighterTile({
    required this.fighter,
    required this.strings,
    required this.onOpenFighter,
    required this.onToggleFollow,
  });

  final FighterSummary fighter;
  final AppStrings strings;
  final VoidCallback onOpenFighter;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${fighter.name}, ${fighter.organizationHint}, ${fighter.nextAppearanceLabel}',
      child: InkWell(
        onTap: onOpenFighter,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: [
              EditorialCardHeaderBand(
                pillLabel: fighter.organizationHint,
                title: fighter.name,
                trailingLabel: strings.trackedTagLabel.toUpperCase(),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FighterAvatar(
                      name: fighter.name,
                      size: 72,
                      showInitialsChip: false,
                      framed: true,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fighter.headline,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          EditorialMetaBand(label: fighter.nextAppearanceLabel),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: EditorialActionPill(
                                  label: strings.aboutFighterTitle,
                                  emphasized: true,
                                  onTap: onOpenFighter,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: EditorialActionPill(
                                  label: strings.unfollowAction,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedFighterCard extends StatelessWidget {
  const _FeaturedFighterCard({
    required this.fighter,
    required this.strings,
    required this.onOpenFighter,
    required this.onToggleFollow,
  });

  final FighterSummary fighter;
  final AppStrings strings;
  final VoidCallback onOpenFighter;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${fighter.name}, ${fighter.organizationHint}, ${fighter.nextAppearanceLabel}',
      child: InkWell(
        onTap: onOpenFighter,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 288,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2B2B2B),
                Color(0xFF101010),
              ],
            ),
            boxShadow: AppShadows.card,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -28,
                top: 26,
                child: FighterAvatar(
                  name: fighter.name,
                  size: 188,
                  showInitialsChip: false,
                  framed: false,
                ),
              ),
              Positioned(
                right: 18,
                top: 18,
                child: InkWell(
                  onTap: onToggleFollow,
                  borderRadius: BorderRadius.circular(999),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.favorite,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fighter.organizationHint.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFFFD5DB),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      fighter.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        height: 0.95,
                        letterSpacing: -0.9,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fighter.nextAppearanceLabel.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFFFD5DB),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
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

class _FeaturedEventCard extends StatelessWidget {
  const _FeaturedEventCard({
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
    final dateParts = event.localDateLabel.split(' ');
    final dateDay = dateParts.isNotEmpty ? dateParts.last : event.localDateLabel;

    return Semantics(
      button: true,
      label: '${event.title}, ${event.organization}, ${event.localDateLabel}',
      child: InkWell(
        onTap: onOpenEvent,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2B2B2B),
                Color(0xFF101010),
              ],
            ),
            boxShadow: AppShadows.card,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.organization.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFFFD5DB),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.9,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onToggleFollow,
                      borderRadius: BorderRadius.circular(999),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.sports_mma,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    height: 0.95,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FeaturedEventDateBlock(
                      topLabel: event.localDateLabel.toUpperCase(),
                      dayLabel: dateDay,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.localTimeLabel.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.locationLabel,
                            style: const TextStyle(
                              color: Color(0xFFFFD5DB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (mainBout != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x14FFFFFF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${mainBout.fighterAName} vs ${mainBout.fighterBName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: EditorialActionPill(
                        label: strings.viewEventDetails,
                        emphasized: true,
                        onTap: onOpenEvent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: EditorialActionPill(
                        label: strings.unfollowAction,
                        onTap: onToggleFollow,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedEventDateBlock extends StatelessWidget {
  const _FeaturedEventDateBlock({
    required this.topLabel,
    required this.dayLabel,
  });

  final String topLabel;
  final String dayLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            topLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFD5DB),
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dayLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 28,
              letterSpacing: -0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowedEventCard extends StatelessWidget {
  const _FollowedEventCard({
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
    final followedBouts =
        event.bouts.where((bout) => bout.includesFollowedFighter).length;

    return Semantics(
      button: true,
      label: '${event.title}, ${event.organization}, ${event.localDateLabel}, ${event.localTimeLabel}',
      child: InkWell(
        onTap: onOpenEvent,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EditorialCardHeaderBand(
                pillLabel: event.organization,
                title: event.title,
                trailingLabel: event.localDateLabel,
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${event.localTimeLabel}  •  ${event.locationLabel}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (mainBout == null)
                      _PendingCardNotice(strings: strings)
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _CompactFighterPreview(
                              label: mainBout.fighterAName,
                              alignEnd: false,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'VS',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _CompactFighterPreview(
                              label: mainBout.fighterBName,
                              alignEnd: true,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _Metric(
                            label: strings.followedFightersTitle,
                            value: followedBouts.toString(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _Metric(
                            label: strings.selectedCountryLabel,
                            value: event.selectedCountryCode,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: EditorialActionPill(
                            label: strings.viewEventDetails,
                            emphasized: true,
                            onTap: onOpenEvent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: EditorialActionPill(
                            label: strings.unfollowAction,
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

class _PendingCardNotice extends StatelessWidget {
  const _PendingCardNotice({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return EditorialMetaBand(label: strings.pendingCardTitle);
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactFighterPreview extends StatelessWidget {
  const _CompactFighterPreview({
    required this.label,
    required this.alignEnd,
  });

  final String label;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final avatar = FighterAvatar(
      name: label,
      size: 48,
      showInitialsChip: false,
      framed: true,
    );
    final name = Expanded(
      child: Text(
        label,
        textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );

    return Row(
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd
          ? [name, const SizedBox(width: 8), avatar]
          : [avatar, const SizedBox(width: 8), name],
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return EditorialSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
