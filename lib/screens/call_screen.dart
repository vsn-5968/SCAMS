import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'result_screen.dart'; // We will create this next

class CallScreen extends StatefulWidget {
  final String contactName;
  final String phoneNumber;

  const CallScreen({
    super.key,
    required this.contactName,
    required this.phoneNumber,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  Timer? _callTimer;
  int _seconds = 0;
  bool _isRecording = false;
  String _statusText = "Connecting...";

  @override
  void initState() {
    super.initState();
    _startCallSimulation();
  }

  Future<void> _startCallSimulation() async {
    // 1. Initialize Recorder
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) Navigator.pop(context);
      return;
    }
    await _recorder.openRecorder();

    // 2. Simulate "Connecting..." delay
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 3. Start Call & Recording
    setState(() => _statusText = "00:00");
    _startTimer();
    _startRecording();
  }

  void _startTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        _statusText = _formatTime(_seconds);
      });
    });
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/call_recording.aac';
    await _recorder.startRecorder(toFile: filePath);
    setState(() => _isRecording = true);
  }

  Future<void> _endCall() async {
    _callTimer?.cancel();
    String? path;

    if (_isRecording) {
      path = await _recorder.stopRecorder();
    }
    await _recorder.closeRecorder();

    if (mounted) {
      if (path != null) {
        // Navigate to result screen which handles the upload
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(audioPath: path!),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _recorder.closeRecorder();
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
            // Contact Info
            Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.contactName,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  _statusText,
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ],
            ),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(Icons.mic_off, "Mute"),
                _buildControlButton(Icons.keypad, "Keypad"),
                _buildControlButton(Icons.volume_up, "Speaker"),
              ],
            ),

            // End Call Button
            FloatingActionButton.large(
              onPressed: _endCall,
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.call_end, size: 36, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white10,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
