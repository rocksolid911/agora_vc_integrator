# Agora Video Call Kit - Integration Guide

This guide will walk you through integrating the `agora_video_call_kit` package into your existing Flutter application.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Setup](#setup)
4. [Basic Integration](#basic-integration)
5. [Advanced Configuration](#advanced-configuration)
6. [Production Deployment](#production-deployment)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### 1. Agora Account Setup

Before starting, you need:

1. **Agora Account**: Sign up at [https://console.agora.io](https://console.agora.io)
2. **Create a Project**: In the Agora Console, create a new project
3. **Get App ID**: Copy your App ID from the project settings
4. **Enable Token Authentication** (for production):
   - Go to Project Management → Settings
   - Enable "App Certificate"
   - Copy your App Certificate

### 2. System Requirements

- **Flutter**: >=3.0.0
- **Dart**: >=3.0.0
- **Android**: minSdkVersion 21 (Android 5.0) or higher
- **iOS**: iOS 12.0 or higher
- **Xcode**: 13.0+ (for iOS development)
- **Android Studio**: Latest version with Android SDK

## Installation

### Step 1: Add Dependency

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  # Your existing dependencies
  flutter:
    sdk: flutter

  # Add this line (adjust path for your setup)
  agora_video_call_kit:
    path: ../packages/agora_video_call_kit
    # OR use git dependency:
    # git:
    #   url: https://github.com/rocksolid911/agora_vc_integrator.git
    #   path: packages/agora_video_call_kit
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

## Setup

### Android Configuration

#### 1. Update `android/app/build.gradle`

Ensure minimum SDK version:

```gradle
android {
    compileSdkVersion 33

    defaultConfig {
        minSdkVersion 21  // Minimum for Agora
        targetSdkVersion 33
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

#### 2. Permissions in `android/app/src/main/AndroidManifest.xml`

The package already includes necessary permissions, but verify they exist:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.BLUETOOTH"/>
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>

    <application>
        <!-- Your app config -->
    </application>
</manifest>
```

#### 3. ProGuard Rules (if using code shrinking)

Add to `android/app/proguard-rules.pro`:

```proguard
-keep class io.agora.**{*;}
```

### iOS Configuration

#### 1. Update `ios/Podfile`

Set minimum iOS version:

```ruby
platform :ios, '12.0'
```

#### 2. Add Permissions to `ios/Runner/Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for audio calls</string>
<key>NSLocalNetworkUsageDescription</key>
<string>This app needs local network access for peer connections</string>
```

#### 3. Update iOS Pods

```bash
cd ios
pod install
cd ..
```

## Basic Integration

### Step 1: Import the Package

```dart
import 'package:agora_video_call_kit/agora_video_call_kit.dart';
```

### Step 2: Create Configuration

Create a configuration file (e.g., `lib/config/agora_config.dart`):

```dart
class AgoraConfig {
  static const String appId = 'YOUR_APP_ID_HERE';

  // For testing without security (NOT for production!)
  static const String? testToken = null;

  // For production, implement token fetching
  static Future<String> getToken({
    required String channelName,
    required int uid,
  }) async {
    // Call your backend token server
    final response = await http.post(
      Uri.parse('https://your-server.com/agora/token'),
      body: {
        'channelName': channelName,
        'uid': uid.toString(),
      },
    );
    return jsonDecode(response.body)['token'];
  }
}
```

### Step 3: Start a Video Call

```dart
import 'package:flutter/material.dart';
import 'package:agora_video_call_kit/agora_video_call_kit.dart';
import 'config/agora_config.dart';

class MyVideoCallPage extends StatelessWidget {
  final String channelName;
  final String userName;

  const MyVideoCallPage({
    Key? key,
    required this.channelName,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _startVideoCall(context),
          child: const Text('Start Video Call'),
        ),
      ),
    );
  }

  void _startVideoCall(BuildContext context) {
    // Create call configuration
    final config = AgoraCallConfig(
      appId: AgoraConfig.appId,
      channelName: channelName,
      token: AgoraConfig.testToken, // Use null for testing
      uid: 0, // 0 = auto-assign user ID
      userName: userName,
      enableAudio: true,
      enableVideo: true,
    );

    // Navigate to video call screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgoraVideoCallScreen(
          config: config,
          onCallEnded: () {
            // Handle call ended
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Call ended')),
            );
          },
        ),
      ),
    );
  }
}
```

## Advanced Configuration

### Custom Token Provider

For production apps, implement secure token fetching:

```dart
class MyTokenProvider implements AgoraTokenProvider {
  final ApiService apiService;

