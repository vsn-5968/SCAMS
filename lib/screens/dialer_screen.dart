import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'call_screen.dart'; // We will create this next

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
      // Simulate a call with our app's recording feature
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
          flex: 2,
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
          flex: 5,
          child: _buildKeypad(),
        ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0, top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 48), // Placeholder for alignment
              FloatingActionButton.large(
                onPressed: _onCallPressed,
                backgroundColor: Colors.green,
                child: const Icon(Icons.call, size: 36, color: Colors.white),
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
    final List<Map<String, String>> keys = [
      {'number': '1', 'letters': ''}, {'number': '2', 'letters': 'ABC'}, {'number': '3', 'letters': 'DEF'},
      {'number': '4', 'letters': 'GHI'}, {'number': '5', 'letters': 'JKL'}, {'number': '6', 'letters': 'MNO'},
      {'number': '7', 'letters': 'PQRS'}, {'number': '8', 'letters': 'TUV'}, {'number': '9', 'letters': 'WXYZ'},
      {'number': '*', 'letters': ''}, {'number': '0', 'letters': '+'}, {'number': '#', 'letters': ''},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 24,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => _onNumberPressed(keys[index]['number']!),
          borderRadius: BorderRadius.circular(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                keys[index]['number']!,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: Colors.white),
              ),
              if (keys[index]['letters']!.isNotEmpty)
                Text(
                  keys[index]['letters']!,
                  style: const TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 1.5),
                ),
            ],
          ),
        );
      },
    );
  }
}
