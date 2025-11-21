import 'package:flutter/material.dart';
import 'package:agora_video_call_kit/agora_video_call_kit.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import 'agora_config.dart';

/// Example showing how to use advanced features:
/// - Mixpanel analytics integration
/// - Call recording
/// - Custom logging levels
/// - Metrics tracking
class AdvancedVideoCallExample extends StatefulWidget {
  const AdvancedVideoCallExample({Key? key}) : super(key: key);

  @override
  State<AdvancedVideoCallExample> createState() =>
      _AdvancedVideoCallExampleState();
}

class _AdvancedVideoCallExampleState extends State<AdvancedVideoCallExample> {
  final _channelController = TextEditingController(text: 'advanced_channel');
  final _userNameController = TextEditingController(text: 'User');

  Mixpanel? _mixpanel;
  bool _enableRecording = false;
  bool _enableMetrics = false;
  LogLevel _logLevel = LogLevel.info;

  @override
  void initState() {
    super.initState();
    _initializeMixpanel();
  }

  Future<void> _initializeMixpanel() async {
    // Initialize Mixpanel (replace with your Mixpanel token)
    // For demo purposes, this is optional
    try {
      // Uncomment and add your Mixpanel token
      // _mixpanel = await Mixpanel.init('YOUR_MIXPANEL_TOKEN',
      //     trackAutomaticEvents: true);
    } catch (e) {
      print('Mixpanel initialization failed: $e');
    }
  }

