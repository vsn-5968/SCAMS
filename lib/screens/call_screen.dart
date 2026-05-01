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
    
    _voipService.onMixedAudioChunkReceived = null;
    await _voipService.leaveChannel();
    await _voipService.dispose();

    if (_audioSink != null) {
      await _audioSink!.flush();
      await _audioSink!.close();
      _audioSink = null;
    }

    if (mounted && _recordingPath != null) {
      // CONVERT RAW TO WAV BEFORE SENDING
      String wavPath = await _convertToWav(_recordingPath!);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(audioPath: wavPath),
        ),
      );
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<String> _convertToWav(String rawPath) async {
    final rawFile = File(rawPath);
    final wavPath = rawPath.replaceAll('.raw', '.wav');
    final wavFile = File(wavPath);

    final rawBytes = await rawFile.readAsBytes();
    final fileSize = rawBytes.length;

    final header = ByteData(44);
    // RIFF header
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, 36 + fileSize, Endian.little);
    header.setUint8(8, 0x57); // W
    header.setUint8(9, 0x41); // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E

    // fmt chunk
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6D); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // ' '
    header.setUint32(16, 16, Endian.little); // Subchunk1Size
    header.setUint16(20, 1, Endian.little); // AudioFormat (PCM)
    header.setUint16(22, 1, Endian.little); // NumChannels (Mono)
    header.setUint32(24, 16000, Endian.little); // SampleRate
    header.setUint32(28, 32000, Endian.little); // ByteRate (SampleRate * NumChannels * BitsPerSample/8)
    header.setUint16(32, 2, Endian.little); // BlockAlign (NumChannels * BitsPerSample/8)
    header.setUint16(34, 16, Endian.little); // BitsPerSample

    // data chunk
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, fileSize, Endian.little);

    final wavBytes = Uint8List(44 + fileSize);
    wavBytes.setRange(0, 44, header.buffer.asUint8List());
    wavBytes.setRange(44, 44 + fileSize, rawBytes);

    await wavFile.writeAsBytes(wavBytes);
    return wavPath;
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
