import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

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
        boxShadow: AppShadows.card,
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
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 31,
                    height: 0.98,
                    letterSpacing: -0.9,
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
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textPrimary,
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
    final background = emphasized ? AppColors.accent : Colors.white;
    final textColor = emphasized ? Colors.white : AppColors.accent;

    return InkWell(
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

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
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              height: 1.06,
              letterSpacing: -0.4,
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
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
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
        color: AppColors.ink,
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
