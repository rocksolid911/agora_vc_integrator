import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../analytics/analytics_provider.dart';

/// Metrics tracked during a video call
class CallMetrics {
  /// Time when initialization started
  DateTime? initStartTime;

  /// Time when join was requested
  DateTime? joinStartTime;

  /// Time when successfully joined
  DateTime? joinSuccessTime;

  /// Time when call ended
  DateTime? endTime;

  /// Network quality (1-6, where 1 is excellent, 6 is down)
  int? lastNetworkQuality;

  /// Number of reconnection attempts
  int reconnectionAttempts = 0;

  /// Number of users who joined
  int usersJoined = 0;

  /// Number of users who left
  int usersLeft = 0;

  /// Errors encountered
  final List<String> errors = [];

  /// Channel name
  String? channelName;

  /// User ID
  int? uid;

  /// Calculate initialization duration in milliseconds
  int? get initDurationMs {
    if (initStartTime == null || joinStartTime == null) return null;
    return joinStartTime!.difference(initStartTime!).inMilliseconds;
  }

  /// Calculate join duration in milliseconds
  int? get joinDurationMs {
    if (joinStartTime == null || joinSuccessTime == null) return null;
    return joinSuccessTime!.difference(joinStartTime!).inMilliseconds;
  }

  /// Calculate total call duration in milliseconds
  int? get totalDurationMs {
    if (joinSuccessTime == null || endTime == null) return null;
    return endTime!.difference(joinSuccessTime!).inMilliseconds;
  }

  /// Convert metrics to map for analytics
  Map<String, dynamic> toMap() {
    return {
      'init_duration_ms': initDurationMs,
      'join_duration_ms': joinDurationMs,
      'total_duration_ms': totalDurationMs,
      'reconnection_attempts': reconnectionAttempts,
      'users_joined': usersJoined,
      'users_left': usersLeft,
      'errors_count': errors.length,
      'network_quality': lastNetworkQuality,
      'channel_name': channelName,
      'uid': uid,
      if (errors.isNotEmpty) 'errors': errors,
    };
  }

  /// Reset all metrics
  void reset() {
    initStartTime = null;
    joinStartTime = null;
    joinSuccessTime = null;
    endTime = null;
    lastNetworkQuality = null;
    reconnectionAttempts = 0;
    usersJoined = 0;
    usersLeft = 0;
    errors.clear();
    channelName = null;
    uid = null;
  }
}

/// Tracks and reports call metrics
class CallMetricsTracker {
  final AnalyticsProvider analyticsProvider;
  final CallMetrics metrics = CallMetrics();
  bool _enabled;

  CallMetricsTracker({
    required this.analyticsProvider,
    bool enabled = true,
  }) : _enabled = enabled;

  /// Enable or disable metrics tracking
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Track initialization start
  void trackInitStart() {
    if (!_enabled) return;
    metrics.initStartTime = DateTime.now();
    analyticsProvider.startTimedEvent('call_initialization');
  }

  /// Track join start
  void trackJoinStart(String channelName, int uid) {
    if (!_enabled) return;
    metrics.joinStartTime = DateTime.now();
    metrics.channelName = channelName;
    metrics.uid = uid;
    analyticsProvider.startTimedEvent('call_join');
  }

  /// Track successful join
  void trackJoinSuccess() {
    if (!_enabled) return;
    metrics.joinSuccessTime = DateTime.now();

    analyticsProvider.endTimedEvent('call_initialization', {
      'duration_ms': metrics.initDurationMs,
      'channel_name': metrics.channelName,
      'uid': metrics.uid,
    });

    analyticsProvider.endTimedEvent('call_join', {
      'duration_ms': metrics.joinDurationMs,
      'channel_name': metrics.channelName,
      'uid': metrics.uid,
    });

    analyticsProvider.trackEvent('call_joined', {
      'channel_name': metrics.channelName,
      'uid': metrics.uid,
      'init_duration_ms': metrics.initDurationMs,
      'join_duration_ms': metrics.joinDurationMs,
    });
  }

  /// Track user joined
  void trackUserJoined(int remoteUid) {
    if (!_enabled) return;
    metrics.usersJoined++;
    analyticsProvider.trackEvent('remote_user_joined', {
      'remote_uid': remoteUid,
      'channel_name': metrics.channelName,
      'total_users': metrics.usersJoined - metrics.usersLeft,
    });
  }

  /// Track user left
  void trackUserLeft(int remoteUid, UserOfflineReasonType reason) {
    if (!_enabled) return;
    metrics.usersLeft++;
    analyticsProvider.trackEvent('remote_user_left', {
      'remote_uid': remoteUid,
      'reason': reason.name,
      'channel_name': metrics.channelName,
    });
  }

  /// Track reconnection attempt
  void trackReconnection() {
    if (!_enabled) return;
    metrics.reconnectionAttempts++;
    analyticsProvider.trackEvent('call_reconnection', {
      'attempt': metrics.reconnectionAttempts,
      'channel_name': metrics.channelName,
    });
  }

  /// Track error
  void trackError(String errorType, String errorMessage) {
    if (!_enabled) return;
    metrics.errors.add('$errorType: $errorMessage');
    analyticsProvider.trackEvent('call_error', {
      'error_type': errorType,
      'error_message': errorMessage,
      'channel_name': metrics.channelName,
      'total_errors': metrics.errors.length,
    });
  }

  /// Track network quality
  void trackNetworkQuality(int quality) {
    if (!_enabled) return;
    metrics.lastNetworkQuality = quality;
    // Only track significant changes
    if (quality >= 4) {
      analyticsProvider.trackEvent('network_quality_poor', {
        'quality': quality,
        'channel_name': metrics.channelName,
      });
    }
  }

  /// Track call end
  void trackCallEnd({bool wasSuccessful = true}) {
    if (!_enabled) return;
    metrics.endTime = DateTime.now();

    final eventProps = {
      ...metrics.toMap(),
      'was_successful': wasSuccessful,
    };

    analyticsProvider.trackEvent(
      wasSuccessful ? 'call_ended' : 'call_failed',
      eventProps,
    );

    // Reset metrics for next call
    metrics.reset();
  }

  /// Track audio/video toggle
  void trackMediaToggle(String mediaType, bool enabled) {
    if (!_enabled) return;
    analyticsProvider.trackEvent('media_toggle', {
      'media_type': mediaType,
      'enabled': enabled,
      'channel_name': metrics.channelName,
    });
  }

  /// Track camera switch
  void trackCameraSwitch() {
    if (!_enabled) return;
    analyticsProvider.trackEvent('camera_switched', {
      'channel_name': metrics.channelName,
    });
  }
}
