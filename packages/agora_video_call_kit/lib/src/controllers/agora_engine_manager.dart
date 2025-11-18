import 'dart:developer' as dev;

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';

import '../models/agora_call_config.dart';
import '../models/remote_user.dart';

/// Manages the Agora RTC Engine lifecycle and operations
///
/// This class handles initialization, channel operations, and event callbacks
/// from the Agora SDK.
class AgoraEngineManager {
  RtcEngine? _engine;
  final AgoraCallConfig config;

  /// Current local user ID (assigned after joining)
  int? _localUid;

  /// Callbacks
  final VoidCallback? onJoinSuccess;
  final Function(int uid)? onUserJoined;
  final Function(int uid, UserOfflineReasonType reason)? onUserOffline;
  final Function(RtcConnection connection, RtcStats stats)? onLeaveChannel;
  final Function(ErrorCodeType err, String msg)? onError;
  final Function(RtcConnection connection, int elapsed)? onJoinChannelSuccess;
  final Function(ConnectionStateType state, ConnectionChangedReasonType reason)?
      onConnectionStateChanged;
  final Function(int uid, bool muted)? onRemoteAudioStateChanged;
  final Function(int uid, RemoteVideoState state, RemoteVideoStateReason reason)?
      onRemoteVideoStateChanged;

  AgoraEngineManager({
    required this.config,
    this.onJoinSuccess,
    this.onUserJoined,
    this.onUserOffline,
    this.onLeaveChannel,
    this.onError,
    this.onJoinChannelSuccess,
    this.onConnectionStateChanged,
    this.onRemoteAudioStateChanged,
    this.onRemoteVideoStateChanged,
  });

  /// Get the RTC engine instance
  RtcEngine? get engine => _engine;

  /// Get the local user ID
  int? get localUid => _localUid;

  /// Initialize the Agora RTC Engine
  Future<void> initialize() async {
    if (_engine != null) {
      dev.log('Engine already initialized', name: 'AgoraEngineManager');
      return;
    }

    try {
      // Create engine instance
      _engine = createAgoraRtcEngine();

      // Initialize with app ID
      await _engine!.initialize(RtcEngineContext(
        appId: config.appId,
        channelProfile: config.channelProfile,
        areaCode: AreaCode.areaCodeGlob.value(),
      ));

      // Register event handlers
      _engine!.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          dev.log(
            'Local user ${connection.localUid} joined channel ${connection.channelId}',
            name: 'AgoraEngineManager',
          );
          _localUid = connection.localUid;
          onJoinChannelSuccess?.call(connection, elapsed);
          onJoinSuccess?.call();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          dev.log(
            'Remote user $remoteUid joined',
            name: 'AgoraEngineManager',
          );
          onUserJoined?.call(remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          dev.log(
            'Remote user $remoteUid left: $reason',
            name: 'AgoraEngineManager',
          );
          onUserOffline?.call(remoteUid, reason);
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          dev.log(
            'Left channel ${connection.channelId}',
            name: 'AgoraEngineManager',
          );
          _localUid = null;
          onLeaveChannel?.call(connection, stats);
        },
        onError: (ErrorCodeType err, String msg) {
          dev.log(
            'Error: $err - $msg',
            name: 'AgoraEngineManager',
            error: err,
          );
          onError?.call(err, msg);
        },
        onConnectionStateChanged: (RtcConnection connection,
            ConnectionStateType state, ConnectionChangedReasonType reason) {
          dev.log(
            'Connection state changed: $state (reason: $reason)',
            name: 'AgoraEngineManager',
          );
          onConnectionStateChanged?.call(state, reason);
        },
        onRemoteAudioStateChanged: (RtcConnection connection, int remoteUid,
            RemoteAudioState state, RemoteAudioStateReason reason, int elapsed) {
          final isMuted = state == RemoteAudioState.remoteAudioStateStopped;
          dev.log(
            'Remote user $remoteUid audio state: $state',
            name: 'AgoraEngineManager',
          );
          onRemoteAudioStateChanged?.call(remoteUid, isMuted);
        },
        onRemoteVideoStateChanged: (RtcConnection connection, int remoteUid,
            RemoteVideoState state, RemoteVideoStateReason reason, int elapsed) {
          dev.log(
            'Remote user $remoteUid video state: $state',
            name: 'AgoraEngineManager',
          );
          onRemoteVideoStateChanged?.call(remoteUid, state, reason);
        },
      ));

