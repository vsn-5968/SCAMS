import 'package:flutter/material.dart';
import 'incoming_call_screen.dart';

class DialerScreen extends StatefulWidget {
  const DialerScreen({super.key});

  @override
  State<DialerScreen> createState() => _DialerScreenState();
}

class _DialerScreenState extends State<DialerScreen> {
  String _phoneNumber = "";

  void _onKeyPress(String value) {
    setState(() {
      if (_phoneNumber.length < 15) {
        _phoneNumber += value;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_phoneNumber.isNotEmpty) {
        _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
      }
    });
  }

  void _makeCall() {
    if (_phoneNumber.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IncomingCallScreen(
            callerName: "Unknown Number",
            callerNumber: _phoneNumber,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Display Area
        SizedBox(
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _phoneNumber,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (_phoneNumber.isNotEmpty)
                const Text(
                  "Add to Contacts",
                  style: TextStyle(color: Color(0xFF00BFA5), fontSize: 14),
                ),
            ],
          ),
        ),
        const Spacer(),
        // Number Pad
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              _buildRow(["1", "2", "3"]),
              const SizedBox(height: 20),
              _buildRow(["4", "5", "6"]),
              const SizedBox(height: 20),
              _buildRow(["7", "8", "9"]),
              const SizedBox(height: 20),
              _buildRow(["*", "0", "#"]),
            ],
          ),
        ),
        const Spacer(),
        // Action Buttons
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 60), // Placeholder for symmetry
              FloatingActionButton(
                onPressed: _makeCall,
                backgroundColor: const Color(0xFF00BFA5),
                child: const Icon(Icons.call, size: 30),
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: _onBackspace,
                icon: const Icon(Icons.backspace_outlined, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: values.map((val) => _buildNumberButton(val)).toList(),
    );
  }

  Widget _buildNumberButton(String val) {
    return GestureDetector(
      onTap: () => _onKeyPress(val),
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            val,
            style: const TextStyle(fontSize: 28, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
