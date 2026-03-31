import 'domain_models.dart';

BoutSummary? headlineBoutForEvent(EventSummary event) {
  for (final bout in event.bouts) {
    if (bout.isMainEvent) {
      return bout;
    }
  }

  if (event.bouts.isEmpty) {
    return null;
  }

  return event.bouts.first;
}

String? primaryWatchProviderLabel(EventSummary event) {
  if (event.watchProviders.isEmpty) {
    return null;
  }

  return event.watchProviders.first.label;
}
