part of 'settings_screen.dart';

class _SettingsPreferenceWrap extends StatelessWidget {
  const _SettingsPreferenceWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: children,
    );
  }
}

class _HighlightSettingsCard extends StatelessWidget {
  const _HighlightSettingsCard({
    required this.accountModeLabel,
    required this.planLabel,
    required this.timezone,
    required this.strings,
  });

  final String accountModeLabel;
  final String planLabel;
  final String timezone;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppShadows.cardFor(context),
      ),
      child: Column(
        children: [
          EditorialCardHeaderBand(
            pillLabel: strings.accountModelTitle,
            title: planLabel,
            trailingLabel: timezone,
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: _QuickStat(
                    label: strings.accountModelTitle,
                    value: accountModeLabel,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickStat(
                    label: strings.currentPlanTitle,
                    value: planLabel,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickStat(
                    label: strings.currentTimezoneTitle,
                    value: timezone,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final surfaceAlt = AppColors.surfaceAltFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);
    final textPrimary = AppColors.textPrimaryFor(context);

    return Semantics(
      label: '$label: $value',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.title,
    required this.body,
    required this.icon,
    this.child,
  });

  final String title;
  final String body;
  final IconData icon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final surfaceAlt = AppColors.surfaceAltFor(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);

    return Semantics(
      container: true,
      label: title,
      child: EditorialSurfaceCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: textPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: TextStyle(
                      color: textSecondary,
                      height: 1.45,
                    ),
                  ),
                  if (child != null) ...[
                    const SizedBox(height: 14),
                    child!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceChip extends StatelessWidget {
  const _PreferenceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        selectedColor: AppColors.accent,
        backgroundColor: AppColors.surfaceAltFor(context),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textPrimaryFor(context),
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? AppColors.accent : AppColors.borderFor(context),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        showCheckmark: false,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltFor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Semantics(
        label: label,
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondaryFor(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