  MyTokenProvider(this.apiService);

  @override
  Future<String> getToken({
    required String channelName,
    required int uid,
  }) async {
    try {
      final response = await apiService.fetchAgoraToken(
        channelName: channelName,
        uid: uid,
      );
      return response.token;
    } catch (e) {
      throw Exception('Failed to fetch Agora token: $e');
    }
  }
}

// Usage
AgoraVideoCallScreen(
  config: config,
  tokenProvider: MyTokenProvider(apiService),
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
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Custom mute button
          FloatingActionButton(
            onPressed: controller.toggleMuteAudio,
            backgroundColor: controller.isAudioMuted
                ? Colors.red
                : Colors.blue,
            child: Icon(
              controller.isAudioMuted ? Icons.mic_off : Icons.mic,
            ),
          ),

          // Custom end call button
          FloatingActionButton(
            onPressed: controller.endCall,
            backgroundColor: Colors.red,
            child: const Icon(Icons.call_end),
          ),

          // Custom video toggle
          FloatingActionButton(
            onPressed: controller.toggleVideo,
            backgroundColor: controller.isVideoEnabled
                ? Colors.blue
                : Colors.grey,
            child: Icon(
              controller.isVideoEnabled
                  ? Icons.videocam
                  : Icons.videocam_off,
            ),
          ),
        ],
      ),
    );
  },
)
```

### Using the Controller Directly

For complete control, use `AgoraVideoCallController`:

```dart
class CustomCallPage extends StatefulWidget {
  final AgoraCallConfig config;

  const CustomCallPage({Key? key, required this.config}) : super(key: key);

  @override
  State<CustomCallPage> createState() => _CustomCallPageState();
}

class _CustomCallPageState extends State<CustomCallPage> {
  late AgoraVideoCallController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AgoraVideoCallController(config: widget.config);
    _controller.addListener(_onControllerUpdate);
    _controller.startCall();
  }

  void _onControllerUpdate() {
    setState(() {});

    // Handle state changes
    if (_controller.callState == AgoraCallState.error) {
      _showError(_controller.errorMessage);
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
      body: Stack(
        children: [
          // Your custom UI using controller state
          if (_controller.engine != null)
            RemoteUsersGrid(
              engine: _controller.engine!,
              users: _controller.remoteUsersList,
            ),

          // Status indicator
          Positioned(
            top: 40,
            left: 20,
            child: Text(
              'State: ${_controller.callState.description}',
              style: const TextStyle(color: Colors.white),
            ),
          ),

          // Custom controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _controller.isAudioMuted ? Icons.mic_off : Icons.mic,
                  ),
                  onPressed: _controller.toggleMuteAudio,
                  color: Colors.white,
                ),
                IconButton(
                  icon: const Icon(Icons.call_end),
                  onPressed: _controller.endCall,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'An error occurred')),
    );
  }
}
```

## Production Deployment

### Token Server Setup

For production, you **must** implement token authentication:

#### 1. Backend Token Server (Node.js Example)

```javascript
const express = require('express');
const { RtcTokenBuilder, RtcRole } = require('agora-access-token');

const app = express();
const PORT = 3000;

