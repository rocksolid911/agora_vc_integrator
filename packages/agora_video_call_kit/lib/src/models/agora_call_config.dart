import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../monitoring/agora_logger.dart';

/// Configuration class for Agora video calls
///
/// This class contains all the necessary configuration parameters
/// to initialize and join an Agora video call.
class AgoraCallConfig {
  /// Agora App ID from your Agora Console project
  final String appId;

  /// Channel name to join (must be unique per call session)
  final String channelName;

  /// Token for authentication (can be null for testing without security)
  /// For production, always use a valid token from your token server
  final String? token;

  /// User ID (must be unique within the channel)
  /// If set to 0, Agora will auto-assign a UID
  final int uid;

  /// Client role type - broadcaster can send/receive, audience can only receive
  final ClientRoleType role;

  /// Enable or disable audio at call start
  final bool enableAudio;

  /// Enable or disable video at call start
  final bool enableVideo;

  /// Video encoding configuration
  final VideoEncoderConfiguration? videoEncoderConfig;

  /// Channel profile type
  final ChannelProfileType channelProfile;

  /// Optional custom user name for display
  final String? userName;

  /// Enable metrics tracking and analytics (default: false)
  final bool enableMetrics;

  /// Log level for debugging (default: error only)
  final LogLevel logLevel;

  const AgoraCallConfig({
    required this.appId,
    required this.channelName,
    this.token,
    this.uid = 0,
    this.role = ClientRoleType.clientRoleBroadcaster,
    this.enableAudio = true,
    this.enableVideo = true,
    this.videoEncoderConfig,
    this.channelProfile = ChannelProfileType.channelProfileCommunication,
    this.userName,
    this.enableMetrics = false,
    this.logLevel = LogLevel.error,
  });

  /// Convenience constructor for quick host setup
  factory AgoraCallConfig.host({
    required String appId,
    required String channelName,
    String? token,
    int uid = 0,
    String? userName,
  }) {
    return AgoraCallConfig(
      appId: appId,
      channelName: channelName,
      token: token,
      uid: uid,
      role: ClientRoleType.clientRoleBroadcaster,
      userName: userName,
    );
  }

  /// Convenience constructor for audience (view-only) setup
  factory AgoraCallConfig.audience({
    required String appId,
    required String channelName,
    String? token,
    int uid = 0,
    String? userName,
  }) {
    return AgoraCallConfig(
      appId: appId,
      channelName: channelName,
      token: token,
      uid: uid,
      role: ClientRoleType.clientRoleAudience,
      enableAudio: false,
      enableVideo: false,
      userName: userName,
    );
  }

  /// Copy with method for creating modified configurations
  AgoraCallConfig copyWith({
    String? appId,
    String? channelName,
    String? token,
    int? uid,
    ClientRoleType? role,
    bool? enableAudio,
    bool? enableVideo,
    VideoEncoderConfiguration? videoEncoderConfig,
    ChannelProfileType? channelProfile,
    String? userName,
    bool? enableMetrics,
    LogLevel? logLevel,
  }) {
    return AgoraCallConfig(
      appId: appId ?? this.appId,
      channelName: channelName ?? this.channelName,
      token: token ?? this.token,
      uid: uid ?? this.uid,
      role: role ?? this.role,
      enableAudio: enableAudio ?? this.enableAudio,
      enableVideo: enableVideo ?? this.enableVideo,
      videoEncoderConfig: videoEncoderConfig ?? this.videoEncoderConfig,
      channelProfile: channelProfile ?? this.channelProfile,
      userName: userName ?? this.userName,
      enableMetrics: enableMetrics ?? this.enableMetrics,
      logLevel: logLevel ?? this.logLevel,
    );
  }

  /// Validate the configuration
  bool get isValid {
    return appId.isNotEmpty && channelName.isNotEmpty;
  }

  /// Get validation error message if config is invalid
  String? get validationError {
    if (appId.isEmpty) return 'App ID is required';
    if (channelName.isEmpty) return 'Channel name is required';
    return null;
  }

  @override
  String toString() {
    return 'AgoraCallConfig(appId: $appId, channel: $channelName, uid: $uid, role: $role)';
  }
}
