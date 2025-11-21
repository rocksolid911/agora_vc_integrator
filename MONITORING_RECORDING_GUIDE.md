# Monitoring, Analytics & Recording Guide

This guide covers the advanced features for monitoring, analytics, and recording in the Agora Video Call Kit.

## Table of Contents

1. [Analytics Integration](#analytics-integration)
2. [Call Metrics](#call-metrics)
3. [Logging](#logging)
4. [Call Recording](#call-recording)
5. [Examples](#examples)

## Analytics Integration

### Overview

The package provides a flexible analytics interface that works with any analytics service (Mixpanel, Firebase Analytics, Amplitude, etc.).

### AnalyticsProvider Interface

```dart
abstract class AnalyticsProvider {
  Future<void> trackEvent(String eventName, [Map<String, dynamic>? properties]);
  Future<void> setUserProperties(Map<String, dynamic> properties);
  Future<void> startTimedEvent(String eventName);
  Future<void> endTimedEvent(String eventName, [Map<String, dynamic>? properties]);
}
```

### Mixpanel Integration

```dart
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:agora_video_call_kit/agora_video_call_kit.dart';

// Initialize Mixpanel
final mixpanel = await Mixpanel.init('YOUR_MIXPANEL_TOKEN');

// Create analytics provider
final analytics = MixpanelAnalyticsProvider(mixpanel);

// Use in controller
final controller = AgoraVideoCallController(
  config: config,
  analyticsProvider: analytics,
);
```

### Custom Analytics Implementation

```dart
class MyAnalyticsProvider implements AnalyticsProvider {
  @override
  Future<void> trackEvent(String eventName, [Map<String, dynamic>? properties]) async {
    // Your implementation
    await myAnalyticsService.logEvent(eventName, properties);
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    await myAnalyticsService.setProperties(properties);
  }

  @override
  Future<void> startTimedEvent(String eventName) async {
    // Start timing
  }

  @override
  Future<void> endTimedEvent(String eventName, [Map<String, dynamic>? properties]) async {
    // End timing and track
  }
}
```

## Call Metrics

### Tracked Metrics

The package automatically tracks:

- **Init Duration**: Time to initialize Agora engine
- **Join Duration**: Time to join channel
- **Total Duration**: Total call duration
- **Reconnection Attempts**: Number of reconnects
- **Users Joined/Left**: Participant tracking
- **Errors**: Error occurrences and types
- **Network Quality**: Connection quality metrics

### Events Tracked

| Event | Properties | When Fired |
|-------|-----------|------------|
| `call_initialization` | `duration_ms`, `channel_name`, `uid` | Engine initialized |
| `call_join` | `duration_ms`, `channel_name`, `uid` | Channel joined |
| `call_joined` | `init_duration_ms`, `join_duration_ms` | Join successful |
| `call_ended` / `call_failed` | Full metrics | Call ends |
| `remote_user_joined` | `remote_uid`, `total_users` | User joins |
| `remote_user_left` | `remote_uid`, `reason` | User leaves |
| `call_reconnection` | `attempt`, `channel_name` | Reconnection attempt |
| `call_error` | `error_type`, `error_message` | Error occurs |
| `media_toggle` | `media_type`, `enabled` | Audio/video toggled |
| `camera_switched` | `channel_name` | Camera switched |

### Enabling Metrics

```dart
final config = AgoraCallConfig(
  appId: 'YOUR_APP_ID',
  channelName: 'test_channel',
  enableMetrics: true, // Enable metrics tracking
);

final controller = AgoraVideoCallController(
  config: config,
  analyticsProvider: myAnalyticsProvider,
);

// Access metrics
final metrics = controller.metrics;
print('Join time: ${metrics?.joinDurationMs}ms');
print('Users joined: ${metrics?.usersJoined}');
```

## Logging

### Log Levels

```dart
enum LogLevel {
  none,    // No logging
  error,   // Errors only (default)
  warning, // Warnings and errors
  info,    // Info, warnings, and errors
  debug,   // Everything
}
```

### Configuration

**Per-call logging:**

```dart
final config = AgoraCallConfig(
  appId: 'YOUR_APP_ID',
  channelName: 'test_channel',
  logLevel: LogLevel.info, // Set log level for this call
);
```

**Global logging:**

```dart
// Configure globally
AgoraLogger.configure(
  logLevel: LogLevel.debug,
  enableConsole: true,
);
```

### Disable Analytics in Production

```dart
// No analytics provider = no tracking
final controller = AgoraVideoCallController(
  config: config.copyWith(enableMetrics: false),
  // Don't pass analyticsProvider
);
```

## Call Recording

### Overview

The package supports Agora Cloud Recording through a backend service. **Recording requires a backend server** to manage Agora's Cloud Recording API.

### Recording Configuration

```dart
final recordingConfig = RecordingConfig(
  enabled: true,
  mode: RecordingMode.composite, // or RecordingMode.individual
  autoStart: true, // Start recording automatically
  maxDurationSeconds: 3600, // 1 hour max
  videoConfig: RecordingVideoConfig(
    width: 1280,
    height: 720,
    fps: 15,
    bitrate: 2000,
  ),
  audioConfig: RecordingAudioConfig(
    sampleRate: 48000,
    bitrate: 128,
    channels: 2,
  ),
  storageConfig: StorageConfig(
    vendor: 's3', // 's3', 'azure', 'gcs', 'oss'
    region: 'us-east-1',
    bucket: 'my-recordings',
    accessKey: 'YOUR_ACCESS_KEY',
    secretKey: 'YOUR_SECRET_KEY',
    fileNamePrefix: 'recording_',
  ),
);
```

### Recording Service Provider

**HTTP-based backend:**

```dart
final recordingService = HttpRecordingServiceProvider(
  baseUrl: 'https://your-backend.com/api',
  headers: {
    'Authorization': 'Bearer YOUR_API_KEY',
  },
);

final controller = AgoraVideoCallController(
  config: config,
  recordingConfig: recordingConfig,
  recordingServiceProvider: recordingService,
);
```

### Backend API Endpoints

Your backend should implement:

**POST `/recording/start`**
```json
{
  "channelName": "string",
  "uid": 0,
  "mode": "composite",
  "storageConfig": {},
  "videoConfig": {},
  "audioConfig": {}
}
```
Response:
```json
{
  "recordingId": "unique-id"
}
```

**POST `/recording/stop`**
```json
{
  "recordingId": "unique-id"
}
```

**GET `/recording/query/:recordingId`**
Response:
```json
{
  "recordingId": "unique-id",
  "isRecording": true,
  "fileUrl": "https://...",
  "durationSeconds": 120
}
```

### Manual Recording Control

```dart
// Start recording manually
await controller.startRecording();

// Stop recording
await controller.stopRecording();

// Check if recording
if (controller.isRecording) {
  print('Recording in progress');
}
```

## Examples

### Full Example with All Features

```dart
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:agora_video_call_kit/agora_video_call_kit.dart';

Future<void> startMonitoredCall() async {
  // 1. Initialize analytics
  final mixpanel = await Mixpanel.init('YOUR_TOKEN');
  final analytics = MixpanelAnalyticsProvider(mixpanel);

  // 2. Configure recording
  final recordingConfig = RecordingConfig(
    enabled: true,
    mode: RecordingMode.composite,
    autoStart: true,
  );

  final recordingService = HttpRecordingServiceProvider(
    baseUrl: 'https://your-backend.com/api',
  );

  // 3. Create configuration
  final config = AgoraCallConfig(
    appId: 'YOUR_APP_ID',
    channelName: 'monitored_channel',
    token: 'YOUR_TOKEN',
    uid: 0,
    enableMetrics: true,
    logLevel: LogLevel.info,
  );

  // 4. Create controller
  final controller = AgoraVideoCallController(
    config: config,
    analyticsProvider: analytics,
    recordingConfig: recordingConfig,
    recordingServiceProvider: recordingService,
  );

  // 5. Start call
  await controller.startCall();

  // 6. Access metrics anytime
  print('Metrics: ${controller.metrics?.toMap()}');
}
```

### Console Logging Only (No External Analytics)

```dart
final controller = AgoraVideoCallController(
  config: AgoraCallConfig(
    appId: 'YOUR_APP_ID',
    channelName: 'test',
    enableMetrics: true,
    logLevel: LogLevel.debug,
  ),
  analyticsProvider: ConsoleAnalyticsProvider(), // Logs to console
);
```

### Disable All Monitoring

```dart
final controller = AgoraVideoCallController(
  config: AgoraCallConfig(
    appId: 'YOUR_APP_ID',
    channelName: 'test',
    enableMetrics: false,  // No metrics
    logLevel: LogLevel.none, // No logs
  ),
  // No analyticsProvider
);
```

## Best Practices

### 1. Production Setup

```dart
// Production
final config = AgoraCallConfig(
  appId: appId,
  channelName: channelName,
  enableMetrics: true,
  logLevel: LogLevel.error, // Errors only in production
);

// Development
final config = AgoraCallConfig(
  appId: appId,
  channelName: channelName,
  enableMetrics: true,
  logLevel: LogLevel.debug, // Full logging in dev
);
```

### 2. Conditional Analytics

```dart
final analyticsProvider = kReleaseMode
    ? MixpanelAnalyticsProvider(mixpanel)
    : ConsoleAnalyticsProvider();
```

### 3. Recording Cost Management

```dart
// Only enable for premium users
final recordingConfig = user.isPremium
    ? RecordingConfig(enabled: true, ...)
    : null;
```

### 4. Error Tracking

```dart
controller.addListener(() {
  if (controller.callState == AgoraCallState.error) {
    // Log error to your error tracking service
    errorTracker.logError(controller.errorMessage);
  }
});
```

## Metrics Schema for Dashboards

### Sample Mixpanel Dashboard Queries

**Average Join Time:**
```javascript
average(event['call_joined'].properties['join_duration_ms'])
```

**Call Success Rate:**
```javascript
count(event['call_ended']) /
(count(event['call_ended']) + count(event['call_failed']))
```

**Reconnection Rate:**
```javascript
count(event['call_reconnection']) / count(event['call_joined'])
```

## Troubleshooting

### No Metrics Being Tracked

- Ensure `enableMetrics: true` in config
- Verify `analyticsProvider` is passed to controller
- Check analytics service initialization

### Recording Not Working

- Verify backend endpoints are accessible
- Check storage credentials
- Ensure Agora Cloud Recording is enabled in console
- Verify backend returns proper `recordingId`

### High Log Volume

- Reduce log level: `LogLevel.error` or `LogLevel.warning`
- Disable debug logs in production
- Use selective logging per feature

---

For more information, see:
- [Main README](README.md)
- [Integration Guide](INTEGRATION_GUIDE.md)
- [Advanced Example](example_app/lib/advanced_example.dart)
