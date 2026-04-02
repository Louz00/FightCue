part of 'settings_screen.dart';

class _SettingsInfoPanel extends StatelessWidget {
  const _SettingsInfoPanel({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltFor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        body,
        style: TextStyle(
          color: AppColors.textSecondaryFor(context),
          height: 1.4,
        ),
      ),
    );
  }
}

class _MonetizationConsentControls extends StatelessWidget {
  const _MonetizationConsentControls({
    required this.strings,
    required this.settings,
    required this.isSaving,
    required this.onSave,
  });

  final AppStrings strings;
  final MonetizationSnapshot settings;
  final bool isSaving;
  final Future<void> Function({
    bool? adConsentGranted,
    bool? analyticsConsent,
  }) onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (settings.adConsentRequired) ...[
          Text(
            strings.adConsentTitle,
            style: TextStyle(
              color: AppColors.textPrimaryFor(context),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _SettingsPreferenceWrap(
            children: [
              _PreferenceChip(
                label: strings.adConsentDisabledLabel,
                selected: !settings.adConsentGranted,
                onSelected: isSaving ? () {} : () => onSave(adConsentGranted: false),
              ),
              _PreferenceChip(
                label: strings.adConsentEnabledLabel,
                selected: settings.adConsentGranted,
                onSelected: isSaving ? () {} : () => onSave(adConsentGranted: true),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        Text(
          strings.analyticsConsentTitle,
          style: TextStyle(
            color: AppColors.textPrimaryFor(context),
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        _SettingsPreferenceWrap(
          children: [
            _PreferenceChip(
              label: strings.analyticsDisabledLabel,
              selected: !settings.analyticsConsent,
              onSelected: isSaving ? () {} : () => onSave(analyticsConsent: false),
            ),
            _PreferenceChip(
              label: strings.analyticsEnabledLabel,
              selected: settings.analyticsConsent,
              onSelected: isSaving ? () {} : () => onSave(analyticsConsent: true),
            ),
          ],
        ),
      ],
    );
  }
}

class _MonetizationRuntimePanels extends StatelessWidget {
  const _MonetizationRuntimePanels({
    required this.strings,
    required this.billingProviderStatus,
    required this.billingRuntimeStatus,
    required this.adProviderStatus,
    required this.adRuntimeStatus,
    required this.crashReportingStatus,
  });

  final AppStrings strings;
  final BillingProviderStatusSnapshot? billingProviderStatus;
  final BillingRuntimeStatus? billingRuntimeStatus;
  final AdProviderStatusSnapshot? adProviderStatus;
  final AdRuntimeStatus? adRuntimeStatus;
  final CrashReportingStatus? crashReportingStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsInfoPanel(body: strings.billingFoundationBody),
        if (billingProviderStatus != null) ...[
          const SizedBox(height: 14),
          _SettingsInfoPanel(
            body: strings.storeProviderStatusBody(
              providerLabel: strings.billingProviderLabel(
                billingProviderStatus!.provider,
              ),
              configured: billingProviderStatus!.configured,
              runtimeReady: billingRuntimeStatus?.fullyReady ?? false,
            ),
          ),
        ],
        if (adProviderStatus != null) ...[
          const SizedBox(height: 14),
          _SettingsInfoPanel(
            body: strings.adProviderStatusBody(
              providerLabel: strings.adProviderLabel(
                adProviderStatus!.provider,
              ),
              configured: adProviderStatus!.configured,
              bannerConfigured: adProviderStatus!.bannerUnitConfigured,
            ),
          ),
        ],
        if (adRuntimeStatus != null) ...[
          const SizedBox(height: 14),
          _SettingsInfoPanel(
            body: strings.adRuntimeStatusBody(
              sdkReady: adRuntimeStatus!.sdkReady,
              usingTestIdentifiers: adRuntimeStatus!.usingTestIdentifiers,
              bannerReady: adRuntimeStatus!.bannerReady,
            ),
          ),
        ],
        if (crashReportingStatus != null) ...[
          const SizedBox(height: 14),
          _SettingsInfoPanel(
            body: strings.crashReportingStatusBody(
              providerLabel: crashReportingStatus!.providerLabel,
              available: crashReportingStatus!.available,
              reason: crashReportingStatus!.reason,
            ),
          ),
        ],
      ],
    );
  }
}
