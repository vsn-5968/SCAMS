import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultScreen extends StatefulWidget {
  final String audioPath;

  const ResultScreen({super.key, required this.audioPath});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isLoading = true;
  String? _predictionResult;
  String? _transcript;
  // Use the same backend URL
  final String _backendUrl = 'https://scam-app.onrender.com/audio/upload';

  @override
  void initState() {
    super.initState();
    _analyzeAudio();
  }

  Future<void> _analyzeAudio() async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_backendUrl));
      request.files.add(await http.MultipartFile.fromPath('file', widget.audioPath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        bool isScam = data['is_scam'] == true;
        String transcript = data['transcript'] ?? "No transcript available.";

        setState(() {
          _predictionResult = isScam ? "Potential Scam Call Detected" : "Audio Seems Safe.\nNot Scam Call";
          _transcript = transcript;
          _isLoading = false;
        });
      } else {
        setState(() {
          _predictionResult = "Error: Server returned ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _predictionResult = "Error: Connection failed";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text("Call Analysis"),
        backgroundColor: const Color(0xFF0D1B2A),
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Analyzing Call Recording...", style: TextStyle(color: Colors.white)),
                ],
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildResultContent(),
              ),
      ),
    );
  }

  Widget _buildResultContent() {
    // Check specifically for "Potential Scam" to avoid matching "Not Scam Call"
    bool isScam = _predictionResult?.toLowerCase().contains("potential scam") ?? false;
    bool isError = _predictionResult?.toLowerCase().contains("error") ?? false;
    Color color = isError ? Colors.orange : (isScam ? Colors.redAccent : Colors.greenAccent);
    IconData icon = isError ? Icons.error : (isScam ? Icons.warning : Icons.check_circle);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: color),
        const SizedBox(height: 24),
        Text(
          _predictionResult ?? "Unknown",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (_transcript != null) ...[
          const Text("Transcript:", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _transcript!,
              style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Back to Dialer"),
        ),
      ],
    );
  }
}
