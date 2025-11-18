# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-XX

### Added
- Initial release of Agora Video Call Kit
- `AgoraCallConfig` model for call configuration
- `AgoraVideoCallController` for state management
- `AgoraEngineManager` for low-level Agora SDK operations
- `AgoraVideoCallScreen` widget with complete call UI
- `AgoraTokenProvider` interface for dynamic token fetching
- Support for 1:1 and small-group video calls
- Audio/video controls (mute, camera toggle, switch camera)
- Connection state management and error handling
- Automatic permission handling for Android and iOS
- Customizable UI through `controlsBuilder` parameter
- Remote user grid layout for multiple participants
- Call state indicators (connecting, reconnecting, error)
- Debug information overlay (optional)
- Comprehensive documentation and examples
- Unit tests for core models and providers
- Example Flutter app demonstrating integration

### Features
- **Ready-to-use UI**: Drop-in widget for instant video calling
- **Clean API**: Simple, intuitive configuration
- **Null Safety**: Sound null safety throughout
- **Error Handling**: Graceful error recovery and user feedback
- **Customizable**: Override default UI components
- **Production-Ready**: Token authentication support
- **Cross-Platform**: Android and iOS support

### Supported Platforms
- Android (SDK 21+)
- iOS (12.0+)

### Dependencies
- agora_rtc_engine: ^6.3.2
- permission_handler: ^11.3.0
- Flutter: >=3.0.0

---

## Future Releases

### Planned Features
- Screen sharing support
- Recording functionality
- Picture-in-Picture mode
- Chat integration during calls
- Virtual backgrounds
- Beauty filters
- Web platform support
- Desktop platform support (Windows, macOS, Linux)
- Background call mode
- Call quality indicators
- Network quality monitoring
- Custom video filters
- Noise cancellation options

---

For more information, see [README.md](README.md)
