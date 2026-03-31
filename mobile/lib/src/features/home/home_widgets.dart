part of 'home_screen.dart';

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background =
        selected ? AppColors.accent : AppColors.surfaceFor(context);
    final borderColor =
        selected ? AppColors.accent : AppColors.borderFor(context);
    final textColor =
        selected ? Colors.white : AppColors.textPrimaryFor(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadows.cardFor(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.noFilteredEventsTitle,
              style: TextStyle(
                color: AppColors.textPrimaryFor(context),
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              strings.noFilteredEventsBody,
              style: TextStyle(
                color: AppColors.textSecondaryFor(context),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFollowedFightersCard extends StatelessWidget {
  const _EmptyFollowedFightersCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadows.cardFor(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.followedFightersEmptyTitle,
              style: TextStyle(
                color: AppColors.textPrimaryFor(context),
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              strings.followedFightersEmptyBody,
              style: TextStyle(
                color: AppColors.textSecondaryFor(context),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.textPrimaryFor(context);

    return Row(
      children: [
        Semantics(
          header: true,
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor,
                ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 2,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

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
                    _WatchInfoBand(
                      label: watchLabel,
                    ),
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

class _FollowedFighterCard extends StatelessWidget {
  const _FollowedFighterCard({
    required this.fighter,
    required this.strings,
    required this.onTap,
  });

  final FighterSummary fighter;
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);

    return Semantics(
      button: true,
      label: '${fighter.name}. ${fighter.organizationHint}. ${fighter.nextAppearanceLabel}.',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 216,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderFor(context)),
            boxShadow: AppShadows.cardFor(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.trackedTagLabel.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.accent,
                    ),
              ),
              const SizedBox(height: 12),
              FighterAvatar(
                name: fighter.name,
                size: 60,
                showInitialsChip: false,
                framed: true,
              ),
              const SizedBox(height: 10),
              Text(
                fighter.name,
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                fighter.organizationHint,
                style: TextStyle(color: textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAltFor(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  fighter.nextAppearanceLabel,
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuietAdFoundationSlot extends StatelessWidget {
  const _QuietAdFoundationSlot({
    required this.strings,
    required this.adsEnabled,
  });

  final AppStrings strings;
  final bool adsEnabled;

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);

    return Semantics(
      container: true,
      label: strings.quietAdsTitle,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadows.cardFor(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAltFor(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    strings.sponsoredLabel.toUpperCase(),
                    style: TextStyle(
                      color: textSecondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                _InversePill(
                  label: adsEnabled
                      ? strings.quietAdsEnabledLabel
                      : strings.quietAdsDisabledLabel,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              strings.quietAdSlotTitle,
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              adsEnabled ? strings.quietAdSlotBody : strings.quietAdsConsentBody,
              style: TextStyle(
                color: textSecondary,
                height: 1.45,
              ),
            ),
          ],
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
                      _EventFaceoffPreview(
                        bout: mainBout,
                      ),
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

class _PendingFightCard extends StatelessWidget {
  const _PendingFightCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltFor(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.pendingCardTitle,
            style: TextStyle(
              color: AppColors.textPrimaryFor(context),
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.pendingCardBody,
            style: TextStyle(
              color: AppColors.textSecondaryFor(context),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCardHeader extends StatelessWidget {
  const _EventCardHeader({
    required this.event,
    required this.trailingLabel,
  });

  final EventSummary event;
  final String trailingLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _InversePill(label: event.organization),
              const Spacer(),
              Text(
                trailingLabel,
                style: const TextStyle(
                  color: Color(0xFFFFE4E8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              height: 1.06,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventMetaLine extends StatelessWidget {
  const _EventMetaLine({
    required this.primary,
    required this.secondary,
  });

  final String primary;
  final String secondary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          primary,
          style: TextStyle(
            color: AppColors.textPrimaryFor(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          secondary,
          style: TextStyle(
            color: AppColors.textSecondaryFor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EventFaceoffPreview extends StatelessWidget {
  const _EventFaceoffPreview({
    required this.bout,
    this.prominent = false,
  });

  final BoutSummary bout;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final avatarSize = prominent ? 72.0 : 58.0;
    final nameStyle = TextStyle(
      color: AppColors.textPrimaryFor(context),
      fontWeight: FontWeight.w800,
      fontSize: prominent ? 18 : 16,
      letterSpacing: -0.3,
    );

    return Row(
      children: [
        Expanded(
          child: _PreviewFighterSide(
            name: bout.fighterAName,
            avatarSize: avatarSize,
            alignEnd: false,
            nameStyle: nameStyle,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: EdgeInsets.symmetric(
            horizontal: prominent ? 12 : 10,
            vertical: prominent ? 12 : 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceAltFor(context),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Text(
                bout.slotLabel.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.4,
                ),
              ),
              if (bout.weightClass != null) ...[
                const SizedBox(height: 6),
                Text(
                  bout.weightClass!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: _PreviewFighterSide(
            name: bout.fighterBName,
            avatarSize: avatarSize,
            alignEnd: true,
            nameStyle: nameStyle,
          ),
        ),
      ],
    );
  }
}

class _PreviewFighterSide extends StatelessWidget {
  const _PreviewFighterSide({
    required this.name,
    required this.avatarSize,
    required this.alignEnd,
    required this.nameStyle,
  });

  final String name;
  final double avatarSize;
  final bool alignEnd;
  final TextStyle nameStyle;

  @override
  Widget build(BuildContext context) {
    final avatar = FighterAvatar(
      name: name,
      size: avatarSize,
      showInitialsChip: false,
      framed: true,
    );
    final label = Expanded(
      child: Text(
        name,
        textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        style: nameStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );

    return Row(
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd
          ? [
              label,
              const SizedBox(width: 10),
              avatar,
            ]
          : [
              avatar,
              const SizedBox(width: 10),
              label,
            ],
    );
  }
}

class _WatchInfoBand extends StatelessWidget {
  const _WatchInfoBand({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceAltFor(context),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimaryFor(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InversePill extends StatelessWidget {
  const _InversePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.inkFor(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.onTap,
    this.emphasized = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final background = emphasized
        ? AppColors.accent
        : AppColors.surfaceFor(context);
    final textColor = emphasized ? Colors.white : AppColors.accent;
    final borderColor = AppColors.accent;

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _BoutPreviewTile extends StatelessWidget {
  const _BoutPreviewTile({
    required this.bout,
    required this.strings,
    required this.onOpenFighter,
  });

  final BoutSummary bout;
  final AppStrings strings;
  final ValueChanged<String> onOpenFighter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltFor(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bout.slotLabel,
                  style: TextStyle(
                    color: AppColors.textSecondaryFor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (bout.weightClass != null)
                Text(
                  bout.weightClass!,
                  style: TextStyle(
                    color: AppColors.textSecondaryFor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (bout.includesFollowedFighter)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    strings.followedTagLabel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CompactFighterPreview(
                  label: bout.fighterAName,
                  alignEnd: false,
                  onTap: () => onOpenFighter(bout.fighterAId),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'VS',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: _CompactFighterPreview(
                  label: bout.fighterBName,
                  alignEnd: true,
                  onTap: () => onOpenFighter(bout.fighterBId),
                ),
              ),
            ],
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
    required this.onTap,
  });

  final String label;
  final bool alignEnd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = FighterAvatar(
      name: label,
      size: 40,
      showInitialsChip: false,
      framed: true,
    );
    final name = Expanded(
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          child: Text(
            label,
            textAlign: alignEnd ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              color: AppColors.textPrimaryFor(context),
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );

    return Row(
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd
          ? [
              name,
              const SizedBox(width: 8),
              avatar,
            ]
          : [
              avatar,
              const SizedBox(width: 8),
              name,
            ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: title,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadows.cardFor(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimaryFor(context),
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(color: AppColors.textSecondaryFor(context)),
            ),
          ],
        ),
      ),
    );
  }
}
