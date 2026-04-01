part of 'editorial_ui.dart';

class EditorialCardHeaderBand extends StatelessWidget {
  const EditorialCardHeaderBand({
    super.key,
    required this.pillLabel,
    required this.title,
    this.trailingLabel,
  });

  final String pillLabel;
  final String title;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _EditorialDarkPill(label: pillLabel),
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
          const SizedBox(height: 12),
          Semantics(
            header: true,
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                height: 1.06,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditorialMetaBand extends StatelessWidget {
  const EditorialMetaBand({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltFor(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textPrimaryFor(context),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EditorialDarkPill extends StatelessWidget {
  const _EditorialDarkPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.inkFor(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
