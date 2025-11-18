/// Abstract interface for fetching Agora tokens dynamically
///
/// Implement this interface in your app to provide tokens from your
/// authentication server. This allows for secure token management and
/// automatic token refresh.
///
/// Example implementation:
/// ```dart
/// class MyTokenProvider implements AgoraTokenProvider {
///   final ApiClient apiClient;
///
///   MyTokenProvider(this.apiClient);
///
///   @override
///   Future<String> getToken({
///     required String channelName,
///     required int uid,
///   }) async {
///     final response = await apiClient.post('/agora/token', {
///       'channelName': channelName,
///       'uid': uid,
///     });
///     return response['token'];
///   }
/// }
/// ```
abstract class AgoraTokenProvider {
  /// Fetch a token for the given channel and user ID
  ///
  /// [channelName] - The name of the channel to join
  /// [uid] - The user ID for which to generate the token
  ///
  /// Returns a valid Agora token string
  /// Throws an exception if token generation fails
  Future<String> getToken({
    required String channelName,
    required int uid,
  });
}

/// Simple implementation that returns a pre-configured token
///
/// Use this for testing or when you have a long-lived token
class StaticTokenProvider implements AgoraTokenProvider {
  final String token;

  const StaticTokenProvider(this.token);

  @override
  Future<String> getToken({
    required String channelName,
    required int uid,
  }) async {
    return token;
  }
}

/// Implementation for testing without authentication
///
/// WARNING: Only use this for development/testing!
/// Production apps should always use proper token authentication
class NoAuthTokenProvider implements AgoraTokenProvider {
  const NoAuthTokenProvider();

  @override
  Future<String> getToken({
    required String channelName,
    required int uid,
  }) async {
    return '';
  }
}
