import 'package:agora_video_call_kit/agora_video_call_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoteUser', () {
    test('should create user with required parameters', () {
      final user = RemoteUser(uid: 12345);

      expect(user.uid, 12345);
      expect(user.hasVideo, true);
      expect(user.hasAudio, true);
      expect(user.name, null);
    });

    test('should create user with all parameters', () {
      final now = DateTime.now();
      final user = RemoteUser(
        uid: 12345,
        hasVideo: false,
        hasAudio: false,
        name: 'Test User',
        joinedAt: now,
      );

      expect(user.uid, 12345);
      expect(user.hasVideo, false);
      expect(user.hasAudio, false);
      expect(user.name, 'Test User');
      expect(user.joinedAt, now);
    });

    test('copyWith should create modified user', () {
      final original = RemoteUser(
        uid: 12345,
        hasVideo: true,
        hasAudio: true,
      );

      final modified = original.copyWith(
        hasVideo: false,
        name: 'Modified User',
      );

      expect(modified.uid, 12345); // Unchanged
      expect(modified.hasVideo, false); // Changed
      expect(modified.hasAudio, true); // Unchanged
      expect(modified.name, 'Modified User'); // Changed
    });

    test('equality should be based on uid', () {
      final user1 = RemoteUser(uid: 12345, name: 'User 1');
      final user2 = RemoteUser(uid: 12345, name: 'User 2');
      final user3 = RemoteUser(uid: 54321, name: 'User 3');

      expect(user1, user2); // Same UID
      expect(user1 == user3, false); // Different UID
    });

    test('hashCode should be based on uid', () {
      final user1 = RemoteUser(uid: 12345);
      final user2 = RemoteUser(uid: 12345);

      expect(user1.hashCode, user2.hashCode);
    });

    test('toString should return formatted string', () {
      final user = RemoteUser(
        uid: 12345,
        hasVideo: true,
        hasAudio: false,
        name: 'Test User',
      );

      final str = user.toString();
      expect(str, contains('12345'));
      expect(str, contains('true')); // hasVideo
      expect(str, contains('false')); // hasAudio
      expect(str, contains('Test User'));
    });
  });
}
