import 'package:flutter/material.dart';
import 'package:agora_video_call_kit/agora_video_call_kit.dart';

import 'agora_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agora Video Call Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _channelController = TextEditingController(text: 'test_channel');
  final _userNameController = TextEditingController(text: 'User');
  bool _isHost = true;

  @override
  void dispose() {
    _channelController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  void _startCall() {
    final channelName = _channelController.text.trim();
    if (channelName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a channel name')),
      );
      return;
    }

    final config = AgoraCallConfig(
      appId: AgoraConfig.appId,
      channelName: channelName,
      token: AgoraConfig.token, // Can be null for testing
      uid: 0, // 0 = auto-assign
      role: _isHost
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
      userName: _userNameController.text.trim(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgoraVideoCallScreen(
          config: config,
          onCallEnded: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Call ended')),
            );
          },
          showDebugInfo: true, // Enable debug info for demo
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call Demo'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.video_call,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Start a Video Call',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _channelController,
              decoration: const InputDecoration(
                labelText: 'Channel Name',
                hintText: 'Enter channel name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                hintText: 'Enter your display name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Join as:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    RadioListTile<bool>(
                      title: const Text('Host (Broadcaster)'),
                      subtitle: const Text('Can send and receive audio/video'),
                      value: true,
                      groupValue: _isHost,
                      onChanged: (value) {
                        setState(() {
                          _isHost = value!;
                        });
                      },
                    ),
                    RadioListTile<bool>(
                      title: const Text('Audience'),
                      subtitle: const Text('Can only receive audio/video'),
                      value: false,
                      groupValue: _isHost,
                      onChanged: (value) {
                        setState(() {
                          _isHost = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startCall,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Start Call',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Configuration Required',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Update lib/agora_config.dart with your Agora App ID and Token before using this demo.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to use:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. Get your Agora App ID from console.agora.io'),
                    SizedBox(height: 4),
                    Text('2. Update agora_config.dart with your credentials'),
                    SizedBox(height: 4),
                    Text('3. Enter a channel name (same for all participants)'),
                    SizedBox(height: 4),
                    Text('4. Choose your role and start the call'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
