import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../data/ad_runtime.dart';

class FightCueAdSlot extends StatefulWidget {
  const FightCueAdSlot({
    super.key,
    required this.strings,
    required this.adsEnabled,
  });

  final AppStrings strings;
  final bool adsEnabled;

  @override
  State<FightCueAdSlot> createState() => _FightCueAdSlotState();
}

class _FightCueAdSlotState extends State<FightCueAdSlot> {
  final FightCueBannerAdController _controller = FightCueBannerAdController();
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!widget.adsEnabled) {
      return;
    }

    final banner = await _controller.loadBannerAd();
    if (!mounted) {
      banner?.dispose();
      return;
    }

    setState(() {
      _bannerAd = banner;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);

    return Semantics(
      container: true,
      label: widget.strings.quietAdsTitle,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadows.cardFor(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAltFor(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    widget.strings.sponsoredLabel.toUpperCase(),
                    style: TextStyle(
                      color: textSecondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                _AdSlotPill(
                  label: widget.adsEnabled
                      ? widget.strings.quietAdsEnabledLabel
                      : widget.strings.quietAdsDisabledLabel,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              widget.strings.quietAdSlotTitle,
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.adsEnabled
                  ? widget.strings.quietAdSlotBody
                  : widget.strings.quietAdsConsentBody,
              style: TextStyle(
                color: textSecondary,
                height: 1.45,
              ),
            ),
            if (widget.adsEnabled && _bannerAd != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdSlotPill extends StatelessWidget {
  const _AdSlotPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
