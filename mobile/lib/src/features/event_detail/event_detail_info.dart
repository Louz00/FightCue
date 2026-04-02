part of 'event_detail_screen.dart';

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.event, required this.strings});

  final EventSummary event;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.cardFor(context),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _OverviewMetricCard(
                  label: strings.organizationLabel,
                  value: event.organization,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OverviewMetricCard(
                  label: strings.venueLabel,
                  value: event.venueLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OverviewMetricCard(
                  label: strings.yourTimeLabel,
                  value: event.localTimeLabel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OverviewMetricCard(
                  label: strings.eventLocalStartLabel,
                  value: event.eventLocalTimeLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceAltFor(context),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.sourceLabel.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondaryFor(context),
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  event.sourceLabel,
                  style: TextStyle(
                    color: AppColors.textPrimaryFor(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${event.locationLabel} • ${event.venueLabel}',
                  style: TextStyle(
                    color: AppColors.textSecondaryFor(context),
                    height: 1.45,
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

class _OverviewMetricCard extends StatelessWidget {
  const _OverviewMetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundFor(context),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondaryFor(context),
                ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimaryFor(context),
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({
    required this.label,
    this.eyebrow,
  });

  final String label;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryFor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!.toUpperCase(),
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Semantics(
              header: true,
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: -0.8,
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
        ),
      ],
    );
  }
}
