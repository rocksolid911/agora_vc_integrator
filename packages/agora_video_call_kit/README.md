# Agora Video Call Kit

A reusable Flutter package for integrating Agora Video Calling SDK with a clean, customizable API. Perfect for adding 1:1 or small-group video calling to any Flutter application with minimal setup.

## Features

✅ **Ready-to-use Video Call UI** - Drop-in widget with professional call interface
✅ **1:1 and Small Group Calls** - Support for multiple participants
✅ **Full Audio/Video Controls** - Mute, camera toggle, switch camera, speaker control
✅ **Connection Management** - Automatic reconnection and state handling
✅ **Error Handling** - Graceful error recovery and user feedback
✅ **Customizable UI** - Override default controls and layouts
✅ **Token Provider Interface** - Secure authentication with your backend
✅ **Null-Safe** - Built with sound null safety
✅ **Cross-Platform** - Android and iOS support

## Installation

Add this package to your Flutter project:

### Option 1: Local Path Dependency (Monorepo)

In your app's `pubspec.yaml`:

```yaml
dependencies:
  agora_video_call_kit:
    path: ../packages/agora_video_call_kit
```

### Option 2: Git Dependency

```yaml
dependencies:
  agora_video_call_kit:
    git:
      url: https://github.com/rocksolid911/agora_vc_integrator.git
      path: packages/agora_video_call_kit
```

Then run:

```bash
flutter pub get
```

## Prerequisites

### 1. Create an Agora Account

1. Sign up at [Agora Console](https://console.agora.io/)
2. Create a new project
3. Get your **App ID** from the project settings
4. For production, set up token authentication (recommended)

### 2. Configure Permissions

#### Android

The package handles most Android configuration automatically. Ensure your `android/app/build.gradle` has:

```gradle
android {
    compileSdkVersion 33

    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

Required permissions (already included in the package):
- `INTERNET`
- `CAMERA`
- `RECORD_AUDIO`
- `MODIFY_AUDIO_SETTINGS`
- `ACCESS_NETWORK_STATE`
- `BLUETOOTH` (optional, for Bluetooth headsets)
- `BLUETOOTH_CONNECT` (Android 12+)

#### iOS

Update your `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for audio calls</string>
<key>NSLocalNetworkUsageDescription</key>
<string>This app needs local network access for peer connections</string>
```

Set minimum deployment target to iOS 12.0 in `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

## Quick Start

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:agora_video_call_kit/agora_video_call_kit.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CallPage(),
    );
  }
}

class CallPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _startCall(context),
          child: Text('Start Video Call'),
        ),
      ),
    );
  }

  void _startCall(BuildContext context) {
    final config = AgoraCallConfig(
      appId: 'YOUR_APP_ID',
      channelName: 'test_channel',
      token: null, // For testing only - use real tokens in production!
      uid: 0, // 0 = auto-assign
      userName: 'John Doe',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgoraVideoCallScreen(
          config: config,
          onCallEnded: () {
            print('Call ended');
          },
        ),
      ),
    );
  }
}
```

## Configuration Options

### AgoraCallConfig

The main configuration class for setting up video calls:

```dart
final config = AgoraCallConfig(
  appId: 'YOUR_APP_ID',           // Required: Your Agora App ID
  channelName: 'my_channel',      // Required: Channel name (same for all participants)
  token: 'YOUR_TOKEN',            // Optional: Authentication token (null for testing)
  uid: 12345,                     // Optional: User ID (0 = auto-assign)
  role: ClientRoleType.clientRoleBroadcaster, // Optional: Host or audience
  enableAudio: true,              // Optional: Enable audio on join (default: true)
  enableVideo: true,              // Optional: Enable video on join (default: true)
  userName: 'John Doe',           // Optional: Display name
  channelProfile: ChannelProfileType.channelProfileCommunication, // Optional
  videoEncoderConfig: VideoEncoderConfiguration( // Optional: Custom video settings
    dimensions: VideoDimensions(width: 640, height: 480),
    frameRate: 15,
  ),
);
```

### Convenience Constructors

**Host (Broadcaster):**
```dart
final config = AgoraCallConfig.host(
  appId: 'YOUR_APP_ID',
  channelName: 'my_channel',
  token: 'YOUR_TOKEN',
  uid: 0,
  userName: 'John',
);
```

**Audience (View-Only):**
```dart
final config = AgoraCallConfig.audience(
  appId: 'YOUR_APP_ID',
  channelName: 'my_channel',
  token: 'YOUR_TOKEN',
  uid: 0,
  userName: 'Jane',
);
```

## Advanced Usage

### Custom Token Provider

For production apps, implement the `AgoraTokenProvider` interface to fetch tokens from your backend:

```dart
class MyTokenProvider implements AgoraTokenProvider {
  final ApiClient apiClient;

  MyTokenProvider(this.apiClient);

  @override
  Future<String> getToken({
    required String channelName,
    required int uid,
  }) async {
    final response = await apiClient.post('/agora/token', {
      'channelName': channelName,
      'uid': uid,
    });
    return response['token'];
  }
}

