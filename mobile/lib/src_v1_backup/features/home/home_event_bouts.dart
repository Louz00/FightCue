part of 'home_screen.dart';

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
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
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
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
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
