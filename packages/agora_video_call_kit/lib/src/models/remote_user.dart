/// Represents a remote user in the Agora call
class RemoteUser {
  /// Unique user ID
  final int uid;

  /// Whether the user has video enabled
  final bool hasVideo;

  /// Whether the user has audio enabled
  final bool hasAudio;

  /// Optional display name
  final String? name;

  /// Timestamp when user joined
  final DateTime joinedAt;

   RemoteUser({
    required this.uid,
    this.hasVideo = true,
    this.hasAudio = true,
    this.name,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ??  _DefaultDateTime();

  /// Copy with method for updating user state
  RemoteUser copyWith({
    int? uid,
    bool? hasVideo,
    bool? hasAudio,
    String? name,
    DateTime? joinedAt,
  }) {
    return RemoteUser(
      uid: uid ?? this.uid,
      hasVideo: hasVideo ?? this.hasVideo,
      hasAudio: hasAudio ?? this.hasAudio,
      name: name ?? this.name,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RemoteUser && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'RemoteUser(uid: $uid, video: $hasVideo, audio: $hasAudio, name: $name)';
  }
}

/// Helper class for default DateTime in const constructor
class _DefaultDateTime extends DateTime {
   _DefaultDateTime() : super.fromMillisecondsSinceEpoch(0);
}