  @override
  void dispose() {
    _channelController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  void _startAdvancedCall() {
    final channelName = _channelController.text.trim();
    if (channelName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a channel name')),
      );
      return;
    }

    // Create analytics provider
    AnalyticsProvider? analyticsProvider;
    if (_enableMetrics) {
      if (_mixpanel != null) {
        // Use Mixpanel for analytics
        analyticsProvider = MixpanelAnalyticsProvider(_mixpanel!);
      } else {
        // Use console analytics for demo
        analyticsProvider = ConsoleAnalyticsProvider();
      }
    }

    // Create recording configuration (optional)
    RecordingConfig? recordingConfig;
    RecordingServiceProvider? recordingService;
    if (_enableRecording) {
      recordingConfig = RecordingConfig(
        enabled: true,
        mode: RecordingMode.composite,
        autoStart: true,
        maxDurationSeconds: 3600, // 1 hour max
        videoConfig: const RecordingVideoConfig(
          width: 1280,
          height: 720,
          fps: 15,
          bitrate: 2000,
        ),
      );

      // Create recording service provider
      // You need to implement your own backend for this
      recordingService = HttpRecordingServiceProvider(
        baseUrl: 'https://your-recording-server.com/api',
        headers: {
          'Authorization': 'Bearer YOUR_API_KEY',
        },
      );
    }

    // Create call configuration with monitoring features
    final config = AgoraCallConfig(
      appId: AgoraConfig.appId,
      channelName: channelName,
      token: AgoraConfig.token,
      uid: 0,
      userName: _userNameController.text.trim(),
      enableMetrics: _enableMetrics, // Enable metrics tracking
      logLevel: _logLevel, // Set log level
    );

    // Create controller with analytics and recording
    final controller = AgoraVideoCallController(
      config: config,
      analyticsProvider: analyticsProvider,
      recordingConfig: recordingConfig,
      recordingServiceProvider: recordingService,
    );

    // Navigate to custom call screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _AdvancedCallScreen(
          controller: controller,
          onCallEnded: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Call ended')),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Video Call Features'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _channelController,
              decoration: const InputDecoration(
                labelText: 'Channel Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Enable Metrics Tracking'),
              subtitle: const Text('Track call quality and analytics'),
              value: _enableMetrics,
              onChanged: (value) {
                setState(() {
                  _enableMetrics = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Enable Recording'),
              subtitle: const Text('Record the call (requires backend)'),
              value: _enableRecording,
              onChanged: (value) {
                setState(() {
                  _enableRecording = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Log Level:'),
            DropdownButton<LogLevel>(
              value: _logLevel,
              isExpanded: true,
              items: LogLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _logLevel = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startAdvancedCall,
              child: const Text('Start Advanced Call'),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Advanced Features Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Metrics: Tracks join time, latency, failures\n'
                      '• Recording: Requires backend server setup\n'
                      '• Logging: Control verbosity for debugging',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom call screen that shows metrics
class _AdvancedCallScreen extends StatefulWidget {
  final AgoraVideoCallController controller;
  final VoidCallback? onCallEnded;

  const _AdvancedCallScreen({
    required this.controller,
    this.onCallEnded,
  });

  @override
  State<_AdvancedCallScreen> createState() => _AdvancedCallScreenState();
}

class _AdvancedCallScreenState extends State<_AdvancedCallScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
    widget.controller.startCall();
  }

  void _onControllerUpdate() {
    if (widget.controller.callState == AgoraCallState.left) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onCallEnded?.call();
        }
      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video views
            if (widget.controller.engine != null)
              Positioned.fill(
                child: RemoteUsersGrid(
                  engine: widget.controller.engine!,
                  users: widget.controller.remoteUsersList,
                ),
              ),

            // Local video
            if (widget.controller.engine != null)
              Positioned(
                top: 16,
                right: 16,
                width: 120,
                height: 160,
                child: LocalVideoView(
                  engine: widget.controller.engine!,
                  isVideoEnabled: widget.controller.isVideoEnabled,
                ),
              ),

            // Metrics display
            if (widget.controller.metrics != null)
              Positioned(
                top: 16,
                left: 16,
                child: _buildMetricsDisplay(),
              ),

            // Recording indicator
            if (widget.controller.isRecording)
              const Positioned(
                top: 180,
                left: 16,
                child: _RecordingIndicator(),
              ),

            // Controls
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsDisplay() {
    final metrics = widget.controller.metrics!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Metrics',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (metrics.joinDurationMs != null)
            Text(
              'Join Time: ${metrics.joinDurationMs}ms',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          Text(
            'Users: ${metrics.usersJoined}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (metrics.reconnectionAttempts > 0)
            Text(
              'Reconnects: ${metrics.reconnectionAttempts}',
              style: const TextStyle(color: Colors.orange, fontSize: 12),
            ),
          if (metrics.errors.isNotEmpty)
            Text(
              'Errors: ${metrics.errors.length}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildControls() {
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
          CallControlButton(
            icon: widget.controller.isAudioMuted ? Icons.mic_off : Icons.mic,
            onPressed: widget.controller.toggleMuteAudio,
            isActive: !widget.controller.isAudioMuted,
          ),
          CallControlButton(
            icon: widget.controller.isVideoEnabled
                ? Icons.videocam
                : Icons.videocam_off,
            onPressed: widget.controller.toggleVideo,
            isActive: widget.controller.isVideoEnabled,
          ),
          EndCallButton(onPressed: widget.controller.endCall),
          CallControlButton(
            icon: Icons.cameraswitch,
            onPressed: widget.controller.switchCamera,
          ),
          if (widget.controller.isRecording)
            CallControlButton(
              icon: Icons.stop,
              onPressed: widget.controller.stopRecording,
              backgroundColor: Colors.red,
              iconColor: Colors.white,
              tooltip: 'Stop Recording',
            )
          else if (widget.controller.recordingConfig?.enabled == true)
            CallControlButton(
              icon: Icons.fiber_manual_record,
              onPressed: () async {
                await widget.controller.startRecording();
                setState(() {});
              },
              tooltip: 'Start Recording',
            ),
        ],
      ),
    );
  }
}

/// Recording indicator widget
class _RecordingIndicator extends StatefulWidget {
  const _RecordingIndicator();

  @override
  State<_RecordingIndicator> createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<_RecordingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(Tween(begin: 0.3, end: 1.0)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fiber_manual_record, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Recording',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
