part of 'editorial_ui.dart';

class EditorialActionPill extends StatelessWidget {
  const EditorialActionPill({
    super.key,
    required this.label,
    required this.onTap,
    this.emphasized = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final background =
        emphasized ? AppColors.accent : AppColors.surfaceFor(context);
    final textColor = emphasized ? Colors.white : AppColors.accent;

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.accent),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class EditorialSurfaceCard extends StatelessWidget {
  const EditorialSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppShadows.cardFor(context),
      ),
      child: child,
    );
  }
}

class EditorialLoadingCard extends StatelessWidget {
  const EditorialLoadingCard({
    super.key,
    this.label,
  });

  final String? label;

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.textSecondaryFor(context);

    return EditorialSurfaceCard(
      padding: const EdgeInsets.all(26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Center(child: CircularProgressIndicator()),
          if (label != null) ...[
            const SizedBox(height: 14),
            Text(
              label!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EditorialNoticeCard extends StatelessWidget {
  const EditorialNoticeCard({
    super.key,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final titleColor = AppColors.textPrimaryFor(context);
    final bodyColor = AppColors.textSecondaryFor(context);

    return Semantics(
      container: true,
      child: EditorialSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(
                color: bodyColor,
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              EditorialActionPill(
                label: actionLabel!,
                emphasized: true,
                onTap: onAction!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
