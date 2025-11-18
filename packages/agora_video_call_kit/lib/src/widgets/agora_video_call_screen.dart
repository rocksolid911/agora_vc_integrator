import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controllers/agora_video_call_controller.dart';
import '../models/agora_call_config.dart';
import '../models/agora_call_state.dart';
import '../providers/agora_token_provider.dart';
import 'call_control_button.dart';
import 'video_view.dart';

/// Main screen for Agora video calls
///
/// This widget provides a complete video calling UI with:
/// - Local and remote video views
/// - Call controls (mute, video, speaker, switch camera, end call)
/// - Connection status and error handling
/// - Permission management
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => AgoraVideoCallScreen(
///       config: AgoraCallConfig(
///         appId: 'YOUR_APP_ID',
///         channelName: 'test_channel',
///         token: 'YOUR_TOKEN',
///         uid: 12345,
///       ),
///       onCallEnded: () {
///         print('Call ended');
///       },
///     ),
///   ),
/// );
/// ```
class AgoraVideoCallScreen extends StatefulWidget {
  /// Configuration for the call
  final AgoraCallConfig config;

  /// Optional token provider for dynamic token fetching
  final AgoraTokenProvider? tokenProvider;

  /// Callback when the call ends
  final VoidCallback? onCallEnded;

  /// Custom builder for call controls (optional)
  final Widget Function(BuildContext context, AgoraVideoCallController controller)?
      controlsBuilder;

  /// Whether to show debug information
  final bool showDebugInfo;

  /// Background color for the call screen
  final Color? backgroundColor;

  const AgoraVideoCallScreen({
    Key? key,
    required this.config,
    this.tokenProvider,
    this.onCallEnded,
    this.controlsBuilder,
    this.showDebugInfo = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<AgoraVideoCallScreen> createState() => _AgoraVideoCallScreenState();
}

class _AgoraVideoCallScreenState extends State<AgoraVideoCallScreen> {
  late final AgoraVideoCallController _controller;
  bool _permissionsGranted = false;
  String? _permissionError;

  @override
  void initState() {
    super.initState();
    _controller = AgoraVideoCallController(
      config: widget.config,
      tokenProvider: widget.tokenProvider,
    );
    _controller.addListener(_onControllerUpdate);
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    // Request permissions
    final granted = await _requestPermissions();
    if (!granted) {
      setState(() {
        _permissionError = 'Camera and microphone permissions are required';
      });
      return;
    }

    setState(() {
      _permissionsGranted = true;
    });

    // Start the call
    await _controller.startCall();
  }

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    return statuses[Permission.camera]?.isGranted == true &&
        statuses[Permission.microphone]?.isGranted == true;
  }

  void _onControllerUpdate() {
    if (_controller.callState == AgoraCallState.left) {
      // Call ended, pop the screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onCallEnded?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.black,
      body: SafeArea(
        child: _permissionError != null
            ? _buildPermissionError()
            : !_permissionsGranted
                ? _buildLoadingView()
                : _buildCallView(),
      ),
    );
  }

  Widget _buildPermissionError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              _permissionError!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Requesting permissions...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildCallView() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.callState;

        if (state.hasError) {
          return _buildErrorView();
        }

        if (state.isConnecting) {
          return _buildConnectingView();
        }

        if (!state.isActive) {
          return _buildConnectingView();
        }

        return _buildActiveCallView();
      },
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _controller.errorMessage ?? 'An error occurred',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await _controller.startCall();
              },
              child: const Text('Retry'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            _controller.callState.description,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCallView() {
    final engine = _controller.engine;
    if (engine == null) {
      return _buildConnectingView();
    }

    return Stack(
      children: [
        // Remote users (main area)
        Positioned.fill(
          child: RemoteUsersGrid(
            engine: engine,
            users: _controller.remoteUsersList,
          ),
        ),

        // Local video (small overlay)
        Positioned(
          top: 16,
          right: 16,
          width: 120,
          height: 160,
          child: LocalVideoView(
            engine: engine,
            isVideoEnabled: _controller.isVideoEnabled,
            userName: widget.config.userName ?? 'You',
          ),
        ),

        // Call controls (bottom)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: widget.controlsBuilder?.call(context, _controller) ??
              _buildDefaultControls(),
        ),

        // Debug info
        if (widget.showDebugInfo) _buildDebugInfo(),

        // Connection status indicator
        if (_controller.callState == AgoraCallState.reconnecting)
          Positioned(
            top: 16,
            left: 16,
            child: _buildReconnectingIndicator(),
          ),
      ],
    );
  }

  Widget _buildDefaultControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute/unmute audio
          CallControlButton(
            icon: _controller.isAudioMuted ? Icons.mic_off : Icons.mic,
            onPressed: _controller.toggleMuteAudio,
            isActive: !_controller.isAudioMuted,
            tooltip: _controller.isAudioMuted ? 'Unmute' : 'Mute',
          ),

          // Toggle video
          CallControlButton(
            icon: _controller.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
            onPressed: _controller.toggleVideo,
            isActive: _controller.isVideoEnabled,
            tooltip: _controller.isVideoEnabled ? 'Turn off camera' : 'Turn on camera',
          ),

          // End call
          EndCallButton(
            onPressed: _controller.endCall,
          ),

          // Switch camera
          CallControlButton(
            icon: Icons.cameraswitch,
            onPressed: _controller.switchCamera,
            tooltip: 'Switch camera',
          ),

          // Toggle speaker
          CallControlButton(
            icon: _controller.isSpeakerEnabled ? Icons.volume_up : Icons.volume_off,
            onPressed: _controller.toggleSpeaker,
            isActive: _controller.isSpeakerEnabled,
            tooltip: _controller.isSpeakerEnabled ? 'Turn off speaker' : 'Turn on speaker',
          ),
        ],
      ),
    );
  }

  Widget _buildReconnectingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Reconnecting...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugInfo() {
    return Positioned(
      bottom: 120,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'State: ${_controller.callState.name}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Local UID: ${_controller.localUid ?? "N/A"}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Remote users: ${_controller.remoteUsers.length}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Audio: ${_controller.isAudioMuted ? "Muted" : "Unmuted"}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Video: ${_controller.isVideoEnabled ? "On" : "Off"}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
