import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import '../services/voip_service.dart';
import 'result_screen.dart';

class CallScreen extends StatefulWidget {
  final String channelName;
  final String contactName;

  const CallScreen({
    super.key,
    required this.channelName,
    required this.contactName,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final VoIPService _voipService = VoIPService();
  Timer? _callTimer;
  int _seconds = 0;
  String _statusText = "Connecting...";
  
  // --- Audio Recording State ---
  String? _recordingPath;
  IOSink? _audioSink;
  final List<Uint8List> _audioChunks = [];

  @override
  void initState() {
    super.initState();
    _startCall();
  }

  Future<void> _startCall() async {
    await _initializeRecording();

    _voipService.onMixedAudioChunkReceived = (chunk) {
      if (_audioSink != null) {
        _audioSink!.add(chunk);
      } else {
        _audioChunks.add(chunk); // Store chunks if sink isn't ready
      }
    };

    try {
      await _voipService.initialize();
      await _voipService.joinChannel(widget.channelName); // Join the dynamic channel
    } catch (e) {
      print("[CallScreen] VoIP Error: $e");
    }

    if (mounted) {
      setState(() => _statusText = "Ringing...");
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return; 

      setState(() => _statusText = "00:00");
      _startTimer();
    }
  }

  Future<void> _initializeRecording() async {
    final tempDir = await getTemporaryDirectory();
    _recordingPath = '${tempDir.path}/call_recording.raw';
    final file = File(_recordingPath!);
    _audioSink = file.openWrite();

    if (_audioChunks.isNotEmpty) {
      for (var chunk in _audioChunks) {
        _audioSink!.add(chunk);
      }
      _audioChunks.clear();
    }
  }

  void _startTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        _statusText = '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}';
      });
    });
  }

  Future<void> _endCall() async {
    _callTimer?.cancel();
    await _voipService.leaveChannel();
    await _voipService.dispose();

    await _audioSink?.flush();
    await _audioSink?.close();

    if (mounted && _recordingPath != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(audioPath: _recordingPath!),
        ),
      );
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _audioSink?.close();
    _voipService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const CircleAvatar(radius: 50, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 60, color: Colors.white)),
                const SizedBox(height: 20),
                Text(widget.contactName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Text(_statusText, style: const TextStyle(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 10),
                const Text("TrueGuard Secured Call", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(Icons.mic_off, "Mute"),
                _buildControlButton(Icons.dialpad, "Keypad"),
                _buildControlButton(Icons.volume_up, "Speaker"),
              ],
            ),
            FloatingActionButton.large(onPressed: _endCall, backgroundColor: Colors.redAccent, child: const Icon(Icons.call_end, size: 36, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(radius: 30, backgroundColor: Colors.white10, child: Icon(icon, color: Colors.white, size: 28)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