const APP_ID = 'YOUR_APP_ID';
const APP_CERTIFICATE = 'YOUR_APP_CERTIFICATE';

app.post('/agora/token', (req, res) => {
  const { channelName, uid } = req.body;

  if (!channelName || !uid) {
    return res.status(400).json({ error: 'Missing parameters' });
  }

  const role = RtcRole.PUBLISHER;
  const expirationTimeInSeconds = 3600; // 1 hour
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

  const token = RtcTokenBuilder.buildTokenWithUid(
    APP_ID,
    APP_CERTIFICATE,
    channelName,
    parseInt(uid),
    role,
    privilegeExpiredTs
  );

  res.json({ token, expirationTime: privilegeExpiredTs });
});

app.listen(PORT, () => {
  console.log(`Token server running on port ${PORT}`);
});
```

#### 2. Flutter Token Provider Implementation

```dart
class ProductionTokenProvider implements AgoraTokenProvider {
  final String serverUrl;
  final http.Client httpClient;

  ProductionTokenProvider({
    required this.serverUrl,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  @override
  Future<String> getToken({
    required String channelName,
    required int uid,
  }) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$serverUrl/agora/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'channelName': channelName,
          'uid': uid,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        throw Exception('Failed to fetch token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Token fetch error: $e');
    }
  }
}
```

### Security Best Practices

1. **Never hardcode tokens or App Certificate in your app**
2. **Always use HTTPS** for token server communication
3. **Implement authentication** before issuing tokens
4. **Set reasonable token expiration times** (e.g., 1-24 hours)
5. **Implement token refresh logic** for long calls
6. **Validate channel names** on your backend
7. **Rate limit** token generation endpoints
8. **Log token generation** for auditing

### Release Checklist

- [ ] Token authentication implemented
- [ ] Token server deployed and secured
- [ ] HTTPS enabled on token server
- [ ] App ID and credentials stored securely
- [ ] Permissions properly configured
- [ ] Tested on both Android and iOS
- [ ] Error handling implemented
- [ ] Analytics/logging added
- [ ] Performance testing completed
- [ ] Privacy policy updated

## Troubleshooting

### Common Issues

#### 1. "Invalid App ID" Error

**Solution**:
- Verify App ID is correct (no spaces, correct format)
- Check that you're using the right project in Agora Console
- Ensure App ID is not hardcoded with quotes around it

#### 2. Black Screen / No Video

**Solutions**:
- Check camera permissions are granted
- Verify `enableVideo: true` in config
- Test camera in device settings
- Check if another app is using the camera
- Try restarting the app

#### 3. No Audio

**Solutions**:
- Check microphone permissions
- Verify `enableAudio: true` in config
- Test on a different device
- Check Bluetooth headset connection
- Verify speaker/earpiece settings

#### 4. Connection Failures

**Solutions**:
- Check internet connectivity
- Verify firewall isn't blocking Agora servers
- Test token validity (if using authentication)
- Check Agora service status
- Try different network (WiFi vs mobile data)

#### 5. iOS Build Errors

**Solutions**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install
cd ..
flutter clean
flutter pub get
```

#### 6. Android Build Errors

**Solutions**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### Debug Mode

Enable debug logging:

```dart
AgoraVideoCallScreen(
  config: config,
  showDebugInfo: true, // Shows state, UID, user count
)
```

### Getting Help

If you're still experiencing issues:

1. Check [Agora Documentation](https://docs.agora.io)
2. Review [Package README](../packages/agora_video_call_kit/README.md)
3. Search [GitHub Issues](https://github.com/rocksolid911/agora_vc_integrator/issues)
4. Join [Agora Community](https://www.agora.io/en/community/)
5. Open a [new issue](https://github.com/rocksolid911/agora_vc_integrator/issues/new) with:
   - Flutter version (`flutter --version`)
   - Package version
   - Platform (Android/iOS)
   - Full error message
   - Steps to reproduce

---

**Happy coding! 🎉**
