import 'dart:developer' as dev;

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';

import '../models/agora_call_config.dart';
import '../models/agora_call_state.dart';
import '../models/remote_user.dart';
import '../providers/agora_token_provider.dart';
import 'agora_engine_manager.dart';

/// Controller for managing Agora video call state and operations
///
/// This controller provides a high-level API for:
/// - Starting and ending calls
/// - Managing local audio/video
/// - Tracking remote users
/// - Monitoring call state
class AgoraVideoCallController extends ChangeNotifier {
  final AgoraCallConfig config;
  final AgoraTokenProvider? tokenProvider;

  late final AgoraEngineManager _engineManager;

  // State
  AgoraCallState _callState = AgoraCallState.idle;
  final Map<int, RemoteUser> _remoteUsers = {};
  bool _isAudioMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerEnabled = true;
  String? _errorMessage;
  int? _localUid;

  // Getters
  AgoraCallState get callState => _callState;
  Map<int, RemoteUser> get remoteUsers => Map.unmodifiable(_remoteUsers);
  List<RemoteUser> get remoteUsersList => _remoteUsers.values.toList();
  bool get isAudioMuted => _isAudioMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isSpeakerEnabled => _isSpeakerEnabled;
  String? get errorMessage => _errorMessage;
  int? get localUid => _localUid;
  RtcEngine? get engine => _engineManager.engine;

  AgoraVideoCallController({
    required this.config,
    this.tokenProvider,
  }) {
    _isAudioMuted = !config.enableAudio;
    _isVideoEnabled = config.enableVideo;
    _initializeEngineManager();
  }

  void _initializeEngineManager() {
    _engineManager = AgoraEngineManager(
      config: config,
      onJoinSuccess: _handleJoinSuccess,
      onUserJoined: _handleUserJoined,
      onUserOffline: _handleUserOffline,
      onError: _handleError,
      onConnectionStateChanged: _handleConnectionStateChanged,
      onRemoteAudioStateChanged: _handleRemoteAudioStateChanged,
      onRemoteVideoStateChanged: _handleRemoteVideoStateChanged,
      onJoinChannelSuccess: (connection, elapsed) {
        _localUid = connection.localUid;
        notifyListeners();
      },
    );
  }

  /// Initialize and join the call
  Future<void> startCall() async {
    if (!config.isValid) {
      _setError('Invalid configuration: ${config.validationError}');
      return;
    }

    try {
      _updateState(AgoraCallState.initializing);

      // Get token if provider is available and token is null
      String? token = config.token;
      if (token == null || token.isEmpty) {
        if (tokenProvider != null) {
          dev.log('Fetching token from provider', name: 'AgoraVideoCallController');
          token = await tokenProvider!.getToken(
            channelName: config.channelName,
            uid: config.uid,
          );
        }
      }

      // Update config with token if fetched
      final updatedConfig = token != null ? config.copyWith(token: token) : config;

      // Initialize engine
      await _engineManager.initialize();

      _updateState(AgoraCallState.joining);

      // Join channel
      await _engineManager.joinChannel();

      // Set initial audio/video state
      if (_isAudioMuted) {
        await _engineManager.muteLocalAudio(true);
      }
      if (!_isVideoEnabled) {
        await _engineManager.enableLocalVideo(false);
      }
    } catch (e) {
      dev.log('Error starting call', name: 'AgoraVideoCallController', error: e);
      _setError('Failed to start call: $e');
    }
  }

  /// Leave the call and clean up
  Future<void> endCall() async {
    try {
      _updateState(AgoraCallState.leaving);
      await _engineManager.leaveChannel();
      _remoteUsers.clear();
      _updateState(AgoraCallState.left);
    } catch (e) {
      dev.log('Error ending call', name: 'AgoraVideoCallController', error: e);
      _setError('Failed to end call: $e');
    }
  }

  /// Toggle audio mute state
  Future<void> toggleMuteAudio() async {
    try {
      final newMuteState = !_isAudioMuted;
      await _engineManager.muteLocalAudio(newMuteState);
      _isAudioMuted = newMuteState;
      notifyListeners();
    } catch (e) {
      dev.log('Error toggling audio', name: 'AgoraVideoCallController', error: e);
    }
  }

