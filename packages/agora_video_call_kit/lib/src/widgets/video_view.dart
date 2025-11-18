import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

import '../models/remote_user.dart';

/// Widget for displaying local video feed
class LocalVideoView extends StatelessWidget {
  final RtcEngine engine;
  final bool isVideoEnabled;
  final String? userName;

  const LocalVideoView({
    Key? key,
    required this.engine,
    required this.isVideoEnabled,
    this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isVideoEnabled)
              AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
            else
              _buildPlaceholder(context, 'You'),
            if (userName != null)
              Positioned(
                bottom: 8,
                left: 8,
                child: _buildNameTag(userName!, context),
              ),
            if (!isVideoEnabled)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.videocam_off,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, String label) {
    return Container(
      color: Colors.blueGrey.shade900,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blueGrey.shade700,
              child: Text(
                label.isNotEmpty ? label[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameTag(String name, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Widget for displaying remote user video feed
class RemoteVideoView extends StatelessWidget {
  final RtcEngine engine;
  final RemoteUser user;
  final RtcConnection? connection;

  const RemoteVideoView({
    Key? key,
    required this.engine,
    required this.user,
    this.connection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (user.hasVideo)
              AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: engine,
                  canvas: VideoCanvas(uid: user.uid),
                  connection: connection ?? const RtcConnection(channelId: ''),
                ),
              )
            else
              _buildPlaceholder(context, user),
            Positioned(
              bottom: 8,
              left: 8,
              child: _buildNameTag(user, context),
            ),
            if (!user.hasVideo)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.videocam_off,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ),
            if (!user.hasAudio)
              Positioned(
                top: 8,
                left: 8,
                child: Icon(
                  Icons.mic_off,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, RemoteUser user) {
    final label = user.name ?? 'User ${user.uid}';
    return Container(
      color: Colors.blueGrey.shade900,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueGrey.shade700,
              child: Text(
                label.isNotEmpty ? label[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameTag(RemoteUser user, BuildContext context) {
    final name = user.name ?? 'User ${user.uid}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Grid layout for multiple remote users
class RemoteUsersGrid extends StatelessWidget {
  final RtcEngine engine;
  final List<RemoteUser> users;
  final RtcConnection? connection;

  const RemoteUsersGrid({
    Key? key,
    required this.engine,
    required this.users,
    this.connection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Waiting for others to join...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (users.length == 1) {
      return RemoteVideoView(
        engine: engine,
        user: users[0],
        connection: connection,
      );
    }

    // Grid layout for multiple users
    final crossAxisCount = users.length <= 4 ? 2 : 3;
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return RemoteVideoView(
          engine: engine,
          user: users[index],
          connection: connection,
        );
      },
    );
  }
}
