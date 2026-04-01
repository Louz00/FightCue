import 'api_models.dart';
import '../models/domain_models.dart';

HomeSnapshot mapHomeSnapshot(Map<String, dynamic> json) {
  return HomeSnapshotJson.fromJson(json).toMobile();
}

EventDetailSnapshot mapEventDetailSnapshot(Map<String, dynamic> json) {
  return EventDetailSnapshotJson.fromJson(json).toMobile();
}

FighterDetailSnapshot mapFighterDetailSnapshot(Map<String, dynamic> json) {
  return FighterDetailSnapshotJson.fromJson(json).toMobile();
}

AlertsSnapshot mapAlertsSnapshot(Map<String, dynamic> json) {
  return AlertsSnapshotJson.fromJson(json).toMobile();
}

PushSettingsSnapshot mapPushSettingsSnapshot(Map<String, dynamic> json) {
  return PushSettingsSnapshotJson.fromJson(json).toMobile();
}

PushPreviewSnapshot mapPushPreviewSnapshot(Map<String, dynamic> json) {
  return PushPreviewSnapshotJson.fromJson(json).toMobile();
}

PushProviderStatusSnapshot mapPushProviderStatusSnapshot(
  Map<String, dynamic> json,
) {
  return PushProviderStatusSnapshotJson.fromJson(json).toMobile();
}

PushTestDispatchSnapshot mapPushTestDispatchSnapshot(
  Map<String, dynamic> json,
) {
  return PushTestDispatchSnapshotJson.fromJson(json).toMobile();
}

BillingProviderStatusSnapshot mapBillingProviderStatusSnapshot(
  Map<String, dynamic> json,
) {
  return BillingProviderStatusSnapshotJson.fromJson(json).toMobile();
}

AdProviderStatusSnapshot mapAdProviderStatusSnapshot(
  Map<String, dynamic> json,
) {
  return AdProviderStatusSnapshotJson.fromJson(json).toMobile();
}

MonetizationSnapshot mapMonetizationSnapshot(Map<String, dynamic> json) {
  return MonetizationSnapshotJson.fromJson(json).toMobile();
}

UfcSourcePreview mapUfcSourcePreview(Map<String, dynamic> json) {
  final items = (json['items'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(EventSummaryJson.fromJson)
      .map((entry) => entry.toMobile())
      .toList();

  return UfcSourcePreview(
    mode: json['mode'] as String? ?? 'fallback',
    warnings: (json['warnings'] as List<dynamic>? ?? const [])
        .map((value) => value.toString())
        .toList(),
    items: items,
  );
}

List<LeaderboardSummary> mapLeaderboardSummaries(Map<String, dynamic> json) {
  return (json['items'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(LeaderboardSummaryJson.fromJson)
      .map((entry) => entry.toMobile())
      .toList();
}

EventSummary mapEventSummaryItem(Map<String, dynamic> json) {
  return EventSummaryJson.fromJson(json).toMobile();
}

FighterSummary mapFighterSummaryItem(Map<String, dynamic> json) {
  return FighterSummaryJson.fromJson(json).toMobile();
}
