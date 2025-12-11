import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';

void main() {
  runApp(const ScamDetectorApp());
}

class ScamDetectorApp extends StatelessWidget {
  const ScamDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCAMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF00BFA5),
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        cardColor: const Color(0xFF1B263B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1B2A),
          elevation: 0,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00BFA5),
          secondary: Color(0xFF3D5A80),
          surface: Color(0xFF1B263B),
        ),
      ),
      home: const AudioScannerScreen(),
    );
  }
}

class AudioScannerScreen extends StatefulWidget {
  const AudioScannerScreen({super.key});

  @override
  State<AudioScannerScreen> createState() => _AudioScannerScreenState();
}

class _AudioScannerScreenState extends State<AudioScannerScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialised = false;
  bool _isRecording = false;
  bool _isLoading = false;
  String? _predictionResult;
  String? _transcript;
  File? _selectedFile;

  // Backend URL - UPDATED to the new endpoint provided
  final String _backendUrl = 'https://scam-app.onrender.com/audio/upload';

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission not granted')),
      );
      return;
    }

    await _recorder.openRecorder();
    _isRecorderInitialised = true;
    setState(() {});
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _record() async {
    if (!_isRecorderInitialised) return;

    if (_isRecording) {
      // Stop Recording
      final path = await _recorder.stopRecorder();
      setState(() => _isRecording = false);
      if (path != null) {
        _uploadAudio(File(path));
      }
    } else {
      // Start Recording
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/temp_audio.aac';
      await _recorder.startRecorder(toFile: filePath);
      setState(() => _isRecording = true);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _selectedFile = file;
        _predictionResult = null; // Reset previous result
        _transcript = null;
      });
      _uploadAudio(file);
    }
  }

  Future<void> _uploadAudio(File file) async {
    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_backendUrl));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Parse the response based on the structure: {"transcript": ..., "is_scam": ...}
        bool isScam = data['is_scam'] == true;
        String transcript = data['transcript'] ?? "No transcript available.";

        setState(() {
          _predictionResult = isScam ? "Potential Scam Call Detected" : "Audio Seems Safe.\nNot Scam Call";
          _transcript = transcript;
        });
      } else {
        setState(() {
          _predictionResult = "Error: Server returned ${response.statusCode}";
          _transcript = null;
        });
      }
    } catch (e) {
      setState(() {
        _predictionResult = "Error: Connection failed";
        _transcript = null;
      });
      print("Upload error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Scam Detector"),
        centerTitle: true,
        leading: const Icon(Icons.security, color: Color(0xFF00BFA5)),
      ),
      // Added SingleChildScrollView to fix overflow issues
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      _isRecording ? Icons.mic : Icons.cloud_upload_outlined,
                      size: 64,
                      color: _isRecording ? Colors.redAccent : const Color(0xFF00BFA5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isRecording
                          ? "Recording Audio..."
                          : (_isLoading ? "Analyzing..." : "Ready to Scan"),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Detect potential fraud in calls or audio clips.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: _isRecording ? Icons.stop : Icons.mic,
                      label: _isRecording ? "Stop" : "Record",
                      color: _isRecording ? Colors.redAccent : const Color(0xFF00BFA5),
                      onTap: _record,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.upload_file,
                      label: "Upload",
                      color: const Color(0xFF3D5A80),
                      onTap: _pickFile,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Results Section
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_predictionResult != null)
                _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    bool isScam = _predictionResult!.toLowerCase().contains("scam") ||
        _predictionResult!.toLowerCase().contains("fraud");
    bool isError = _predictionResult!.toLowerCase().contains("error");
    
    Color resultColor;
    IconData resultIcon;

    if (isError) {
      resultColor = Colors.orangeAccent;
      resultIcon = Icons.error_outline;
    } else if (isScam) {
      resultColor = Colors.redAccent;
      resultIcon = Icons.warning_amber_rounded;
    } else {
      resultColor = Colors.greenAccent;
      resultIcon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: resultColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: resultColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(
            resultIcon,
            color: resultColor,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            _predictionResult!,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (_transcript != null && _transcript!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            const Text(
              "Transcript Analysis",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _transcript!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
