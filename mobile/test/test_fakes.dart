import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:fightcue_mobile/src/data/fightcue_api.dart';
import 'package:fightcue_mobile/src/data/push_delivery_service.dart';
import 'package:fightcue_mobile/src/models/domain_models.dart';

class FakeFightCueApi extends FightCueApi {
  FakeFightCueApi({
    this.homeResult,
    this.leaderboards = const [],
    this.leaderboardsError,
    this.monetizationFetchResult,
    this.monetizationResult,
    this.monetizationError,
    this.pushFetchResult,
    this.pushSettingsResult,
    this.pushPreviewResult,
    this.pushProviderStatus,
    this.pushTestDispatchResult,
    this.pushError,
    this.alertsFetchResult,
    this.alertsResult,
    this.alertsError,
    this.eventDetailResult,
    this.fighterDetailResult,
    this.eventDetailError,
    this.fighterDetailError,
    this.setEventFollowError,
    this.setFighterFollowError,
  }) : super(
         client: MockClient((_) async => http.Response('{}', 500)),
       );

  final ApiFetchResult<HomeSnapshot>? homeResult;
  final List<LeaderboardSummary> leaderboards;
  final Object? leaderboardsError;
  final ApiFetchResult<MonetizationSnapshot>? monetizationFetchResult;
  final MonetizationSnapshot? monetizationResult;
  final Object? monetizationError;
  final ApiFetchResult<PushSettingsSnapshot>? pushFetchResult;
  final PushSettingsSnapshot? pushSettingsResult;
  final ApiFetchResult<PushPreviewSnapshot>? pushPreviewResult;
  final PushProviderStatusSnapshot? pushProviderStatus;
  final PushTestDispatchSnapshot? pushTestDispatchResult;
  final Object? pushError;
  final ApiFetchResult<AlertsSnapshot>? alertsFetchResult;
  final AlertsSnapshot? alertsResult;
  final Object? alertsError;
  final ApiFetchResult<EventDetailSnapshot>? eventDetailResult;
  final ApiFetchResult<FighterDetailSnapshot>? fighterDetailResult;
  final Object? eventDetailError;
  final Object? fighterDetailError;
  final Object? setEventFollowError;
  final Object? setFighterFollowError;

  @override
  Future<ApiFetchResult<HomeSnapshot>> fetchHomeResult() async {
    if (homeResult == null) {
      throw StateError('Fake home result missing');
    }
    return homeResult!;
  }

  @override
  Future<AlertsSnapshot> fetchAlerts() async {
    return (await fetchAlertsResult()).data;
  }

  @override
  Future<ApiFetchResult<AlertsSnapshot>> fetchAlertsResult() async {
    if (alertsError != null) {
      throw alertsError!;
    }
    if (alertsFetchResult != null) {
      return alertsFetchResult!;
    }
    if (alertsResult == null) {
      throw StateError('Fake alerts result missing');
    }
    return ApiFetchResult(
      data: alertsResult!,
      isFromCache: false,
    );
  }

  @override
  Future<List<LeaderboardSummary>> fetchLeaderboards() async {
    return (await fetchLeaderboardsResult()).data;
  }

  @override
  Future<ApiFetchResult<List<LeaderboardSummary>>> fetchLeaderboardsResult() async {
    if (leaderboardsError != null) {
      throw leaderboardsError!;
    }
    return ApiFetchResult(
      data: leaderboards,
      isFromCache: false,
    );
  }

  @override
  Future<ApiFetchResult<MonetizationSnapshot>> fetchMonetizationResult() async {
    if (monetizationError != null) {
      throw monetizationError!;
    }
    if (monetizationFetchResult != null) {
      return monetizationFetchResult!;
    }
    if (monetizationResult == null) {
      throw StateError('Fake monetization result missing');
    }
    return ApiFetchResult(
      data: monetizationResult!,
      isFromCache: false,
    );
  }

  @override
  Future<MonetizationSnapshot> updateMonetizationSettings({
    bool? analyticsConsent,
    bool? adConsentGranted,
  }) async {
    if (monetizationError != null) {
      throw monetizationError!;
    }
    final current = monetizationResult ??
        monetizationFetchResult?.data ??
        const MonetizationSnapshot(
          premiumState: PremiumState.free,
          adTier: AdTier.freeWithAds,
          adConsentRequired: true,
          adConsentGranted: false,
          analyticsConsent: false,
          quietAdsEnabled: false,
        );

    return current.copyWith(
      analyticsConsent: analyticsConsent,
      adConsentGranted: adConsentGranted,
      quietAdsEnabled: current.premiumState == PremiumState.free &&
          (!current.adConsentRequired ||
              (adConsentGranted ?? current.adConsentGranted)),
    );
  }

