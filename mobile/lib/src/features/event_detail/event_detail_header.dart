part of 'event_detail_screen.dart';

class _EventScoreboardHeader extends StatelessWidget {
  const _EventScoreboardHeader({
    required this.event,
    required this.mainBout,
    required this.fighterA,
    required this.fighterB,
    required this.strings,
    required this.onToggleFollow,
    required this.onCalendarExport,
  });

  final EventSummary event;
  final BoutSummary? mainBout;
  final FighterSummary? fighterA;
  final FighterSummary? fighterB;
  final AppStrings strings;
  final VoidCallback onToggleFollow;
  final VoidCallback onCalendarExport;

  @override
  Widget build(BuildContext context) {
    final primaryWatchProvider = primaryWatchProviderLabel(event);
    final watchLabel = primaryWatchProvider == null
        ? null
        : '${strings.whereToWatch}: $primaryWatchProvider';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                _HeaderBrandPill(label: event.organization),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.officialCardLabel,
                    style: const TextStyle(
                      color: Color(0xFFFFE4E8),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            color: const Color(0x26000000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    height: 1.06,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.tagline,
                  style: const TextStyle(
                    color: Color(0xFFFFE4E8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Column(
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _HeaderMetaChip(
                      icon: Icons.schedule_rounded,
                      label: '${event.localDateLabel}  •  ${event.localTimeLabel}',
                    ),
                    _HeaderMetaChip(
                      icon: Icons.location_on_outlined,
                      label: event.locationLabel,
                    ),
                    if (watchLabel != null)
                      _HeaderMetaChip(
                        icon: Icons.play_circle_outline_rounded,
                        label: watchLabel,
                      ),
                  ],
                ),
                if (mainBout != null) ...[
                  const SizedBox(height: 18),
                  _HeadlineFightRow(
                    bout: mainBout!,
                    fighterA: fighterA,
                    fighterB: fighterB,
                  ),
                ] else ...[
                  const SizedBox(height: 18),
                  _HeaderMetaChip(
                    icon: Icons.pending_actions_outlined,
                    label: strings.pendingCardTitle,
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _HeaderActionButton(
                        label: event.isFollowed
                            ? strings.unfollowAction
                            : strings.followAction,
                        filled: true,
                        onTap: onToggleFollow,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HeaderActionButton(
                        label: strings.calendarAction,
                        filled: false,
                        onTap: onCalendarExport,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBrandPill extends StatelessWidget {
  const _HeaderBrandPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _HeaderMetaChip extends StatelessWidget {
  const _HeaderMetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x36FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeadlineFightRow extends StatelessWidget {
  const _HeadlineFightRow({
    required this.bout,
    required this.fighterA,
    required this.fighterB,
  });

  final BoutSummary bout;
  final FighterSummary? fighterA;
  final FighterSummary? fighterB;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          '${bout.fighterAName} versus ${bout.fighterBName}, ${bout.slotLabel}',
      child: Row(
        children: [
          Expanded(
            child: _HeadlineFighterBlock(
              name: bout.fighterAName,
              recordLabel: fighterA?.recordLabel,
              avatarOnLeadingEdge: true,
            ),
          ),
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x22FFFFFF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x34FFFFFF)),
            ),
            child: Text(
              bout.slotLabel.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: _HeadlineFighterBlock(
              name: bout.fighterBName,
              recordLabel: fighterB?.recordLabel,
              avatarOnLeadingEdge: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeadlineFighterBlock extends StatelessWidget {
  const _HeadlineFighterBlock({
    required this.name,
    required this.recordLabel,
    required this.avatarOnLeadingEdge,
  });

  final String name;
  final String? recordLabel;
  final bool avatarOnLeadingEdge;

  @override
  Widget build(BuildContext context) {
    final textColumn = Expanded(
      child: Column(
        crossAxisAlignment: avatarOnLeadingEdge
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            name,
            textAlign: avatarOnLeadingEdge ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (recordLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              recordLabel!,
              textAlign: avatarOnLeadingEdge ? TextAlign.left : TextAlign.right,
              style: const TextStyle(
                color: Color(0xFFFFD8DE),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );

    final avatar = FighterAvatar(
      name: name,
      size: 72,
      showInitialsChip: false,
      framed: true,
    );

    return Row(
      mainAxisAlignment: avatarOnLeadingEdge
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: avatarOnLeadingEdge
          ? [
              avatar,
              const SizedBox(width: 12),
              textColumn,
            ]
          : [
              textColumn,
              const SizedBox(width: 12),
              avatar,
            ],
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: filled
                ? Colors.white
                : (AppColors.isDark(context)
                      ? AppColors.darkSurface
                      : AppColors.ink),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: filled ? Colors.white : const Color(0x33FFFFFF),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: filled ? AppColors.accent : Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
