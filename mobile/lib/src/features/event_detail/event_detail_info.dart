part of 'event_detail_screen.dart';

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.event, required this.strings});

  final EventSummary event;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surfaceFor(context);
    final border = AppColors.borderFor(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          _OverviewRow(
            label: strings.organizationLabel,
            value: event.organization,
          ),
          const SizedBox(height: 12),
          _OverviewRow(
            label: strings.venueLabel,
            value: event.venueLabel,
          ),
          const SizedBox(height: 12),
          _OverviewRow(
            label: strings.selectedCountryLabel,
            value: event.selectedCountryCode,
          ),
          const SizedBox(height: 12),
          _OverviewRow(
            label: strings.sourceLabel,
            value: event.sourceLabel,
          ),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textSecondary = AppColors.textSecondaryFor(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.provider,
    required this.strings,
  });

  final WatchProviderSummary provider;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surfaceFor(context);
    final border = AppColors.borderFor(context);
    final surfaceAlt = AppColors.surfaceAltFor(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.play_circle_outline,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.label,
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${strings.selectedCountryLabel}: ${provider.countryCode}  •  ${provider.confidenceLabel}',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
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

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryFor(context);
    return Row(
      children: [
        Semantics(
          header: true,
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textPrimary,
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
