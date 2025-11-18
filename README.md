# Agora Video Call Integrator

A comprehensive Flutter monorepo containing a reusable Agora Video Calling package and example implementation.

## 📦 Project Structure

```
agora_vc_integrator/
├── packages/
│   └── agora_video_call_kit/    # Reusable Agora video calling package
│       ├── lib/
│       │   ├── src/
│       │   │   ├── models/       # Configuration and data models
│       │   │   ├── controllers/  # Business logic and state management
│       │   │   ├── widgets/      # UI components
│       │   │   └── providers/    # Token provider interfaces
│       │   └── agora_video_call_kit.dart
│       ├── test/                 # Unit tests
│       ├── pubspec.yaml
│       └── README.md            # Detailed package documentation
│
└── example_app/                 # Example Flutter app
    ├── lib/
    │   ├── main.dart           # Demo app implementation
    │   └── agora_config.dart   # Configuration file
    ├── android/
    ├── ios/
    └── pubspec.yaml
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/rocksolid911/agora_vc_integrator.git
cd agora_vc_integrator
```

### 2. Set Up the Package

```bash
cd packages/agora_video_call_kit
flutter pub get
```

### 3. Run the Example App

```bash
cd ../../example_app
```

Update `lib/agora_config.dart` with your Agora credentials:

```dart
class AgoraConfig {
  static const String appId = 'YOUR_APP_ID_HERE';
  static const String? token = null; // Or your token
}
```

Then run:

```bash
flutter run
```

## 📱 Package: agora_video_call_kit

A production-ready Flutter package for integrating Agora Video Calling with minimal code.

### Features

- ✅ Drop-in video call UI widget
- ✅ 1:1 and small-group video calls
- ✅ Full audio/video controls (mute, camera, speaker)
- ✅ Automatic permission handling
- ✅ Connection state management
- ✅ Error handling and recovery
- ✅ Customizable UI
- ✅ Token provider interface for secure auth
- ✅ Null-safe and type-safe

### Installation

Add to your Flutter app's `pubspec.yaml`:

#### Option 1: Local Path (Monorepo)

```yaml
dependencies:
  agora_video_call_kit:
    path: ../packages/agora_video_call_kit
```

#### Option 2: Git Dependency

```yaml
dependencies:
  agora_video_call_kit:
    git:
      url: https://github.com/rocksolid911/agora_vc_integrator.git
      path: packages/agora_video_call_kit
```

### Basic Usage

```dart
import 'package:agora_video_call_kit/agora_video_call_kit.dart';

// Configure the call
final config = AgoraCallConfig(
  appId: 'YOUR_APP_ID',
  channelName: 'test_channel',
  token: 'YOUR_TOKEN', // null for testing
  uid: 0,
  userName: 'John Doe',
);

// Start the call
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
```

### Documentation

For detailed documentation, see:
- [Package README](packages/agora_video_call_kit/README.md)
- [API Reference](packages/agora_video_call_kit/lib/)
- [Example App](example_app/)

## 🎯 Use Cases

This package is perfect for:

- 📞 **Telemedicine Apps** - Doctor-patient video consultations
- 👥 **Social Apps** - Video chat features
- 🎓 **Education Platforms** - Online tutoring and classes
- 💼 **Business Apps** - Remote meetings and collaboration
- 🎮 **Gaming** - In-game voice/video chat
- 🛒 **E-commerce** - Live shopping assistance

## 🛠️ Development

### Requirements

- Flutter SDK: >=3.0.0
- Dart SDK: >=3.0.0 <4.0.0
- Android: minSdkVersion 21
- iOS: 12.0+

### Getting Agora Credentials

1. Sign up at [Agora Console](https://console.agora.io/)
2. Create a new project
3. Get your **App ID** from project settings
4. (Optional) Enable token authentication for production

### Running Tests

```bash
cd packages/agora_video_call_kit
flutter test
```

### Building the Example App

**Android:**
```bash
cd example_app
flutter build apk
```

**iOS:**
```bash
cd example_app
flutter build ios
```

## 📖 Key Concepts

### Architecture

The package follows clean architecture principles:

- **Models** - Data structures and configuration
- **Controllers** - Business logic and state management
- **Widgets** - Reusable UI components
- **Providers** - Interfaces for external dependencies (token provider)

### Components

1. **AgoraCallConfig** - Configuration model for calls
2. **AgoraVideoCallController** - State management and operations
3. **AgoraEngineManager** - Low-level Agora SDK wrapper
4. **AgoraVideoCallScreen** - Ready-to-use call UI
5. **AgoraTokenProvider** - Interface for token fetching

### State Management

The package uses `ChangeNotifier` for simple, efficient state management. The controller notifies listeners when:
- Call state changes (joining, joined, reconnecting, etc.)
- Users join or leave
- Audio/video settings change
- Errors occur

## 🔐 Security

### Token Authentication

For production apps, **always use token authentication**:

1. Set up a token server using Agora's SDKs
2. Implement `AgoraTokenProvider` interface
3. Pass it to `AgoraVideoCallScreen`

Example:

```dart
class MyTokenProvider implements AgoraTokenProvider {
  @override
  Future<String> getToken({
    required String channelName,
    required int uid,
  }) async {
    final response = await http.post(
      Uri.parse('https://your-server.com/agora/token'),
      body: {'channelName': channelName, 'uid': uid.toString()},
    );
    return jsonDecode(response.body)['token'];
  }
}
```

Learn more: [Agora Token Guide](https://docs.agora.io/en/video-calling/get-started/authentication-workflow)

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow [Flutter style guide](https://dart.dev/guides/language/effective-dart/style)
- Add tests for new features
- Update documentation
- Ensure null safety compliance

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Agora](https://www.agora.io/) for the excellent RTC SDK
- Flutter team for the amazing framework
- All contributors and users of this package

## 📞 Support

- 📚 [Package Documentation](packages/agora_video_call_kit/README.md)
- 🐛 [Report Issues](https://github.com/rocksolid911/agora_vc_integrator/issues)
- 💬 [Agora Community](https://www.agora.io/en/community/)
- 📖 [Agora Documentation](https://docs.agora.io/en/)

## 🗺️ Roadmap

Future enhancements:
- [ ] Screen sharing support
- [ ] Recording functionality
- [ ] Chat integration
- [ ] Virtual backgrounds
- [ ] Beauty filters
- [ ] Web platform support
- [ ] Desktop platform support
- [ ] Picture-in-Picture mode

---

**Made with ❤️ by [rocksolid911](https://github.com/rocksolid911)**

⭐ Star this repo if you find it useful!
