/// A reusable Flutter package for integrating Agora Video Calling SDK
///
/// This package provides a clean, configurable API for adding video calling
/// functionality to any Flutter app with minimal integration effort.
///
/// ## Features
///
/// - Ready-to-use video call UI
/// - 1:1 and small-group video calls
/// - Audio/video controls (mute, camera toggle, switch camera)
/// - Connection state management
/// - Error handling
/// - Customizable UI
/// - Token provider interface for secure authentication
///
/// ## Quick Start
///
/// ```dart
/// import 'package:agora_video_call_kit/agora_video_call_kit.dart';
///
/// final config = AgoraCallConfig(
///   appId: 'YOUR_APP_ID',
///   channelName: 'test_channel',
///   token: 'YOUR_TOKEN',
///   uid: 12345,
/// );
///
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => AgoraVideoCallScreen(
///       config: config,
///       onCallEnded: () {
///         print('Call ended');
///       },
///     ),
///   ),
/// );
/// ```
library agora_flutter;

// Models
export 'src/models/agora_call_config.dart';
export 'src/models/agora_call_state.dart';
export 'src/models/remote_user.dart';

// Providers
export 'src/providers/agora_token_provider.dart';

// Controllers
export 'src/controllers/agora_video_call_controller.dart';

// Widgets
export 'src/widgets/agora_video_call_screen.dart';
export 'src/widgets/call_control_button.dart';
export 'src/widgets/video_view.dart';

// Re-export commonly used Agora types for convenience
export 'package:agora_rtc_engine/agora_rtc_engine.dart'
    show
        ClientRoleType,
        ChannelProfileType,
        VideoEncoderConfiguration,
        VideoDimensions,
        RtcEngine;
