import 'package:flutter/material.dart';

import '../models/domain_models.dart';

part 'app_strings_general.dart';
part 'app_strings_offline.dart';
part 'app_strings_events.dart';
part 'app_strings_settings.dart';
part 'app_strings_push.dart';
part 'app_strings_paywall.dart';

class AppStrings {
  const AppStrings._(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('nl'),
    Locale('es'),
  ];

  static AppStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return AppStrings._(locale);
  }

  bool get isDutch => locale.languageCode == 'nl';
  bool get isSpanish => locale.languageCode == 'es';

  String _pick({
    required String en,
    required String nl,
    required String es,
  }) {
    if (isDutch) return nl;
    if (isSpanish) return es;
    return en;
  }
}
