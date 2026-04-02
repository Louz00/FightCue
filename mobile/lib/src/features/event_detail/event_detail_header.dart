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
    final eyebrow =
        '${event.locationLabel.toUpperCase()}  •  ${event.venueLabel.toUpperCase()}';

    return Container(
      color: AppColors.backgroundFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Text(
              eyebrow,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 0.9,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.textPrimaryFor(context),
                    fontWeight: FontWeight.w900,
                    fontSize: 40,
                    height: 0.94,
                    letterSpacing: -1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.tagline,
                  style: TextStyle(
                    color: AppColors.textSecondaryFor(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: _EditorialTopMetric(
                    label: 'Date',
                    value: event.localDateLabel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _EditorialTopMetric(
                    label: 'Time',
                    value: event.localTimeLabel,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: _HeaderActionButton(
                    label: strings.calendarAction,
                    filled: true,
                    icon: Icons.calendar_today_rounded,
                    onTap: onCalendarExport,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HeaderActionButton(
                    label: event.isFollowed
                        ? strings.unfollowAction
                        : strings.followAction,
                    filled: false,
                    icon: Icons.sports_mma,
                    onTap: onToggleFollow,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'MAIN EVENT',
              style: TextStyle(
                color: AppColors.textSecondaryFor(context),
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: mainBout != null
                ? _MainEventFeatureCard(
                    bout: mainBout!,
                    fighterA: fighterA,
                    fighterB: fighterB,
                  )
                : _EditorialPendingHeaderCard(
                    label: strings.pendingCardTitle,
                  ),
          ),
        ],
      ),
    );
  }
}

class _EditorialTopMetric extends StatelessWidget {
  const _EditorialTopMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: AppColors.textSecondaryFor(context),
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.toUpperCase(),
            style: TextStyle(
              color: AppColors.textPrimaryFor(context),
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MainEventFeatureCard extends StatelessWidget {
  const _MainEventFeatureCard({
    required this.bout,
    required this.fighterA,
    required this.fighterB,
  });

  final BoutSummary bout;
  final FighterSummary? fighterA;
  final FighterSummary? fighterB;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppShadows.cardFor(context),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -24,
            child: Text(
              (bout.weightClass ?? bout.slotLabel).toUpperCase(),
              style: TextStyle(
                color: AppColors.surfaceAltFor(context),
                fontWeight: FontWeight.w900,
                fontSize: 72,
                height: 1,
                letterSpacing: -2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAltFor(context),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        bout.slotLabel.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    if (bout.weightClass != null) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          bout.weightClass!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondaryFor(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 18),
                _HeadlineFightRow(
                  bout: bout,
                  fighterA: fighterA,
                  fighterB: fighterB,
                  editorial: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialPendingHeaderCard extends StatelessWidget {
  const _EditorialPendingHeaderCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textPrimaryFor(context),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HeadlineFightRow extends StatelessWidget {
  const _HeadlineFightRow({
    required this.bout,
    required this.fighterA,
    required this.fighterB,
    this.editorial = false,
  });

  final BoutSummary bout;
  final FighterSummary? fighterA;
  final FighterSummary? fighterB;
  final bool editorial;

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
              editorial: editorial,
            ),
          ),
          Container(
            width: editorial ? 72 : 62,
            height: editorial ? 72 : 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: editorial
                  ? AppColors.surfaceAltFor(context)
                  : const Color(0x22FFFFFF),
              shape: BoxShape.circle,
              border: Border.all(
                color: editorial
                    ? AppColors.borderFor(context)
                    : const Color(0x34FFFFFF),
              ),
            ),
            child: Text(
              bout.slotLabel.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: editorial ? AppColors.accent : Colors.white,
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
              editorial: editorial,
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
    required this.editorial,
  });

  final String name;
  final String? recordLabel;
  final bool avatarOnLeadingEdge;
  final bool editorial;

  @override
  Widget build(BuildContext context) {
    final textColumn = Expanded(
      child: Column(
        crossAxisAlignment: avatarOnLeadingEdge
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            name.toUpperCase(),
            textAlign: avatarOnLeadingEdge ? TextAlign.left : TextAlign.right,
            style: TextStyle(
              color: editorial ? AppColors.textPrimary : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: editorial ? 22 : 16,
              height: 0.98,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (recordLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              recordLabel!,
              textAlign: avatarOnLeadingEdge ? TextAlign.left : TextAlign.right,
              style: TextStyle(
                color: editorial
                    ? AppColors.accent
                    : const Color(0xFFFFD8DE),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );

    final avatar = FighterAvatar(
      name: name,
      size: editorial ? 82 : 72,
      showInitialsChip: false,
      framed: editorial,
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
    this.icon,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;
  final IconData? icon;

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
            color: filled ? AppColors.accent : AppColors.surfaceFor(context),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.accent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: filled ? Colors.white : AppColors.accent,
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: filled ? Colors.white : AppColors.accent,
                    fontWeight: FontWeight.w800,
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
