part of 'event_detail_screen.dart';

class _FightCardSectionBar extends StatelessWidget {
  const _FightCardSectionBar({
    required this.strings,
    required this.hasPrelims,
    required this.selectedSection,
    required this.onSelect,
  });

  final AppStrings strings;
  final bool hasPrelims;
  final _FightCardSection selectedSection;
  final ValueChanged<_FightCardSection> onSelect;

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surfaceFor(context);
    final border = AppColors.borderFor(context);
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SectionToggleButton(
              label: strings.mainCardTabLabel,
              selected: selectedSection == _FightCardSection.main,
              onTap: () => onSelect(_FightCardSection.main),
            ),
          ),
          if (hasPrelims)
            Expanded(
              child: _SectionToggleButton(
                label: strings.preliminaryCardTabLabel,
                selected: selectedSection == _FightCardSection.prelims,
                onTap: () => onSelect(_FightCardSection.prelims),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionToggleButton extends StatelessWidget {
  const _SectionToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          decoration: BoxDecoration(
            border: selected
                ? Border(
                    bottom: BorderSide(
                      color: textPrimary,
                      width: 2.5,
                    ),
                  )
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? textPrimary : textSecondary,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorialBoutTile extends StatelessWidget {
  const _EditorialBoutTile({
    required this.event,
    required this.bout,
    required this.fighterA,
    required this.fighterB,
    required this.onOpenFighter,
    required this.onToggleFighterFollow,
  });

  final EventSummary event;
  final BoutSummary bout;
  final FighterSummary? fighterA;
  final FighterSummary? fighterB;
  final ValueChanged<String> onOpenFighter;
  final ValueChanged<String> onToggleFighterFollow;

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surfaceFor(context);
    final border = AppColors.borderFor(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);
    final surfaceAlt = AppColors.surfaceAltFor(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${event.localDateLabel}, ${event.localTimeLabel}',
                  style: TextStyle(
                    color: textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (bout.includesFollowedFighter)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE7EB),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0x1AD30F2F)),
                  ),
                  child: const Text(
                    'FOLLOWING',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _boutHeadline(bout),
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 21,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BoutFighterSide(
                  fighterId: bout.fighterAId,
                  displayName: bout.fighterAName,
                  fighter: fighterA,
                  alignEnd: false,
                  onOpenFighter: onOpenFighter,
                  onToggleFighterFollow: onToggleFighterFollow,
                ),
              ),
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Expanded(
                child: _BoutFighterSide(
                  fighterId: bout.fighterBId,
                  displayName: bout.fighterBName,
                  fighter: fighterB,
                  alignEnd: true,
                  onOpenFighter: onOpenFighter,
                  onToggleFighterFollow: onToggleFighterFollow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BoutFighterSide extends StatelessWidget {
  const _BoutFighterSide({
    required this.fighterId,
    required this.displayName,
    required this.fighter,
    required this.alignEnd,
    required this.onOpenFighter,
    required this.onToggleFighterFollow,
  });

  final String fighterId;
  final String displayName;
  final FighterSummary? fighter;
  final bool alignEnd;
  final ValueChanged<String> onOpenFighter;
  final ValueChanged<String> onToggleFighterFollow;

  @override
  Widget build(BuildContext context) {
    final isFollowed = fighter?.isFollowed ?? false;
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);
    final surface = AppColors.surfaceFor(context);
    final avatar = FighterAvatar(
      name: displayName,
      size: 60,
      showInitialsChip: false,
      framed: true,
    );
    final info = Expanded(
      child: Semantics(
        button: true,
        label: 'Open fighter profile for $displayName',
        child: InkWell(
          onTap: () => onOpenFighter(fighterId),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: alignEnd
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  textAlign: alignEnd ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    color: isFollowed ? AppColors.accent : textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (fighter?.recordLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    fighter!.recordLabel,
                    textAlign: alignEnd ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (fighter?.organizationHint != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    fighter!.organizationHint,
                    textAlign: alignEnd ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    final followButton = Semantics(
      button: true,
      toggled: isFollowed,
      label: isFollowed ? 'Unfollow $displayName' : 'Follow $displayName',
      child: InkWell(
        onTap: () => onToggleFighterFollow(fighterId),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isFollowed ? AppColors.accent : surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.accent),
          ),
          child: Icon(
            isFollowed ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 16,
            color: isFollowed ? Colors.white : AppColors.accent,
          ),
        ),
      ),
    );

    return Row(
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd
          ? [
              followButton,
              info,
              avatar,
            ]
          : [
              avatar,
              info,
              followButton,
            ],
    );
  }
}

class _EmptyFightCardCard extends StatelessWidget {
  const _EmptyFightCardCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surfaceFor(context);
    final border = AppColors.borderFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Text(
        strings.noFilteredEventsBody,
        style: TextStyle(
          color: textSecondary,
          height: 1.45,
        ),
      ),
    );
  }
}

List<BoutSummary> _boutsForSection(
  EventSummary event, {
  required _FightCardSection section,
}) {
  if (event.bouts.isEmpty) {
    return const [];
  }

  final prelims = event.bouts.where(_isPrelimBout).toList();
  final mains = event.bouts.where((bout) => !_isPrelimBout(bout)).toList();

  if (section == _FightCardSection.prelims) {
    return prelims;
  }

  return mains.isEmpty ? event.bouts : mains;
}

bool _isPrelimBout(BoutSummary bout) {
  final slot = bout.slotLabel.toLowerCase();
  return slot.contains('prelim') || slot.contains('early');
}

String _boutHeadline(BoutSummary bout) {
  final hasWeight = bout.weightClass != null && bout.weightClass!.isNotEmpty;
  if (!hasWeight) {
    return bout.slotLabel;
  }
  return '${bout.weightClass} · ${bout.slotLabel}';
}