  @override
  Future<ApiFetchResult<PushSettingsSnapshot>> fetchPushSettingsResult() async {
    if (pushError != null) {
      throw pushError!;
    }
    if (pushFetchResult != null) {
      return pushFetchResult!;
    }
    if (pushSettingsResult == null) {
      throw StateError('Fake push settings result missing');
    }
    return ApiFetchResult(
      data: pushSettingsResult!,
      isFromCache: false,
    );
  }

  @override
  Future<PushSettingsSnapshot> registerPushToken({
    required PushPermissionStatus permissionStatus,
    PushTokenPlatform? tokenPlatform,
    String? tokenValue,
  }) async {
    if (pushError != null) {
      throw pushError!;
    }
    final current = pushSettingsResult ??
        pushFetchResult?.data ??
        const PushSettingsSnapshot(
          pushEnabled: false,
          permissionStatus: PushPermissionStatus.unknown,
          tokenRegistered: false,
        );
    return current.copyWith(
      pushEnabled: permissionStatus == PushPermissionStatus.granted,
      permissionStatus: permissionStatus,
      tokenPlatform: tokenValue == null ? null : tokenPlatform,
      tokenRegistered: tokenValue != null && tokenValue.isNotEmpty,
      tokenUpdatedAt: tokenValue == null ? null : DateTime.utc(2026, 3, 31, 22, 0),
    );
  }

  @override
  Future<ApiFetchResult<PushPreviewSnapshot>> fetchPushPreviewResult() async {
    if (pushError != null) {
      throw pushError!;
    }
    if (pushPreviewResult != null) {
      return pushPreviewResult!;
    }
    return const ApiFetchResult(
      data: PushPreviewSnapshot(
        deliveryReadiness: PushDeliveryReadiness.tokenMissing,
        scheduledCount: 0,
        signalCount: 0,
        items: [],
      ),
      isFromCache: false,
    );
  }

  @override
  Future<PushProviderStatusSnapshot> fetchPushProviderStatus() async {
    if (pushError != null) {
      throw pushError!;
    }
    return pushProviderStatus ??
        const PushProviderStatusSnapshot(
          provider: PushProviderType.log,
          supportsDelivery: true,
          configured: true,
          description: 'FightCue logs test push payloads locally.',
        );
  }

  @override
  Future<PushTestDispatchSnapshot> sendTestPush() async {
    if (pushError != null) {
      throw pushError!;
    }
    return pushTestDispatchResult ??
        const PushTestDispatchSnapshot(
          provider: PushProviderType.log,
          deliveryReadiness: PushDeliveryReadiness.ready,
          dispatched: true,
          message: 'FightCue queued a test reminder for this device.',
          providerMessageId: 'log_test_001',
        );
  }

  @override
  Future<void> prefetchReadSurfaces(HomeSnapshot snapshot) async {}

  @override
  Future<ApiFetchResult<EventDetailSnapshot>> fetchEventDetailResult(
    String eventId,
  ) async {
    if (eventDetailError != null) {
      throw eventDetailError!;
    }
    if (eventDetailResult == null) {
      throw StateError('Fake event detail result missing');
    }
    return eventDetailResult!;
  }

  @override
  Future<ApiFetchResult<FighterDetailSnapshot>> fetchFighterDetailResult(
    String fighterId,
  ) async {
    if (fighterDetailError != null) {
      throw fighterDetailError!;
    }
    if (fighterDetailResult == null) {
      throw StateError('Fake fighter detail result missing');
    }
    return fighterDetailResult!;
  }

  @override
  Future<EventSummary> setEventFollow(String eventId, bool followed) async {
    if (setEventFollowError != null) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      throw setEventFollowError!;
    }
    final snapshot = homeResult?.data;
    final event = snapshot?.eventById(eventId);
    if (event == null) {
      throw StateError('Fake event missing for $eventId');
    }
    return event.copyWith(isFollowed: followed);
  }

  @override
  Future<FighterSummary> setFighterFollow(String fighterId, bool followed) async {
    if (setFighterFollowError != null) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      throw setFighterFollowError!;
    }
    final snapshot = homeResult?.data;
    final fighter = snapshot?.fighterById(fighterId);
    if (fighter == null) {
      throw StateError('Fake fighter missing for $fighterId');
    }
    return fighter.copyWith(isFollowed: followed);
  }
}

class FakePushDeliveryService implements PushDeliveryService {
  FakePushDeliveryService({
    required this.statusResult,
    this.requestPermissionResult,
  });

  final PushDeviceRegistrationResult statusResult;
  final PushDeviceRegistrationResult? requestPermissionResult;

  @override
  Future<PushDeviceRegistrationResult> getStatus() async {
    return statusResult;
  }

  @override
  Future<PushDeviceRegistrationResult> requestPermission() async {
    return requestPermissionResult ?? statusResult;
  }
}