// Use it in your call:
AgoraVideoCallScreen(
  config: config,
  tokenProvider: MyTokenProvider(apiClient),
  onCallEnded: () => print('Call ended'),
)
```

### Custom UI Controls

Override the default control buttons:

```dart
AgoraVideoCallScreen(
  config: config,
  controlsBuilder: (context, controller) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Custom mute button
          IconButton(
            icon: Icon(
              controller.isAudioMuted ? Icons.mic_off : Icons.mic,
              color: Colors.white,
            ),
            onPressed: controller.toggleMuteAudio,
          ),
          // Custom end call button
          IconButton(
            icon: Icon(Icons.call_end, color: Colors.red),
            onPressed: controller.endCall,
          ),
        ],
      ),
    );
  },
)
```

### Using the Controller Directly

For more control, use `AgoraVideoCallController` directly:

```dart
class MyCallPage extends StatefulWidget {
  @override
  _MyCallPageState createState() => _MyCallPageState();
}

class _MyCallPageState extends State<MyCallPage> {
  late AgoraVideoCallController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AgoraVideoCallController(
      config: AgoraCallConfig(
        appId: 'YOUR_APP_ID',
        channelName: 'test',
      ),
    );
    _controller.startCall();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Column(
            children: [
              Text('State: ${_controller.callState}'),
              Text('Remote users: ${_controller.remoteUsers.length}'),
              ElevatedButton(
                onPressed: _controller.toggleMuteAudio,
                child: Text(_controller.isAudioMuted ? 'Unmute' : 'Mute'),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

## Authentication & Security

### Token-Based Authentication

For production apps, **always use token authentication**:

1. **Set up a token server** - Use Agora's token generation code on your backend
2. **Implement AgoraTokenProvider** - Fetch tokens from your server
3. **Pass provider to widget** - Use `tokenProvider` parameter

Example token server endpoint (Node.js):

```javascript
const { RtcTokenBuilder, RtcRole } = require('agora-access-token');

app.post('/agora/token', (req, res) => {
  const { channelName, uid } = req.body;
  const appId = 'YOUR_APP_ID';
  const appCertificate = 'YOUR_APP_CERTIFICATE';
  const expirationTimeInSeconds = 3600;

  const token = RtcTokenBuilder.buildTokenWithUid(
    appId,
    appCertificate,
    channelName,
    uid,
    RtcRole.PUBLISHER,
    expirationTimeInSeconds
  );

  res.json({ token });
});
```

Learn more: [Agora Token Authentication](https://docs.agora.io/en/video-calling/get-started/authentication-workflow)

## API Reference

### Classes

#### AgoraCallConfig
Configuration model for video calls.

#### AgoraVideoCallController
Controller for managing call state and operations.

**Methods:**
- `startCall()` - Initialize and join the call
- `endCall()` - Leave the call and clean up
- `toggleMuteAudio()` - Mute/unmute microphone
- `toggleVideo()` - Enable/disable camera
- `switchCamera()` - Switch between front/rear camera
- `toggleSpeaker()` - Toggle speaker on/off

**Properties:**
- `callState` - Current call state (idle, joining, joined, etc.)
- `remoteUsers` - Map of remote users in the call
- `isAudioMuted` - Local audio mute state
- `isVideoEnabled` - Local video enabled state
- `localUid` - Local user ID (assigned after joining)
- `errorMessage` - Error message if state is error

#### AgoraVideoCallScreen
Full-featured video call screen widget.

#### AgoraTokenProvider
Interface for providing authentication tokens.

### Widgets

#### CallControlButton
Reusable circular button for call controls.

#### LocalVideoView
Widget for displaying local video feed.

#### RemoteVideoView
Widget for displaying remote user video.

#### RemoteUsersGrid
Grid layout for multiple remote users.

## Troubleshooting

### Common Issues

**1. Black screen / No video**
- Ensure camera permissions are granted
- Check that `enableVideo: true` in config
- Verify video encoder configuration

**2. No audio**
- Check microphone permissions
- Verify `enableAudio: true` in config
- Test with different audio routes (speaker/earpiece)

**3. "Invalid App ID" error**
- Double-check your App ID from Agora Console
- Ensure no extra spaces or quotes in the string

**4. Connection failures**
- Verify internet connection
- Check if firewall is blocking Agora ports
- Ensure token is valid (if using authentication)

**5. Build errors on iOS**
- Update CocoaPods: `cd ios && pod install`
- Set minimum iOS version to 12.0
- Clean build folder: `flutter clean && flutter pub get`

### Enable Debug Logging

```dart
AgoraVideoCallScreen(
  config: config,
  showDebugInfo: true, // Shows state, UID, and user count
)
```

## Examples

See the `/example_app` directory for a complete working example.

## Platform Support

| Platform | Minimum Version |
|----------|----------------|
| Android  | SDK 21 (Android 5.0) |
| iOS      | 12.0 |
| Web      | Not supported yet |
| Desktop  | Not supported yet |

## Dependencies

- [agora_rtc_engine](https://pub.dev/packages/agora_rtc_engine) - Official Agora Flutter SDK
- [permission_handler](https://pub.dev/packages/permission_handler) - Runtime permission management

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This package is available under the MIT License. See LICENSE file for details.

## Resources

- [Agora Documentation](https://docs.agora.io/en/video-calling)
- [Agora Console](https://console.agora.io/)
- [Flutter Documentation](https://flutter.dev/docs)
- [Package Issues](https://github.com/rocksolid911/agora_vc_integrator/issues)

## Support

For questions or issues:
1. Check the [troubleshooting section](#troubleshooting)
2. Review [Agora documentation](https://docs.agora.io)
3. Open an issue on GitHub

---

Made with ❤️ for the Flutter community
