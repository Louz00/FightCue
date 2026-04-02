part of 'home_screen.dart';

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
    return FightCueAdSlot(
      strings: strings,
      adsEnabled: adsEnabled,
    );
  }
}
