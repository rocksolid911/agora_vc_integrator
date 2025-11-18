import 'package:agora_video_call_kit/agora_video_call_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgoraCallState', () {
    test('isActive should return true for joined state', () {
      expect(AgoraCallState.joined.isActive, true);
    });

    test('isActive should return true for reconnecting state', () {
      expect(AgoraCallState.reconnecting.isActive, true);
    });

    test('isActive should return false for other states', () {
      expect(AgoraCallState.idle.isActive, false);
      expect(AgoraCallState.initializing.isActive, false);
      expect(AgoraCallState.joining.isActive, false);
      expect(AgoraCallState.leaving.isActive, false);
      expect(AgoraCallState.left.isActive, false);
      expect(AgoraCallState.error.isActive, false);
    });

    test('isConnecting should return true for initializing and joining', () {
      expect(AgoraCallState.initializing.isConnecting, true);
      expect(AgoraCallState.joining.isConnecting, true);
    });

    test('isConnecting should return false for other states', () {
      expect(AgoraCallState.idle.isConnecting, false);
      expect(AgoraCallState.joined.isConnecting, false);
      expect(AgoraCallState.reconnecting.isConnecting, false);
      expect(AgoraCallState.leaving.isConnecting, false);
      expect(AgoraCallState.left.isConnecting, false);
      expect(AgoraCallState.error.isConnecting, false);
    });

    test('hasEnded should return true only for left state', () {
      expect(AgoraCallState.left.hasEnded, true);
      expect(AgoraCallState.idle.hasEnded, false);
      expect(AgoraCallState.joined.hasEnded, false);
      expect(AgoraCallState.error.hasEnded, false);
    });

    test('hasError should return true only for error state', () {
      expect(AgoraCallState.error.hasError, true);
      expect(AgoraCallState.idle.hasError, false);
      expect(AgoraCallState.joined.hasError, false);
      expect(AgoraCallState.left.hasError, false);
    });

    test('description should return human-readable strings', () {
      expect(AgoraCallState.idle.description, 'Idle');
      expect(AgoraCallState.initializing.description, 'Initializing...');
      expect(AgoraCallState.joining.description, 'Joining call...');
      expect(AgoraCallState.joined.description, 'Connected');
      expect(AgoraCallState.reconnecting.description, 'Reconnecting...');
      expect(AgoraCallState.leaving.description, 'Leaving...');
      expect(AgoraCallState.left.description, 'Call ended');
      expect(AgoraCallState.error.description, 'Error');
    });
  });
}
