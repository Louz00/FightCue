import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fightcue_mobile/src/data/fightcue_api.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('fetchHome returns cached payload when the network call fails', () async {
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

    final first = await api.fetchHome();
    final second = await api.fetchHome();

    expect(first.languageCode, 'en');
    expect(second.languageCode, 'en');
    expect(second.events, isEmpty);
  });
}
