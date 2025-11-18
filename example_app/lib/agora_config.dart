/// Agora Configuration
///
/// Update these values with your own Agora credentials
///
/// To get started:
/// 1. Create a project at https://console.agora.io
/// 2. Get your App ID from the project settings
/// 3. For testing, you can leave token as null (not recommended for production)
/// 4. For production, implement a token server and use AgoraTokenProvider
class AgoraConfig {
  /// Your Agora App ID from console.agora.io
  ///
  /// IMPORTANT: Replace this with your actual App ID
  static const String appId = 'YOUR_APP_ID_HERE';

  /// Agora token for authentication
  ///
  /// - For testing without security, you can set this to null or empty string
  /// - For production, generate tokens from your server
  /// - Learn more: https://docs.agora.io/en/video-calling/get-started/authentication-workflow
  static const String? token = null;

  // Optional: Add your token server URL here
  // static const String tokenServerUrl = 'https://your-server.com/agora/token';
}
