/// Abstract interface for analytics providers
///
/// Implement this interface to integrate with your analytics service
/// (Mixpanel, Firebase Analytics, Amplitude, etc.)
abstract class AnalyticsProvider {
  /// Track an event with optional properties
  Future<void> trackEvent(String eventName, [Map<String, dynamic>? properties]);

  /// Set user properties
  Future<void> setUserProperties(Map<String, dynamic> properties);

  /// Track a timed event start
  Future<void> startTimedEvent(String eventName);

  /// Track a timed event end
  Future<void> endTimedEvent(String eventName, [Map<String, dynamic>? properties]);
}

/// No-op implementation for when analytics is disabled
class NoOpAnalyticsProvider implements AnalyticsProvider {
  const NoOpAnalyticsProvider();

  @override
  Future<void> trackEvent(String eventName, [Map<String, dynamic>? properties]) async {}

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {}

  @override
  Future<void> startTimedEvent(String eventName) async {}

  @override
  Future<void> endTimedEvent(String eventName, [Map<String, dynamic>? properties]) async {}
}

/// Console logging analytics provider (for debugging)
class ConsoleAnalyticsProvider implements AnalyticsProvider {
  final Map<String, DateTime> _timedEvents = {};

  @override
  Future<void> trackEvent(String eventName, [Map<String, dynamic>? properties]) async {
    print('[Analytics] Event: $eventName${properties != null ? ' - $properties' : ''}');
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    print('[Analytics] User Properties: $properties');
  }

  @override
  Future<void> startTimedEvent(String eventName) async {
    _timedEvents[eventName] = DateTime.now();
    print('[Analytics] Started timing: $eventName');
  }

  @override
  Future<void> endTimedEvent(String eventName, [Map<String, dynamic>? properties]) async {
    final startTime = _timedEvents.remove(eventName);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      final props = {...?properties, 'duration_ms': duration.inMilliseconds};
      print('[Analytics] Timed Event: $eventName - ${duration.inMilliseconds}ms - $props');
    }
  }
}
