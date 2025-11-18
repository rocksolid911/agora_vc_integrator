import 'package:agora_video_call_kit/agora_video_call_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StaticTokenProvider', () {
    test('should return pre-configured token', () async {
      const testToken = 'test_static_token';
      final provider = StaticTokenProvider(testToken);

      final token = await provider.getToken(
        channelName: 'test_channel',
        uid: 12345,
      );

      expect(token, testToken);
    });

    test('should return same token regardless of parameters', () async {
      const testToken = 'test_static_token';
      final provider = StaticTokenProvider(testToken);

      final token1 = await provider.getToken(
        channelName: 'channel1',
        uid: 111,
      );

      final token2 = await provider.getToken(
        channelName: 'channel2',
        uid: 222,
      );

      expect(token1, testToken);
      expect(token2, testToken);
      expect(token1, token2);
    });
  });

  group('NoAuthTokenProvider', () {
    test('should return empty token', () async {
      const provider = NoAuthTokenProvider();

      final token = await provider.getToken(
        channelName: 'test_channel',
        uid: 12345,
      );

      expect(token, '');
    });

    test('should always return empty token', () async {
      const provider = NoAuthTokenProvider();

      final token1 = await provider.getToken(
        channelName: 'channel1',
        uid: 111,
      );

      final token2 = await provider.getToken(
        channelName: 'channel2',
        uid: 222,
      );

      expect(token1, '');
      expect(token2, '');
    });
  });

  group('Custom AgoraTokenProvider', () {
    test('custom implementation should work', () async {
      final provider = _MockTokenProvider();

      final token = await provider.getToken(
        channelName: 'test_channel',
        uid: 12345,
      );

      expect(token, 'mock_token_test_channel_12345');
    });
  });
}

// Mock implementation for testing
class _MockTokenProvider implements AgoraTokenProvider {
  @override
  Future<String> getToken({
    required String channelName,
    required int uid,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 10));
    return 'mock_token_${channelName}_$uid';
  }
}
