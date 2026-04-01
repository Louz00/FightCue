import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fightcue_mobile/src/core/app_strings.dart';
import 'package:fightcue_mobile/src/features/paywall/paywall_screen.dart';
import 'package:fightcue_mobile/src/models/domain_models.dart';

import 'test_fakes.dart';

void main() {
  testWidgets('Paywall screen shows current plan and premium CTA', (tester) async {
    final api = FakeFightCueApi();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => PaywallScreen(
            api: api,
            strings: AppStrings.of(context),
            snapshot: const MonetizationSnapshot(
              premiumState: PremiumState.free,
              adTier: AdTier.freeWithAds,
              adConsentRequired: true,
              adConsentGranted: true,
              analyticsConsent: false,
              quietAdsEnabled: true,
            ),
            billingRuntimeService: FakeBillingRuntimeService(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final ctaFinder = find.widgetWithText(FilledButton, 'Premium checkout next');
    await tester.scrollUntilVisible(
      ctaFinder,
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('FightCue Premium'), findsAtLeastNWidgets(1));
    expect(ctaFinder, findsOneWidget);
  });
}
