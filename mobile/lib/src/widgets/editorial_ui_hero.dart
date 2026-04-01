part of 'editorial_ui.dart';

class EditorialPageHero extends StatelessWidget {
  const EditorialPageHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.body,
    this.trailingLabel,
    this.footer,
  });

  final String eyebrow;
  final String title;
  final String body;
  final String? trailingLabel;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.cardFor(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: [
                _EditorialDarkPill(label: eyebrow),
                if (trailingLabel != null) ...[
                  const Spacer(),
                  Text(
                    trailingLabel!,
                    style: const TextStyle(
                      color: Color(0xFFFFE4E8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 31,
                      height: 0.98,
                      letterSpacing: -0.9,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFFFFE4E8),
                    height: 1.45,
                  ),
                ),
                if (footer != null) ...[
                  const SizedBox(height: 16),
                  footer!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditorialSectionTitle extends StatelessWidget {
  const EditorialSectionTitle({
    super.key,
    required this.label,
  });

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
