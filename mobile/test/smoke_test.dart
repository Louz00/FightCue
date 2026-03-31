import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fightcue_mobile/src/core/app_strings.dart';

void main() {
  test('supported locales stay aligned with launch languages', () {
    expect(
      AppStrings.supportedLocales,
      const [Locale('en'), Locale('nl'), Locale('es')],
    );
  });
}
