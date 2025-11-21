import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import 'analytics_provider.dart';

/// Mixpanel implementation of AnalyticsProvider
///
/// Usage:
/// ```dart
/// final mixpanel = await Mixpanel.init('YOUR_TOKEN');
/// final analytics = MixpanelAnalyticsProvider(mixpanel);
/// ```
class MixpanelAnalyticsProvider implements AnalyticsProvider {
  final Mixpanel mixpanel;
  final Map<String, DateTime> _timedEvents = {};

  MixpanelAnalyticsProvider(this.mixpanel);

  @override
  Future<void> trackEvent(String eventName, [Map<String, dynamic>? properties]) async {
    mixpanel.track(eventName, properties: properties);
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    for (final entry in properties.entries) {
      mixpanel.getPeople().set(entry.key, entry.value);
    }
  }

  @override
  Future<void> startTimedEvent(String eventName) async {
    _timedEvents[eventName] = DateTime.now();
    mixpanel.timeEvent(eventName);
  }

  @override
  Future<void> endTimedEvent(String eventName, [Map<String, dynamic>? properties]) async {
    final startTime = _timedEvents.remove(eventName);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      final props = {...?properties, 'duration_ms': duration.inMilliseconds};
      mixpanel.track(eventName, properties: props);
    } else {
      mixpanel.track(eventName, properties: properties);
    }
  }
}
