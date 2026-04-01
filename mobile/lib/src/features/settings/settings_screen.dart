import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/runtime/app_diagnostics.dart';
import '../../core/theme/app_theme.dart';
import '../../data/billing_runtime.dart';
import '../../data/fightcue_api.dart';
import '../../data/push_delivery_service.dart';
import '../paywall/paywall_screen.dart';
import '../../models/domain_models.dart';
import '../../widgets/editorial_ui.dart';

part 'settings_content.dart';
part 'settings_monetization.dart';
part 'settings_push.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.api,
    required this.snapshotListenable,
    required this.strings,
    this.onMonetizationChanged,
    this.billingRuntimeService,
    this.pushDeliveryService,
    required this.onSelectLanguage,
    required this.onSelectViewingCountry,
  });

  final FightCueApi api;
  final ValueListenable<HomeSnapshot> snapshotListenable;
  final AppStrings strings;
  final ValueChanged<MonetizationSnapshot>? onMonetizationChanged;
  final BillingRuntimeService? billingRuntimeService;
  final PushDeliveryService? pushDeliveryService;
  final ValueChanged<String> onSelectLanguage;
  final ValueChanged<String> onSelectViewingCountry;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeSnapshot>(
      valueListenable: snapshotListenable,
      builder: (context, snapshot, _) {
        final planLabel = snapshot.premiumState == PremiumState.premium
            ? strings.premiumPlanLabel
            : strings.freePlanLabel;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            EditorialPageHero(
              eyebrow: strings.settings.toUpperCase(),
              title: strings.settings,
              body: strings.settingsSubtitle,
              trailingLabel: snapshot.viewingCountryCode,
            ),
            const SizedBox(height: 24),
            _HighlightSettingsCard(
              accountModeLabel: snapshot.accountModeLabel,
              planLabel: planLabel,
              timezone: snapshot.timezone,
              strings: strings,
            ),
            const SizedBox(height: 12),
            _MonetizationCard(
              api: api,
              strings: strings,
              snapshot: snapshot,
              billingRuntimeService: billingRuntimeService,
              onChanged: onMonetizationChanged,
            ),
            const SizedBox(height: 20),
            EditorialSectionTitle(label: strings.languagePreferencesTitle),
            const SizedBox(height: 12),
            _SettingCard(
              title: strings.languagePreferencesTitle,
              body: strings.languagePreferencesBody,
              icon: Icons.language_outlined,
              child: _SettingsPreferenceWrap(
                children: [
                  _PreferenceChip(
                    label: strings.languageEnglishLabel,
                    selected: snapshot.languageCode == 'en',
                    onSelected: () => onSelectLanguage('en'),
                  ),
                  _PreferenceChip(
                    label: strings.languageDutchLabel,
                    selected: snapshot.languageCode == 'nl',
                    onSelected: () => onSelectLanguage('nl'),
                  ),
                  _PreferenceChip(
                    label: strings.languageSpanishLabel,
                    selected: snapshot.languageCode == 'es',
                    onSelected: () => onSelectLanguage('es'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            EditorialSectionTitle(label: strings.watchInfoTitle),
            const SizedBox(height: 12),
            _SettingCard(
              title: strings.watchInfoTitle,
              body: strings.watchInfoBody,
              icon: Icons.public_outlined,
              child: _SettingsPreferenceWrap(
                children: [
                  _PreferenceChip(
                    label: strings.countryNetherlandsLabel,
                    selected: snapshot.viewingCountryCode == 'NL',
                    onSelected: () => onSelectViewingCountry('NL'),
                  ),
                  _PreferenceChip(
                    label: strings.countryUnitedKingdomLabel,
                    selected: snapshot.viewingCountryCode == 'GB',
                    onSelected: () => onSelectViewingCountry('GB'),
                  ),
                  _PreferenceChip(
                    label: strings.countryUnitedStatesLabel,
                    selected: snapshot.viewingCountryCode == 'US',
                    onSelected: () => onSelectViewingCountry('US'),
                  ),
                  _PreferenceChip(
                    label: strings.countrySpainLabel,
                    selected: snapshot.viewingCountryCode == 'ES',
                    onSelected: () => onSelectViewingCountry('ES'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            EditorialSectionTitle(label: strings.runtimeSectionTitle),
            const SizedBox(height: 12),
            _SettingCard(
              title: strings.currentTimezoneTitle,
              body: '${snapshot.timezone}\n\n${strings.currentTimezoneBody}',
              icon: Icons.schedule_outlined,
            ),
            const SizedBox(height: 12),
            _SettingCard(
              title: strings.notificationStyleTitle,
              body: strings.notificationStyleBody,
              icon: Icons.notifications_outlined,
            ),
            const SizedBox(height: 12),
            _PushSettingsCard(
              api: api,
              strings: strings,
              pushDeliveryService: pushDeliveryService,
            ),
            const SizedBox(height: 12),
            _SettingCard(
              title: strings.sourcePilotTitle,
              body: strings.sourcePilotBody,
              icon: Icons.sports_mma_outlined,
            ),
            if (snapshot.premiumState == PremiumState.free) ...[
              const SizedBox(height: 12),
              _SettingCard(
                title: strings.quietAdsTitle,
                body: strings.quietAdsBody,
                icon: Icons.campaign_outlined,
              ),
            ],
          ],
        );
      },
    );
  }
}