  /// Toggle video enabled state
  Future<void> toggleVideo() async {
    try {
      final newVideoState = !_isVideoEnabled;
      await _engineManager.enableLocalVideo(newVideoState);
      _isVideoEnabled = newVideoState;
      notifyListeners();
    } catch (e) {
      dev.log('Error toggling video', name: 'AgoraVideoCallController', error: e);
    }
  }

  /// Switch between front and rear camera
  Future<void> switchCamera() async {
    try {
      await _engineManager.switchCamera();
    } catch (e) {
      dev.log('Error switching camera', name: 'AgoraVideoCallController', error: e);
    }
  }

  /// Toggle speaker on/off
  Future<void> toggleSpeaker() async {
    try {
      final newSpeakerState = !_isSpeakerEnabled;
      await _engineManager.setEnableSpeakerphone(newSpeakerState);
      _isSpeakerEnabled = newSpeakerState;
      notifyListeners();
    } catch (e) {
      dev.log('Error toggling speaker', name: 'AgoraVideoCallController', error: e);
    }
  }

  // Event handlers
  void _handleJoinSuccess() {
    dev.log('Join success', name: 'AgoraVideoCallController');
    _updateState(AgoraCallState.joined);
  }

  void _handleUserJoined(int uid) {
    dev.log('User $uid joined', name: 'AgoraVideoCallController');
    _remoteUsers[uid] = RemoteUser(
      uid: uid,
      hasVideo: true,
      hasAudio: true,
      joinedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void _handleUserOffline(int uid, UserOfflineReasonType reason) {
    dev.log('User $uid left: $reason', name: 'AgoraVideoCallController');
    _remoteUsers.remove(uid);
    notifyListeners();
  }

  void _handleError(ErrorCodeType err, String msg) {
    dev.log('Error: $err - $msg', name: 'AgoraVideoCallController');
    _setError('Call error: $msg (${err.name})');
  }

  void _handleConnectionStateChanged(
    ConnectionStateType state,
    ConnectionChangedReasonType reason,
  ) {
    dev.log(
      'Connection state: $state, reason: $reason',
      name: 'AgoraVideoCallController',
    );

    if (state == ConnectionStateType.connectionStateConnecting ||
        state == ConnectionStateType.connectionStateReconnecting) {
      _updateState(AgoraCallState.reconnecting);
    } else if (state == ConnectionStateType.connectionStateConnected) {
      _updateState(AgoraCallState.joined);
    } else if (state == ConnectionStateType.connectionStateFailed) {
      _setError('Connection failed: ${reason.name}');
    } else if (state == ConnectionStateType.connectionStateDisconnected) {
      if (_callState != AgoraCallState.leaving &&
          _callState != AgoraCallState.left) {
        _updateState(AgoraCallState.left);
      }
    }
  }

  void _handleRemoteAudioStateChanged(int uid, bool muted) {
    dev.log('User $uid audio ${muted ? "muted" : "unmuted"}', name: 'AgoraVideoCallController');
    final user = _remoteUsers[uid];
    if (user != null) {
      _remoteUsers[uid] = user.copyWith(hasAudio: !muted);
      notifyListeners();
    }
  }

  void _handleRemoteVideoStateChanged(
    int uid,
    RemoteVideoState state,
    RemoteVideoStateReason reason,
  ) {
    dev.log('User $uid video state: $state', name: 'AgoraVideoCallController');
    final user = _remoteUsers[uid];
    if (user != null) {
      final hasVideo = state == RemoteVideoState.remoteVideoStateDecoding ||
          state == RemoteVideoState.remoteVideoStateStarting;
      _remoteUsers[uid] = user.copyWith(hasVideo: hasVideo);
      notifyListeners();
    }
  }

  void _updateState(AgoraCallState newState) {
    if (_callState != newState) {
      _callState = newState;
      _errorMessage = null; // Clear error when state changes
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _updateState(AgoraCallState.error);
  }

  @override
  void dispose() {
    _engineManager.dispose();
    super.dispose();
  }
}
