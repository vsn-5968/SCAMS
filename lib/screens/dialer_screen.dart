import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'call_screen.dart'; 

class DialerScreen extends StatefulWidget {
  const DialerScreen({super.key});

  @override
  State<DialerScreen> createState() => _DialerScreenState();
}

class _DialerScreenState extends State<DialerScreen> {
  String _dialedNumber = '';

  void _onNumberPressed(String number) {
    if (_dialedNumber.length < 15) {
      setState(() => _dialedNumber += number);
    }
  }

  void _onDeletePressed() {
    if (_dialedNumber.isNotEmpty) {
      setState(() => _dialedNumber = _dialedNumber.substring(0, _dialedNumber.length - 1));
    }
  }

  void _onCallPressed() {
    if (_dialedNumber.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(contactName: "Unknown", phoneNumber: _dialedNumber),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display Number
        Expanded(
          flex: 3, // Increased flex slightly to give more room for number
          child: Center(
            child: Text(
              _dialedNumber.isEmpty ? 'Dial a number' : _dialedNumber,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w300,
                color: _dialedNumber.isEmpty ? Colors.grey : Colors.white,
              ),
            ),
          ),
        ),
        
        // Keypad
        Expanded(
          flex: 8, // Keypad takes most of the space
          child: _buildKeypad(),
        ),

        // Action Buttons
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 48), // Placeholder for alignment
              FloatingActionButton(
                onPressed: _onCallPressed,
                backgroundColor: Colors.green,
                child: const Icon(Icons.call, size: 28, color: Colors.white),
              ),
              IconButton(
                onPressed: _onDeletePressed,
                icon: const Icon(Icons.backspace_outlined),
                iconSize: 32,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeypad() {
    final List<List<Map<String, String>>> rows = [
      [{'number': '1', 'letters': ''}, {'number': '2', 'letters': 'ABC'}, {'number': '3', 'letters': 'DEF'}],
      [{'number': '4', 'letters': 'GHI'}, {'number': '5', 'letters': 'JKL'}, {'number': '6', 'letters': 'MNO'}],
      [{'number': '7', 'letters': 'PQRS'}, {'number': '8', 'letters': 'TUV'}, {'number': '9', 'letters': 'WXYZ'}],
      [{'number': '*', 'letters': ''}, {'number': '0', 'letters': '+'}, {'number': '#', 'letters': ''}],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: rows.map((row) {
          return Expanded(
            child: Row(
              children: row.map((key) {
                return Expanded(
                  child: InkWell(
                    onTap: () => _onNumberPressed(key['number']!),
                    customBorder: const CircleBorder(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          key['number']!,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: Colors.white),
                        ),
                        if (key['letters']!.isNotEmpty)
                          Text(
                            key['letters']!,
                            style: const TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 1.5),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
