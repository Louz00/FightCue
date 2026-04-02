part of 'home_screen.dart';

class _HomeIntro extends StatelessWidget {
  const _HomeIntro({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.appName.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textPrimaryFor(context),
              ),
        ),
        const SizedBox(height: 10),
        Text(
          strings.homeTitle.toUpperCase(),
          style: TextStyle(
            color: AppColors.textPrimaryFor(context),
            fontWeight: FontWeight.w900,
            fontSize: 38,
            height: 0.92,
            letterSpacing: -1.4,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 300,
          child: Text(
            strings.homeSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryFor(context),
                ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          strings.pullToRefreshHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryFor(context),
              ),
        ),
      ],
    );
  }
}

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(999),
              boxShadow: selected ? AppShadows.cardFor(context) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  Icon(
                    Icons.check,
                    size: 16,
                    color: textColor,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: AppColors.accent,
        fontWeight: FontWeight.w800,
        fontSize: 11,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _HomeSummaryBand extends StatelessWidget {
  const _HomeSummaryBand({
    required this.eventCount,
    required this.activeFilterCount,
  });

  final int eventCount;
  final int activeFilterCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _HomeSummaryMetric(
              label: 'Events',
              value: '$eventCount',
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.borderFor(context),
          ),
          Expanded(
            child: _HomeSummaryMetric(
              label: 'Filters',
              value: '$activeFilterCount',
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSummaryMetric extends StatelessWidget {
  const _HomeSummaryMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
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
          value,
          style: TextStyle(
            color: AppColors.textPrimaryFor(context),
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -0.7,
          ),
        ),
      ],
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Semantics(
          header: true,
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: AppColors.textPrimaryFor(context),
              fontWeight: FontWeight.w900,
              fontSize: 28,
              height: 0.96,
              letterSpacing: -1,
            ),
          ),
        ),
        const Spacer(),
        Container(
          width: 44,
          height: 4,
          color: AppColors.accent,
        ),
      ],
    );
  }
}
