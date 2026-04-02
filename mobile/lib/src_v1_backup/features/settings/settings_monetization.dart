part of 'settings_screen.dart';

class _MonetizationCard extends StatefulWidget {
  const _MonetizationCard({
    required this.api,
    required this.strings,
    required this.snapshot,
    this.billingRuntimeService,
    this.adRuntimeLoader,
    this.crashReportingLoader,
    this.onChanged,
  });

  final FightCueApi api;
  final AppStrings strings;
  final HomeSnapshot snapshot;
  final BillingRuntimeService? billingRuntimeService;
  final Future<AdRuntimeStatus> Function()? adRuntimeLoader;
  final Future<CrashReportingStatus> Function()? crashReportingLoader;
  final ValueChanged<MonetizationSnapshot>? onChanged;

  @override
  State<_MonetizationCard> createState() => _MonetizationCardState();
}

class _MonetizationCardState extends State<_MonetizationCard> {
  MonetizationSnapshot? _settings;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasError = false;
  bool _usingCachedFallback = false;
  DateTime? _lastSyncedAt;
  bool _didRequestStaleRefresh = false;
  BillingProviderStatusSnapshot? _billingProviderStatus;
  BillingRuntimeStatus? _billingRuntimeStatus;
  AdProviderStatusSnapshot? _adProviderStatus;
  AdRuntimeStatus? _adRuntimeStatus;
  CrashReportingStatus? _crashReportingStatus;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    return _loadInternal(resetStaleRefresh: true);
  }

  Future<void> _loadInternal({required bool resetStaleRefresh}) async {
    if (resetStaleRefresh) {
      _didRequestStaleRefresh = false;
    }

    try {
      final result = await widget.api.fetchMonetizationResult();
      final billingProviderStatus = await widget.api.fetchBillingProviderStatus();
      final adProviderStatus = await widget.api.fetchAdProviderStatus();
      final billingRuntimeStatus =
          await (widget.billingRuntimeService ?? BillingRuntimeService()).getStatus(
        billingProviderStatus.productIds,
      );
      final adRuntimeStatus =
          await (widget.adRuntimeLoader ?? ensureAdMobReady)();
      final crashReportingStatus =
          await (widget.crashReportingLoader ?? ensureCrashReportingReady)();
      if (!mounted) {
        return;
      }
      setState(() {
        _settings = result.data;
        _billingProviderStatus = billingProviderStatus;
        _billingRuntimeStatus = billingRuntimeStatus;
        _adProviderStatus = adProviderStatus;
        _adRuntimeStatus = adRuntimeStatus;
        _crashReportingStatus = crashReportingStatus;
        _hasError = false;
        _usingCachedFallback = result.isFromCache;
        _lastSyncedAt = result.lastSyncedAt;
        _didRequestStaleRefresh = false;
      });
      widget.onChanged?.call(result.data);
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'settings.load_monetization');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _save({
    bool? adConsentGranted,
    bool? analyticsConsent,
  }) async {
    final current = _settings;
    if (current == null) {
      return;
    }

    final optimistic = current.copyWith(
      adConsentGranted: adConsentGranted,
      analyticsConsent: analyticsConsent,
      quietAdsEnabled: current.premiumState == PremiumState.free &&
          (!current.adConsentRequired ||
              (adConsentGranted ?? current.adConsentGranted)),
    );

    setState(() {
      _settings = optimistic;
      _isSaving = true;
      _hasError = false;
    });
    widget.onChanged?.call(optimistic);

    try {
      final saved = await widget.api.updateMonetizationSettings(
        adConsentGranted: adConsentGranted,
        analyticsConsent: analyticsConsent,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _settings = saved;
      });
      widget.onChanged?.call(saved);
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'settings.update_monetization');
      if (mounted) {
        setState(() {
          _settings = current;
          _hasError = true;
        });
      }
      widget.onChanged?.call(current);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    final settings = _settings ??
        MonetizationSnapshot(
          premiumState: widget.snapshot.premiumState,
          adTier: widget.snapshot.adTier,
          adConsentRequired: widget.snapshot.adConsentRequired,
          adConsentGranted: widget.snapshot.adConsentGranted,
          analyticsConsent: widget.snapshot.analyticsConsent,
          quietAdsEnabled: widget.snapshot.quietAdsEnabled,
        );
    final isStaleCachedSettings = _usingCachedFallback &&
        _lastSyncedAt != null &&
        DateTime.now().toUtc().difference(_lastSyncedAt!.toUtc()) >
            ApiFetchResult.staleThreshold;

    if (isStaleCachedSettings && !_didRequestStaleRefresh) {
      _didRequestStaleRefresh = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadInternal(resetStaleRefresh: false);
        }
      });
    } else if (!isStaleCachedSettings) {
      _didRequestStaleRefresh = false;
    }

    final planLabel = settings.premiumState == PremiumState.premium
        ? strings.premiumPlanLabel
        : strings.freePlanLabel;

    return _SettingCard(
      title: strings.monetizationTitle,
      body: _hasError
          ? strings.monetizationFallbackBody
          : _usingCachedFallback
              ? strings.savedTimestampBody(
                  strings.savedMonetizationBody,
                  _lastSyncedAt,
                  isStale: isStaleCachedSettings,
                )
              : strings.monetizationBody,
      icon: Icons.workspace_premium_outlined,
      child: _isLoading && _settings == null
          ? const LinearProgressIndicator(minHeight: 3)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusPill(label: planLabel),
                    _StatusPill(
                      label: settings.quietAdsEnabled
                          ? strings.quietAdsEnabledLabel
                          : strings.quietAdsDisabledLabel,
                    ),
                    if (_usingCachedFallback)
                      _StatusPill(label: strings.savedMonetizationTitle),
                    if (_isSaving)
                      _StatusPill(label: strings.monetizationSavingLabel),
                  ],
                ),
                const SizedBox(height: 14),
                _MonetizationConsentControls(
                  strings: strings,
                  settings: settings,
                  isSaving: _isSaving,
                  onSave: _save,
                ),
                const SizedBox(height: 14),
                _MonetizationRuntimePanels(
                  strings: strings,
                  billingProviderStatus: _billingProviderStatus,
                  billingRuntimeStatus: _billingRuntimeStatus,
                  adProviderStatus: _adProviderStatus,
                  adRuntimeStatus: _adRuntimeStatus,
                  crashReportingStatus: _crashReportingStatus,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PaywallScreen(
                            api: widget.api,
                            strings: strings,
                            snapshot: settings,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.workspace_premium_outlined),
                    label: Text(strings.paywallViewPlansLabel),
                  ),
                ),
              ],
            ),
    );
  }
}
