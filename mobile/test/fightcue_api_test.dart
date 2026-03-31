import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fightcue_mobile/src/data/fightcue_api.dart';
import 'package:fightcue_mobile/src/models/domain_models.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('resolveFightCueApiBaseUrl uses configured host first', () {
    expect(
      resolveFightCueApiBaseUrl(
        isWeb: false,
        platform: TargetPlatform.android,
        configuredBaseUrl: 'https://api.fightcue.test',
      ),
      'https://api.fightcue.test',
    );
  });

  test('resolveFightCueApiBaseUrl uses 10.0.2.2 for Android emulator', () {
    expect(
      resolveFightCueApiBaseUrl(
        isWeb: false,
        platform: TargetPlatform.android,
      ),
      'http://10.0.2.2:3000',
    );
  });

  test('resolveFightCueApiBaseUrl keeps localhost for web and Apple targets', () {
    expect(
      resolveFightCueApiBaseUrl(
        isWeb: true,
        platform: TargetPlatform.iOS,
      ),
      'http://127.0.0.1:3000',
    );
    expect(
      resolveFightCueApiBaseUrl(
        isWeb: false,
        platform: TargetPlatform.iOS,
      ),
      'http://127.0.0.1:3000',
    );
  });

  test('fetchHomeResult marks cached payloads when the network call fails', () async {
    var homeCallCount = 0;
    final client = MockClient((request) async {
      if (request.url.path == '/v1/session/bootstrap') {
        return http.Response(
          jsonEncode({
            'deviceId': 'device_test',
            'deviceToken': 'signed-token',
          }),
          200,
        );
      }

      if (request.url.path == '/v1/home') {
        homeCallCount += 1;
        if (homeCallCount == 1) {
          return http.Response(
            jsonEncode({
              'profile': {
                'language': 'en',
                'timezone': 'Europe/Amsterdam',
                'viewingCountryCode': 'NL',
                'premiumState': 'free',
                'isAnonymous': true,
              },
              'fighters': [],
              'events': [],
            }),
            200,
          );
        }

        throw http.ClientException('network down');
      }

      return http.Response('{}', 404);
    });

    final api = FightCueApi(client: client);

    final first = await api.fetchHomeResult();
    final second = await api.fetchHomeResult();

    expect(first.data.languageCode, 'en');
    expect(first.isFromCache, isFalse);
    expect(first.lastSyncedAt, isNotNull);
    expect(second.data.languageCode, 'en');
    expect(second.data.events, isEmpty);
    expect(second.isFromCache, isTrue);
  });

  test('fetchPushSettings and updatePushSettings parse push foundation state', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);

      if (request.url.path == '/v1/session/bootstrap') {
        return http.Response(
          jsonEncode({
            'deviceId': 'device_test',
            'deviceToken': 'signed-token',
          }),
          200,
        );
      }

      if (request.url.path == '/v1/me/push' && request.method == 'GET') {
        return http.Response(
          jsonEncode({
            'pushEnabled': false,
            'permissionStatus': 'unknown',
            'tokenRegistered': false,
          }),
          200,
        );
      }

      if (request.url.path == '/v1/me/push/settings' && request.method == 'PUT') {
        return http.Response(
          jsonEncode({
            'pushEnabled': true,
            'permissionStatus': 'prompt',
            'tokenRegistered': false,
          }),
          200,
        );
      }

      return http.Response('{}', 404);
    });

    final api = FightCueApi(client: client);
    final current = await api.fetchPushSettings();
    final updated = await api.updatePushSettings(
      pushEnabled: true,
      permissionStatus: PushPermissionStatus.prompt,
    );

    expect(current.pushEnabled, isFalse);
    expect(current.permissionStatus, PushPermissionStatus.unknown);
    expect(updated.pushEnabled, isTrue);
    expect(updated.permissionStatus, PushPermissionStatus.prompt);
    expect(
      jsonDecode(requests.last.body),
      {
        'pushEnabled': true,
        'permissionStatus': 'prompt',
      },
    );
  });

  test('fetchMonetization and updateMonetizationSettings parse billing foundation state', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);

      if (request.url.path == '/v1/session/bootstrap') {
        return http.Response(
          jsonEncode({
            'deviceId': 'device_test',
            'deviceToken': 'signed-token',
          }),
          200,
        );
      }

      if (request.url.path == '/v1/me/monetization' && request.method == 'GET') {
        return http.Response(
          jsonEncode({
            'premiumState': 'free',
            'adTier': 'free_with_ads',
            'adConsentRequired': true,
            'adConsentGranted': false,
            'analyticsConsent': false,
            'quietAdsEnabled': false,
          }),
          200,
        );
      }

      if (request.url.path == '/v1/me/monetization/settings' &&
          request.method == 'PUT') {
        return http.Response(
          jsonEncode({
            'premiumState': 'free',
            'adTier': 'free_with_ads',
            'adConsentRequired': true,
            'adConsentGranted': true,
            'analyticsConsent': true,
            'quietAdsEnabled': true,
          }),
          200,
        );
      }

      return http.Response('{}', 404);
    });

    final api = FightCueApi(client: client);
    final current = await api.fetchMonetization();
    final updated = await api.updateMonetizationSettings(
      adConsentGranted: true,
      analyticsConsent: true,
    );

    expect(current.premiumState, PremiumState.free);
    expect(current.adTier, AdTier.freeWithAds);
    expect(current.adConsentGranted, isFalse);
    expect(updated.quietAdsEnabled, isTrue);
    expect(
      jsonDecode(requests.last.body),
      {
        'analyticsConsent': true,
        'adConsentGranted': true,
      },
    );
  });
}
