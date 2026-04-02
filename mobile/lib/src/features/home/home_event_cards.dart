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
    final dateParts = event.localDateLabel.split(' ');
    final dateDay = dateParts.isNotEmpty ? dateParts.last : event.localDateLabel;
    final heroTitle = mainBout == null
        ? event.title.toUpperCase()
        : '${mainBout.fighterAName.toUpperCase()}\nVS ${mainBout.fighterBName.toUpperCase()}';
    final heroDetail = mainBout?.weightClass ?? mainBout?.slotLabel ?? event.organization;

    return Semantics(
      button: true,
      label: '${event.title}. ${event.localDateLabel} ${event.localTimeLabel}.',
      child: InkWell(
        onTap: onOpenEvent,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2B2B2B),
                Color(0xFF111111),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
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
                    Text(
                      '${event.organization.toUpperCase()}  •  ${event.locationLabel.toUpperCase()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFFD5DB),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.9,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      heroTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                        height: 0.92,
                        letterSpacing: -1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DateBlock(
                          topLabel: event.localDateLabel.toUpperCase(),
                          dayLabel: dateDay,
                          inverse: true,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _EventMetaLine(
                            primary: event.localTimeLabel,
                            secondary: event.locationLabel,
                            inverse: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (mainBout == null)
                      _PendingFightCard(strings: strings)
                    else ...[
                      _HeroMetricStrip(
                        leftLabel: 'Main event time',
                        leftValue: event.localTimeLabel,
                        rightLabel: 'Division',
                        rightValue: heroDetail,
                      ),
                      const SizedBox(height: 16),
                      _EventFaceoffPreview(
                        bout: mainBout,
                        prominent: true,
                        inverse: true,
                      ),
                    ],
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
                            icon: Icons.sports_mma,
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

class _HeroMetricStrip extends StatelessWidget {
  const _HeroMetricStrip({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _HeroMetric(
              label: leftLabel,
              value: leftValue,
            ),
          ),
          Container(
            width: 1,
            height: 34,
            color: const Color(0x24FFFFFF),
          ),
          Expanded(
            child: _HeroMetric(
              label: rightLabel,
              value: rightValue,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
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
              color: Color(0xFFFFD5DB),
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: -0.2,
            ),
          ),
        ],
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
    final dateParts = event.localDateLabel.split(' ');
    final dateDay = dateParts.isNotEmpty ? dateParts.last : event.localDateLabel;

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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DateBlock(
                            topLabel: event.localDateLabel.toUpperCase(),
                            dayLabel: dateDay,
                            compact: true,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _EventMetaLine(
                              primary: event.localTimeLabel,
                              secondary: event.locationLabel,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (mainBout == null)
                        _PendingFightCard(strings: strings)
                      else
                        _EventFaceoffPreview(bout: mainBout),
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
                      icon: Icons.sports_mma,
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

class _DateBlock extends StatelessWidget {
  const _DateBlock({
    required this.topLabel,
    required this.dayLabel,
    this.compact = false,
    this.inverse = false,
  });

  final String topLabel;
  final String dayLabel;
  final bool compact;
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final background = inverse
        ? const Color(0x16FFFFFF)
        : AppColors.surfaceAltFor(context);
    final topColor = inverse
        ? const Color(0xFFFFD5DB)
        : AppColors.textSecondaryFor(context);
    final dayColor = inverse ? Colors.white : AppColors.textPrimaryFor(context);

    return Container(
      width: compact ? 82 : 92,
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            topLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: topColor,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dayLabel,
            style: TextStyle(
              color: dayColor,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 24 : 28,
              letterSpacing: -0.8,
            ),
          ),
        ],
      ),
    );
  }
}
