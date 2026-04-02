import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fightcue_mobile/src/core/app_strings.dart';
import 'package:fightcue_mobile/src/data/ad_runtime.dart';
import 'package:fightcue_mobile/src/data/crash_reporting.dart';
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
              billingRuntimeService: FakeBillingRuntimeService(),
              adRuntimeLoader: () async => const AdRuntimeStatus(
                sdkReady: true,
                appIdConfigured: true,
                bannerUnitId: 'test-banner',
                usingTestIdentifiers: true,
              ),
              crashReportingLoader: () async => const CrashReportingStatus(
                available: false,
                providerLabel: 'disabled',
                reason: 'Firebase is not initialized for this runtime.',
              ),
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
    expect(find.textContaining('Google test IDs are active'), findsOneWidget);
    expect(
      find.textContaining('Crash reporting provider: disabled'),
      findsOneWidget,
    );
  });

  testWidgets('Settings screen shows cached billing notice when using saved monetization state', (
    tester,
  ) async {
    final syncedAt = DateTime.now().toUtc();
    final api = FakeFightCueApi(
      pushFetchResult: ApiFetchResult(
        data: const PushSettingsSnapshot(
          pushEnabled: true,
          permissionStatus: PushPermissionStatus.prompt,
          tokenRegistered: false,
        ),
        isFromCache: true,
        lastSyncedAt: syncedAt,
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
        lastSyncedAt: syncedAt,
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
              billingRuntimeService: FakeBillingRuntimeService(),
              adRuntimeLoader: () async => const AdRuntimeStatus(
                sdkReady: true,
                appIdConfigured: true,
                bannerUnitId: 'test-banner',
                usingTestIdentifiers: true,
              ),
              crashReportingLoader: () async => const CrashReportingStatus(
                available: false,
                providerLabel: 'disabled',
                reason: 'Firebase is not initialized for this runtime.',
              ),
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

  testWidgets('Settings screen shows premium plans entry point', (tester) async {
    final api = FakeFightCueApi(
      pushSettingsResult: const PushSettingsSnapshot(
        pushEnabled: false,
        permissionStatus: PushPermissionStatus.unknown,
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
              billingRuntimeService: FakeBillingRuntimeService(),
              adRuntimeLoader: () async => const AdRuntimeStatus(
                sdkReady: true,
                appIdConfigured: true,
                bannerUnitId: 'test-banner',
                usingTestIdentifiers: true,
              ),
              crashReportingLoader: () async => const CrashReportingStatus(
                available: false,
                providerLabel: 'disabled',
                reason: 'Firebase is not initialized for this runtime.',
              ),
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
    final plansButton = find.widgetWithText(
      FilledButton,
      'View premium plans',
    );
    await tester.scrollUntilVisible(
      plansButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(plansButton, findsOneWidget);
  });

  testWidgets('Settings screen rolls back monetization changes when save fails', (
    tester,
  ) async {
    final api = FakeFightCueApi(
      monetizationResult: const MonetizationSnapshot(
        premiumState: PremiumState.free,
        adTier: AdTier.freeWithAds,
        adConsentRequired: true,
        adConsentGranted: false,
        analyticsConsent: false,
        quietAdsEnabled: false,
      ),
      updateMonetizationError: StateError('save failed'),
      pushSettingsResult: const PushSettingsSnapshot(
        pushEnabled: false,
        permissionStatus: PushPermissionStatus.unknown,
        tokenRegistered: false,
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
              billingRuntimeService: FakeBillingRuntimeService(),
              adRuntimeLoader: () async => const AdRuntimeStatus(
                sdkReady: true,
                appIdConfigured: true,
                bannerUnitId: 'test-banner',
                usingTestIdentifiers: true,
              ),
              crashReportingLoader: () async => const CrashReportingStatus(
                available: false,
                providerLabel: 'disabled',
                reason: 'Firebase is not initialized for this runtime.',
              ),
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

    final adsAllowedChip = find.widgetWithText(ChoiceChip, 'Ads allowed');
    await tester.scrollUntilVisible(
      adsAllowedChip,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(adsAllowedChip);
    await tester.pumpAndSettle();
    await tester.tap(adsAllowedChip);
    await tester.pumpAndSettle();

    expect(find.text('Quiet ads paused'), findsOneWidget);
  });

  testWidgets('Settings screen rolls back push toggle when save fails', (
    tester,
  ) async {
    final api = FakeFightCueApi(
      pushSettingsResult: const PushSettingsSnapshot(
        pushEnabled: false,
        permissionStatus: PushPermissionStatus.unknown,
        tokenRegistered: false,
      ),
      updatePushSettingsError: StateError('push save failed'),
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
              billingRuntimeService: FakeBillingRuntimeService(),
              adRuntimeLoader: () async => const AdRuntimeStatus(
                sdkReady: true,
                appIdConfigured: true,
                bannerUnitId: 'test-banner',
                usingTestIdentifiers: true,
              ),
              crashReportingLoader: () async => const CrashReportingStatus(
                available: false,
                providerLabel: 'disabled',
                reason: 'Firebase is not initialized for this runtime.',
              ),
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

    final quietAlertsChip = find.widgetWithText(ChoiceChip, 'Quiet alerts');
    await tester.scrollUntilVisible(
      quietAlertsChip,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(quietAlertsChip);
    await tester.pumpAndSettle();
    await tester.tap(quietAlertsChip);
    await tester.pumpAndSettle();

    expect(find.text('Connect this device'), findsNothing);
    expect(find.text('Off'), findsWidgets);
  });
}
