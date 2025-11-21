import 'package:http/http.dart' as http;
import 'dart:convert';

import '../monitoring/agora_logger.dart';
import 'recording_config.dart';

/// Interface for recording service provider
///
/// Implement this to integrate with your recording backend
abstract class RecordingServiceProvider {
  /// Start recording for a channel
  Future<String?> startRecording({
    required String channelName,
    required int uid,
    required RecordingConfig config,
  });

  /// Stop recording
  Future<void> stopRecording(String recordingId);

  /// Query recording status
  Future<RecordingStatus?> queryRecording(String recordingId);
}

/// Recording status
class RecordingStatus {
  final String recordingId;
  final bool isRecording;
  final String? fileUrl;
  final int durationSeconds;

  const RecordingStatus({
    required this.recordingId,
    required this.isRecording,
    this.fileUrl,
    this.durationSeconds = 0,
  });

  factory RecordingStatus.fromJson(Map<String, dynamic> json) {
    return RecordingStatus(
      recordingId: json['recordingId'] as String,
      isRecording: json['isRecording'] as bool,
      fileUrl: json['fileUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
    );
  }
}

/// HTTP-based recording service provider
///
/// This calls your backend server which manages Agora Cloud Recording API
class HttpRecordingServiceProvider implements RecordingServiceProvider {
  final String baseUrl;
  final http.Client httpClient;
  final Map<String, String>? headers;
  final AgoraLogger _logger = AgoraLogger('RecordingService');

  HttpRecordingServiceProvider({
    required this.baseUrl,
    http.Client? httpClient,
    this.headers,
  }) : httpClient = httpClient ?? http.Client();

  @override
  Future<String?> startRecording({
    required String channelName,
    required int uid,
    required RecordingConfig config,
  }) async {
    try {
      _logger.info('Starting recording for channel: $channelName');

      final response = await httpClient.post(
        Uri.parse('$baseUrl/recording/start'),
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: jsonEncode({
          'channelName': channelName,
          'uid': uid,
          'mode': config.mode.name,
          'storageConfig': config.storageConfig?.toJson(),
          'videoConfig': config.videoConfig?.toJson(),
          'audioConfig': config.audioConfig?.toJson(),
          'maxDurationSeconds': config.maxDurationSeconds,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final recordingId = data['recordingId'] as String?;
        _logger.info('Recording started: $recordingId');
        return recordingId;
      } else {
        _logger.error(
          'Failed to start recording: ${response.statusCode}',
          response.body,
        );
        return null;
      }
    } catch (e, stackTrace) {
      _logger.error('Error starting recording', e, stackTrace);
      return null;
    }
  }

  @override
  Future<void> stopRecording(String recordingId) async {
    try {
      _logger.info('Stopping recording: $recordingId');

      final response = await httpClient.post(
        Uri.parse('$baseUrl/recording/stop'),
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: jsonEncode({
          'recordingId': recordingId,
        }),
      );

      if (response.statusCode == 200) {
        _logger.info('Recording stopped: $recordingId');
      } else {
        _logger.error(
          'Failed to stop recording: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e, stackTrace) {
      _logger.error('Error stopping recording', e, stackTrace);
    }
  }

  @override
  Future<RecordingStatus?> queryRecording(String recordingId) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/recording/query/$recordingId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RecordingStatus.fromJson(data);
      } else {
        _logger.error(
          'Failed to query recording: ${response.statusCode}',
          response.body,
        );
        return null;
      }
    } catch (e, stackTrace) {
      _logger.error('Error querying recording', e, stackTrace);
      return null;
    }
  }
}

/// Manages call recording
class RecordingManager {
  final RecordingServiceProvider? serviceProvider;
  final RecordingConfig config;
  final AgoraLogger _logger = AgoraLogger('RecordingManager');

  String? _currentRecordingId;
  bool _isRecording = false;

  RecordingManager({
    this.serviceProvider,
    required this.config,
  });

  /// Whether recording is currently active
  bool get isRecording => _isRecording;

  /// Current recording ID
  String? get currentRecordingId => _currentRecordingId;

  /// Start recording
  Future<bool> startRecording({
    required String channelName,
    required int uid,
  }) async {
    if (!config.enabled || serviceProvider == null) {
      _logger.info('Recording disabled or no service provider');
      return false;
    }

    if (_isRecording) {
      _logger.warning('Recording already in progress');
      return false;
    }

    try {
      _logger.info('Requesting recording start');

      final recordingId = await serviceProvider!.startRecording(
        channelName: channelName,
        uid: uid,
        config: config,
      );

      if (recordingId != null) {
        _currentRecordingId = recordingId;
        _isRecording = true;
        _logger.info('Recording started successfully: $recordingId');
        return true;
      } else {
        _logger.error('Failed to start recording');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.error('Error in startRecording', e, stackTrace);
      return false;
    }
  }

  /// Stop recording
  Future<void> stopRecording() async {
    if (!_isRecording || _currentRecordingId == null || serviceProvider == null) {
      return;
    }

    try {
      _logger.info('Stopping recording: $_currentRecordingId');
      await serviceProvider!.stopRecording(_currentRecordingId!);
      _isRecording = false;
      _currentRecordingId = null;
      _logger.info('Recording stopped');
    } catch (e, stackTrace) {
      _logger.error('Error stopping recording', e, stackTrace);
    }
  }

  /// Query current recording status
  Future<RecordingStatus?> queryStatus() async {
    if (_currentRecordingId == null || serviceProvider == null) {
      return null;
    }

    try {
      return await serviceProvider!.queryRecording(_currentRecordingId!);
    } catch (e, stackTrace) {
      _logger.error('Error querying recording status', e, stackTrace);
      return null;
    }
  }

  /// Dispose and clean up
  Future<void> dispose() async {
    if (_isRecording) {
      await stopRecording();
    }
  }
}
