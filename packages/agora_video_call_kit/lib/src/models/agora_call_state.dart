/// Represents the current state of an Agora video call
enum AgoraCallState {
  /// Initial state, before any connection attempt
  idle,

  /// Requesting permissions and initializing
  initializing,

  /// Joining the channel
  joining,

  /// Successfully joined and in an active call
  joined,

  /// Connection lost, attempting to reconnect
  reconnecting,

  /// Leaving the channel
  leaving,

  /// Left the channel, call ended
  left,

  /// Error occurred during call setup or execution
  error,
}

/// Extension methods for AgoraCallState
extension AgoraCallStateExtension on AgoraCallState {
  /// Check if the call is in an active state
  bool get isActive =>
      this == AgoraCallState.joined || this == AgoraCallState.reconnecting;

  /// Check if the call is connecting
  bool get isConnecting =>
      this == AgoraCallState.initializing || this == AgoraCallState.joining;

  /// Check if the call has ended
  bool get hasEnded => this == AgoraCallState.left;

  /// Check if there's an error
  bool get hasError => this == AgoraCallState.error;

  /// Get a human-readable description
  String get description {
    switch (this) {
      case AgoraCallState.idle:
        return 'Idle';
      case AgoraCallState.initializing:
        return 'Initializing...';
      case AgoraCallState.joining:
        return 'Joining call...';
      case AgoraCallState.joined:
        return 'Connected';
      case AgoraCallState.reconnecting:
        return 'Reconnecting...';
      case AgoraCallState.leaving:
        return 'Leaving...';
      case AgoraCallState.left:
        return 'Call ended';
      case AgoraCallState.error:
        return 'Error';
    }
  }
}
