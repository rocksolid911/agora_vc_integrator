/// Configuration for call recording
class RecordingConfig {
  /// Whether recording is enabled
  final bool enabled;

  /// Recording mode (individual or composite)
  final RecordingMode mode;

  /// Storage configuration (where to save recordings)
  final StorageConfig? storageConfig;

  /// Video configuration for recording
  final RecordingVideoConfig? videoConfig;

  /// Audio configuration for recording
  final RecordingAudioConfig? audioConfig;

  /// Maximum recording duration in seconds (0 = unlimited)
  final int maxDurationSeconds;

  /// Whether to record automatically when call starts
  final bool autoStart;

  const RecordingConfig({
    this.enabled = false,
    this.mode = RecordingMode.composite,
    this.storageConfig,
    this.videoConfig,
    this.audioConfig,
    this.maxDurationSeconds = 0,
    this.autoStart = true,
  });

  RecordingConfig copyWith({
    bool? enabled,
    RecordingMode? mode,
    StorageConfig? storageConfig,
    RecordingVideoConfig? videoConfig,
    RecordingAudioConfig? audioConfig,
    int? maxDurationSeconds,
    bool? autoStart,
  }) {
    return RecordingConfig(
      enabled: enabled ?? this.enabled,
      mode: mode ?? this.mode,
      storageConfig: storageConfig ?? this.storageConfig,
      videoConfig: videoConfig ?? this.videoConfig,
      audioConfig: audioConfig ?? this.audioConfig,
      maxDurationSeconds: maxDurationSeconds ?? this.maxDurationSeconds,
      autoStart: autoStart ?? this.autoStart,
    );
  }
}

/// Recording mode
enum RecordingMode {
  /// Record each user individually
  individual,

  /// Record all users in a single composite video
  composite,
}

/// Storage configuration for recordings
class StorageConfig {
  /// Vendor (e.g., 's3', 'azure', 'gcs', 'oss')
  final String vendor;

  /// Region
  final String region;

  /// Bucket name
  final String bucket;

  /// Access key
  final String accessKey;

  /// Secret key
  final String secretKey;

  /// File name prefix
  final String? fileNamePrefix;

  const StorageConfig({
    required this.vendor,
    required this.region,
    required this.bucket,
    required this.accessKey,
    required this.secretKey,
    this.fileNamePrefix,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendor': vendor,
      'region': region,
      'bucket': bucket,
      'accessKey': accessKey,
      'secretKey': secretKey,
      if (fileNamePrefix != null) 'fileNamePrefix': fileNamePrefix,
    };
  }
}

/// Video configuration for recording
class RecordingVideoConfig {
  /// Video width
  final int width;

  /// Video height
  final int height;

  /// Frame rate
  final int fps;

  /// Bitrate in kbps
  final int bitrate;

  const RecordingVideoConfig({
    this.width = 1280,
    this.height = 720,
    this.fps = 15,
    this.bitrate = 2000,
  });

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'fps': fps,
      'bitrate': bitrate,
    };
  }
}

/// Audio configuration for recording
class RecordingAudioConfig {
  /// Sample rate
  final int sampleRate;

  /// Bitrate in kbps
  final int bitrate;

  /// Number of channels
  final int channels;

  const RecordingAudioConfig({
    this.sampleRate = 48000,
    this.bitrate = 128,
    this.channels = 2,
  });

  Map<String, dynamic> toJson() {
    return {
      'sampleRate': sampleRate,
      'bitrate': bitrate,
      'channels': channels,
    };
  }
}
