part of 'settings_screen.dart';

class _SettingsPreferenceWrap extends StatelessWidget {
  const _SettingsPreferenceWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: children,
    );
  }
}

class _HighlightSettingsCard extends StatelessWidget {
  const _HighlightSettingsCard({
    required this.accountModeLabel,
    required this.planLabel,
    required this.timezone,
    required this.strings,
  });

  final String accountModeLabel;
  final String planLabel;
  final String timezone;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppShadows.cardFor(context),
      ),
      child: Column(
        children: [
          EditorialCardHeaderBand(
            pillLabel: strings.accountModelTitle,
            title: planLabel,
            trailingLabel: timezone,
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: _QuickStat(
                    label: strings.accountModelTitle,
                    value: accountModeLabel,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickStat(
                    label: strings.currentPlanTitle,
                    value: planLabel,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickStat(
                    label: strings.currentTimezoneTitle,
                    value: timezone,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final surfaceAlt = AppColors.surfaceAltFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);
    final textPrimary = AppColors.textPrimaryFor(context);

    return Semantics(
      label: '$label: $value',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.title,
    required this.body,
    required this.icon,
    this.child,
  });

  final String title;
  final String body;
  final IconData icon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final surfaceAlt = AppColors.surfaceAltFor(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);

    return Semantics(
      container: true,
      label: title,
      child: EditorialSurfaceCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: textPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: TextStyle(
                      color: textSecondary,
                      height: 1.45,
                    ),
                  ),
                  if (child != null) ...[
                    const SizedBox(height: 14),
                    child!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceChip extends StatelessWidget {
  const _PreferenceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        selectedColor: AppColors.accent,
        backgroundColor: AppColors.surfaceAltFor(context),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textPrimaryFor(context),
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? AppColors.accent : AppColors.borderFor(context),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        showCheckmark: false,
      ),
    );
  }
}

class _PushSettingsCard extends StatefulWidget {
  const _PushSettingsCard({
    required this.api,
    required this.strings,
    this.pushDeliveryService,
  });

  final FightCueApi api;
  final AppStrings strings;
  final PushDeliveryService? pushDeliveryService;

  @override
  State<_PushSettingsCard> createState() => _PushSettingsCardState();
}

class _MonetizationCard extends StatefulWidget {
  const _MonetizationCard({
    required this.api,
    required this.strings,
    required this.snapshot,
    this.billingRuntimeService,
    this.onChanged,
  });

  final FightCueApi api;
  final AppStrings strings;
  final HomeSnapshot snapshot;
  final BillingRuntimeService? billingRuntimeService;
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
      if (!mounted) {
        return;
      }
      setState(() {
        _settings = result.data;
        _billingProviderStatus = billingProviderStatus;
        _billingRuntimeStatus = billingRuntimeStatus;
        _adProviderStatus = adProviderStatus;
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
                if (settings.adConsentRequired) ...[
                  const SizedBox(height: 14),
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
                        onSelected: _isSaving
                            ? () {}
                            : () => _save(adConsentGranted: false),
                      ),
                      _PreferenceChip(
                        label: strings.adConsentEnabledLabel,
                        selected: settings.adConsentGranted,
                        onSelected: _isSaving
                            ? () {}
                            : () => _save(adConsentGranted: true),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
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
                      onSelected: _isSaving
                          ? () {}
                          : () => _save(analyticsConsent: false),
                    ),
                    _PreferenceChip(
                      label: strings.analyticsEnabledLabel,
                      selected: settings.analyticsConsent,
                      onSelected: _isSaving
                          ? () {}
                          : () => _save(analyticsConsent: true),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAltFor(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    strings.billingFoundationBody,
                    style: TextStyle(
                      color: AppColors.textSecondaryFor(context),
                      height: 1.4,
                    ),
                  ),
                ),
                if (_billingProviderStatus != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAltFor(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      strings.storeProviderStatusBody(
                        providerLabel: strings.billingProviderLabel(
                          _billingProviderStatus!.provider,
                        ),
                        configured: _billingProviderStatus!.configured,
                        runtimeReady: _billingRuntimeStatus?.fullyReady ?? false,
                      ),
                      style: TextStyle(
                        color: AppColors.textSecondaryFor(context),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                if (_adProviderStatus != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAltFor(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      strings.adProviderStatusBody(
                        providerLabel: strings.adProviderLabel(
                          _adProviderStatus!.provider,
                        ),
                        configured: _adProviderStatus!.configured,
                        bannerConfigured:
                            _adProviderStatus!.bannerUnitConfigured,
                      ),
                      style: TextStyle(
                        color: AppColors.textSecondaryFor(context),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
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

class _PushSettingsCardState extends State<_PushSettingsCard> {
  late final PushDeliveryService _pushDeliveryService;
  PushSettingsSnapshot? _settings;
  PushPreviewSnapshot? _preview;
  PushProviderStatusSnapshot? _providerStatus;
  String? _testStatusLabel;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasError = false;
  bool _usingCachedFallback = false;
  DateTime? _lastSyncedAt;
  bool _didRequestStaleRefresh = false;

  @override
  void initState() {
    super.initState();
    _pushDeliveryService =
        widget.pushDeliveryService ?? NativePushDeliveryService();
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
      final results = await Future.wait([
        widget.api.fetchPushSettingsResult(),
        widget.api.fetchPushPreviewResult(),
        widget.api.fetchPushProviderStatus(),
      ]);
      final result = results[0] as ApiFetchResult<PushSettingsSnapshot>;
      final previewResult = results[1] as ApiFetchResult<PushPreviewSnapshot>;
      final providerStatus = results[2] as PushProviderStatusSnapshot;
      if (mounted) {
        setState(() {
          _settings = result.data;
          _preview = previewResult.data;
          _providerStatus = providerStatus;
          _hasError = false;
          _usingCachedFallback = result.isFromCache || previewResult.isFromCache;
          _lastSyncedAt = result.lastSyncedAt ?? previewResult.lastSyncedAt;
          _didRequestStaleRefresh = false;
        });
      }
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'settings.load_push');
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

  Future<void> _setEnabled(bool enabled) async {
    final current = _settings;
    if (current == null) {
      return;
    }

    final optimistic = current.copyWith(
      pushEnabled: enabled,
      permissionStatus: enabled
          ? (current.permissionStatus == PushPermissionStatus.unknown
                ? PushPermissionStatus.prompt
                : current.permissionStatus)
          : current.permissionStatus,
    );

    setState(() {
      _settings = optimistic;
      _isSaving = true;
      _hasError = false;
    });

    try {
      final saved = await widget.api.updatePushSettings(
        pushEnabled: enabled,
        permissionStatus: optimistic.permissionStatus,
      );
      if (mounted) {
        setState(() {
          _settings = saved;
          _preview = _preview?.copyWith(
            deliveryReadiness: saved.permissionStatus == PushPermissionStatus.granted &&
                    saved.tokenRegistered
                ? PushDeliveryReadiness.ready
                : saved.permissionStatus == PushPermissionStatus.granted
                ? PushDeliveryReadiness.tokenMissing
                : saved.pushEnabled
                ? PushDeliveryReadiness.permissionRequired
                : PushDeliveryReadiness.disabled,
          );
        });
      }
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'settings.update_push');
      if (mounted) {
        setState(() {
          _settings = current;
          _hasError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _syncDevicePush({required bool requestPermission}) async {
    final current = _settings;
    if (current == null) {
      return;
    }

    setState(() {
      _isSaving = true;
      _hasError = false;
    });

    try {
      final delivery = requestPermission
          ? await _pushDeliveryService.requestPermission()
          : await _pushDeliveryService.getStatus();
      final saved = await widget.api.registerPushToken(
        permissionStatus: delivery.permissionStatus,
        tokenPlatform: delivery.platform,
        tokenValue: delivery.tokenValue,
      );
      if (mounted) {
        setState(() {
          _settings = saved;
          _usingCachedFallback = false;
          _lastSyncedAt = DateTime.now().toUtc();
          _testStatusLabel = null;
        });
      }
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'settings.sync_device_push');
      if (mounted) {
        setState(() {
          _settings = current;
          _hasError = true;
        });
      }
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
    final settings = _settings;
    final preview = _preview;
    final providerStatus = _providerStatus;
    final pushDetailBody = settings == null
        ? strings.pushSetupBody
        : switch ((settings.permissionStatus, settings.tokenRegistered)) {
            (PushPermissionStatus.denied, _) => strings.pushPermissionDeniedBody,
            (PushPermissionStatus.granted, false) => strings.pushTokenPendingBody,
            (PushPermissionStatus.granted, true) => strings.pushTokenReadyBody,
            _ => strings.pushPermissionPromptBody,
          };
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

    return _SettingCard(
      title: strings.pushSetupTitle,
      body: _hasError
          ? strings.pushSetupFallbackBody
          : _usingCachedFallback
              ? strings.savedTimestampBody(
                  strings.savedPushBody,
                  _lastSyncedAt,
                  isStale: isStaleCachedSettings,
                )
              : settings == null
              ? strings.pushSetupBody
              : '${strings.pushStatusSummary(
                  enabled: settings.pushEnabled,
                  permissionLabel: strings.pushPermissionLabel(
                    settings.permissionStatus,
                  ),
                  tokenLabel: settings.tokenRegistered
                      ? strings.pushTokenRegisteredLabel
                      : strings.pushTokenMissingLabel,
                )}\n\n$pushDetailBody',
      icon: Icons.notifications_active_outlined,
      child: _isLoading && settings == null
          ? const LinearProgressIndicator(minHeight: 3)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsPreferenceWrap(
                  children: [
                    _PreferenceChip(
                      label: strings.pushOffLabel,
                      selected: settings?.pushEnabled == false,
                      onSelected: _isSaving ? () {} : () => _setEnabled(false),
                    ),
                    _PreferenceChip(
                      label: strings.pushQuietAlertsLabel,
                      selected: settings?.pushEnabled == true,
                      onSelected: _isSaving ? () {} : () => _setEnabled(true),
                    ),
                    if (_usingCachedFallback)
                      _StatusPill(label: strings.savedPushTitle),
                    if (_isSaving)
                      _StatusPill(label: strings.pushSavingLabel)
                    else if (settings != null)
                      _StatusPill(
                        label: strings.pushPermissionLabel(settings.permissionStatus),
                      ),
                    if (settings != null)
                      _StatusPill(
                        label: settings.tokenRegistered
                            ? strings.pushDeviceReadyLabel
                            : strings.pushDevicePendingLabel,
                      ),
                    if (preview != null)
                      _StatusPill(
                        label: strings.pushReadinessLabel(preview.deliveryReadiness),
                      ),
                    if (providerStatus != null)
                      _StatusPill(
                        label: strings.pushProviderLabel(providerStatus.provider),
                      ),
                  ],
                ),
                if (preview != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    strings.pushPreviewCountsLabel(
                      scheduledCount: preview.scheduledCount,
                      signalCount: preview.signalCount,
                    ),
                    style: TextStyle(
                      color: AppColors.textSecondaryFor(context),
                      height: 1.4,
                    ),
                  ),
                ],
                if (providerStatus != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    strings.pushProviderStatusBody(
                      configured: providerStatus.configured,
                      description: providerStatus.description,
                    ),
                    style: TextStyle(
                      color: AppColors.textSecondaryFor(context),
                      height: 1.4,
                    ),
                  ),
                ],
                if (settings != null && settings.pushEnabled) ...[
                  const SizedBox(height: 14),
                  EditorialActionPill(
                    label: settings.permissionStatus == PushPermissionStatus.granted &&
                            settings.tokenRegistered
                        ? strings.pushRefreshDeviceAction
                        : strings.pushConnectDeviceAction,
                    emphasized: true,
                    onTap: _isSaving
                        ? () {}
                        : () => _syncDevicePush(
                              requestPermission:
                                  settings.permissionStatus !=
                                  PushPermissionStatus.granted,
                            ),
                  ),
                  if (preview?.deliveryReadiness == PushDeliveryReadiness.ready) ...[
                    const SizedBox(height: 10),
                    EditorialActionPill(
                      label: strings.pushSendTestAction,
                      onTap: _isSaving
                          ? () {}
                          : () async {
                              setState(() {
                                _isSaving = true;
                                _testStatusLabel = null;
                              });
                              try {
                                final result = await widget.api.sendTestPush();
                                if (!mounted) {
                                  return;
                                }
                                setState(() {
                                  _testStatusLabel = result.dispatched
                                      ? strings.pushTestQueuedLabel
                                      : result.message;
                                });
                              } catch (error, stackTrace) {
                                logUiError(
                                  error,
                                  stackTrace,
                                  context: 'settings.test_push',
                                );
                                if (!mounted) {
                                  return;
                                }
                                setState(() {
                                  _hasError = true;
                                });
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isSaving = false;
                                  });
                                }
                              }
                            },
                    ),
                  ],
                  if (_isSaving) ...[
                    const SizedBox(height: 10),
                    _StatusPill(label: strings.pushDeviceLinkingLabel),
                  ] else if (_testStatusLabel != null) ...[
                    const SizedBox(height: 10),
                    _StatusPill(label: _testStatusLabel!),
                  ],
                ],
              ],
            ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltFor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Semantics(
        label: label,
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondaryFor(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
