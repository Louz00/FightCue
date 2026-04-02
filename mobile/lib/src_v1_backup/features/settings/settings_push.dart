part of 'settings_screen.dart';

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
