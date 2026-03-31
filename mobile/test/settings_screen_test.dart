import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fightcue_mobile/src/core/app_strings.dart';
import 'package:fightcue_mobile/src/data/fightcue_api.dart';
import 'package:fightcue_mobile/src/data/push_delivery_service.dart';
import 'package:fightcue_mobile/src/features/settings/settings_screen.dart';
import 'package:fightcue_mobile/src/models/domain_models.dart';
import 'package:fightcue_mobile/src/models/mock_data.dart';

import 'test_fakes.dart';

void main() {
  testWidgets('Settings screen renders billing and consent foundations', (
    tester,
  ) async {
    final api = FakeFightCueApi(
      pushSettingsResult: const PushSettingsSnapshot(
        pushEnabled: true,
        permissionStatus: PushPermissionStatus.prompt,
        tokenRegistered: false,
      ),
      monetizationResult: const MonetizationSnapshot(
        premiumState: PremiumState.free,
        adTier: AdTier.freeWithAds,
        adConsentRequired: true,
        adConsentGranted: true,
        analyticsConsent: false,
        quietAdsEnabled: true,
      ),
      homeResult: const ApiFetchResult(
        data: sampleHomeSnapshot,
        isFromCache: false,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: SettingsScreen(
              api: api,
              snapshotListenable: ValueNotifier(sampleHomeSnapshot),
              strings: AppStrings.of(context),
              pushDeliveryService: FakePushDeliveryService(
                statusResult: const PushDeviceRegistrationResult(
                  permissionStatus: PushPermissionStatus.prompt,
                  platform: PushTokenPlatform.ios,
                ),
              ),
              onSelectLanguage: (_) {},
              onSelectViewingCountry: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Billing and ads'), findsOneWidget);
    expect(find.text('Ads allowed'), findsOneWidget);
    expect(find.text('Analytics off'), findsOneWidget);
    expect(find.text('Quiet ads active'), findsOneWidget);
  });

  testWidgets('Settings screen shows cached billing notice when using saved monetization state', (
    tester,
  ) async {
    final api = FakeFightCueApi(
      pushFetchResult: ApiFetchResult(
        data: const PushSettingsSnapshot(
          pushEnabled: true,
          permissionStatus: PushPermissionStatus.prompt,
          tokenRegistered: false,
        ),
        isFromCache: true,
        lastSyncedAt: DateTime.utc(2026, 3, 31, 21, 10),
      ),
      monetizationFetchResult: ApiFetchResult(
        data: const MonetizationSnapshot(
          premiumState: PremiumState.free,
          adTier: AdTier.freeWithAds,
          adConsentRequired: true,
          adConsentGranted: false,
          analyticsConsent: false,
          quietAdsEnabled: false,
        ),
        isFromCache: true,
        lastSyncedAt: DateTime.utc(2026, 3, 31, 21, 10),
      ),
      homeResult: const ApiFetchResult(
        data: sampleHomeSnapshot,
        isFromCache: false,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: SettingsScreen(
              api: api,
              snapshotListenable: ValueNotifier(sampleHomeSnapshot),
              strings: AppStrings.of(context),
              pushDeliveryService: FakePushDeliveryService(
                statusResult: const PushDeviceRegistrationResult(
                  permissionStatus: PushPermissionStatus.prompt,
                  platform: PushTokenPlatform.ios,
                ),
              ),
              onSelectLanguage: (_) {},
              onSelectViewingCountry: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Showing saved billing setup'), findsOneWidget);
    expect(find.textContaining('Last synced:'), findsOneWidget);
  });
}