      // Enable video
      await _engine!.enableVideo();

      // Enable audio
      await _engine!.enableAudio();

      // Set client role
      await _engine!.setClientRole(role: config.role);

      // Configure video encoder if provided
      if (config.videoEncoderConfig != null) {
        await _engine!.setVideoEncoderConfiguration(config.videoEncoderConfig!);
      } else {
        // Use default configuration
        await _engine!.setVideoEncoderConfiguration(
          const VideoEncoderConfiguration(
            dimensions: VideoDimensions(width: 640, height: 480),
            frameRate: 15,
            bitrate: 0, // Standard bitrate
          ),
        );
      }

      dev.log('Engine initialized successfully', name: 'AgoraEngineManager');
    } catch (e) {
      dev.log('Failed to initialize engine', name: 'AgoraEngineManager', error: e);
      rethrow;
    }
  }

  /// Join the configured channel
  Future<void> joinChannel() async {
    if (_engine == null) {
      throw Exception('Engine not initialized. Call initialize() first.');
    }

    try {
      await _engine!.joinChannel(
        token: config.token ?? '',
        channelId: config.channelName,
        uid: config.uid,
        options: ChannelMediaOptions(
          channelProfile: config.channelProfile,
          clientRoleType: config.role,
          publishMicrophoneTrack: config.enableAudio,
          publishCameraTrack: config.enableVideo,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );

      dev.log('Joining channel: ${config.channelName}', name: 'AgoraEngineManager');
    } catch (e) {
      dev.log('Failed to join channel', name: 'AgoraEngineManager', error: e);
      rethrow;
    }
  }

  /// Leave the current channel
  Future<void> leaveChannel() async {
    if (_engine == null) return;

    try {
      await _engine!.leaveChannel();
      dev.log('Left channel', name: 'AgoraEngineManager');
    } catch (e) {
      dev.log('Error leaving channel', name: 'AgoraEngineManager', error: e);
    }
  }

  /// Mute/unmute local audio
  Future<void> muteLocalAudio(bool muted) async {
    if (_engine == null) return;
    await _engine!.muteLocalAudioStream(muted);
    dev.log('Local audio ${muted ? "muted" : "unmuted"}', name: 'AgoraEngineManager');
  }

  /// Enable/disable local video
  Future<void> enableLocalVideo(bool enabled) async {
    if (_engine == null) return;
    await _engine!.muteLocalVideoStream(!enabled);
    dev.log('Local video ${enabled ? "enabled" : "disabled"}', name: 'AgoraEngineManager');
  }

  /// Switch between front and rear camera
  Future<void> switchCamera() async {
    if (_engine == null) return;
    await _engine!.switchCamera();
    dev.log('Camera switched', name: 'AgoraEngineManager');
  }

  /// Set audio route to speaker or earpiece
  Future<void> setEnableSpeakerphone(bool enabled) async {
    if (_engine == null) return;
    await _engine!.setEnableSpeakerphone(enabled);
    dev.log('Speakerphone ${enabled ? "enabled" : "disabled"}', name: 'AgoraEngineManager');
  }

  /// Destroy the engine and release resources
  Future<void> dispose() async {
    if (_engine == null) return;

    try {
      await _engine!.leaveChannel();
      await _engine!.release();
      _engine = null;
      _localUid = null;
      dev.log('Engine disposed', name: 'AgoraEngineManager');
    } catch (e) {
      dev.log('Error disposing engine', name: 'AgoraEngineManager', error: e);
    }
  }
}
