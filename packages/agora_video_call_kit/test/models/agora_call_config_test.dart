import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_video_call_kit/agora_video_call_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgoraCallConfig', () {
    test('should create config with required parameters', () {
      final config = AgoraCallConfig(
        appId: 'test_app_id',
        channelName: 'test_channel',
      );

      expect(config.appId, 'test_app_id');
      expect(config.channelName, 'test_channel');
      expect(config.uid, 0);
      expect(config.role, ClientRoleType.clientRoleBroadcaster);
      expect(config.enableAudio, true);
      expect(config.enableVideo, true);
    });

    test('should create config with all parameters', () {
      final config = AgoraCallConfig(
        appId: 'test_app_id',
        channelName: 'test_channel',
        token: 'test_token',
        uid: 12345,
        role: ClientRoleType.clientRoleAudience,
        enableAudio: false,
        enableVideo: false,
        userName: 'Test User',
      );

      expect(config.appId, 'test_app_id');
      expect(config.channelName, 'test_channel');
      expect(config.token, 'test_token');
      expect(config.uid, 12345);
      expect(config.role, ClientRoleType.clientRoleAudience);
      expect(config.enableAudio, false);
      expect(config.enableVideo, false);
      expect(config.userName, 'Test User');
    });

    test('host factory should create broadcaster config', () {
      final config = AgoraCallConfig.host(
        appId: 'test_app_id',
        channelName: 'test_channel',
        userName: 'Host User',
      );

      expect(config.role, ClientRoleType.clientRoleBroadcaster);
      expect(config.userName, 'Host User');
    });

    test('audience factory should create audience config', () {
      final config = AgoraCallConfig.audience(
        appId: 'test_app_id',
        channelName: 'test_channel',
        userName: 'Audience User',
      );

      expect(config.role, ClientRoleType.clientRoleAudience);
      expect(config.enableAudio, false);
      expect(config.enableVideo, false);
      expect(config.userName, 'Audience User');
    });

    test('copyWith should create modified config', () {
      final original = AgoraCallConfig(
        appId: 'original_app_id',
        channelName: 'original_channel',
      );

      final modified = original.copyWith(
        channelName: 'new_channel',
        uid: 999,
      );

      expect(modified.appId, 'original_app_id'); // Unchanged
      expect(modified.channelName, 'new_channel'); // Changed
      expect(modified.uid, 999); // Changed
    });

    test('isValid should return true for valid config', () {
      final config = AgoraCallConfig(
        appId: 'test_app_id',
        channelName: 'test_channel',
      );

      expect(config.isValid, true);
      expect(config.validationError, null);
    });

    test('isValid should return false for empty app ID', () {
      final config = AgoraCallConfig(
        appId: '',
        channelName: 'test_channel',
      );

      expect(config.isValid, false);
      expect(config.validationError, 'App ID is required');
    });

    test('isValid should return false for empty channel name', () {
      final config = AgoraCallConfig(
        appId: 'test_app_id',
        channelName: '',
      );

      expect(config.isValid, false);
      expect(config.validationError, 'Channel name is required');
    });

    test('toString should return formatted string', () {
      final config = AgoraCallConfig(
        appId: 'test_app_id',
        channelName: 'test_channel',
        uid: 12345,
      );

      final str = config.toString();
      expect(str, contains('test_app_id'));
      expect(str, contains('test_channel'));
      expect(str, contains('12345'));
    });
  });
}
