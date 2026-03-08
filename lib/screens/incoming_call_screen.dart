import 'package:flutter/material.dart';
import 'dart:math';
import 'call_screen.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callerName;
  final String callerNumber;

  IncomingCallScreen({
    super.key,
    this.callerName = "Unknown Number",
    String? callerNumber,
  }) : callerNumber = callerNumber ?? _generateRandomIndianNumber();

  static String _generateRandomIndianNumber() {
    final random = Random();
    String digits = "";
    for (int i = 0; i < 10; i++) {
      digits += random.nextInt(10).toString();
    }
    return "+91 $digits";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              const Color(0xFF0D1B2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Caller Info
              Column(
                children: [
                  const SizedBox(height: 60),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[800],
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: const Icon(Icons.person, size: 80, color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    callerName,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    callerNumber,
                    style: const TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Incoming Call...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context,
                      color: Colors.redAccent,
                      icon: Icons.call_end,
                      label: "Decline",
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildActionButton(
                      context,
                      color: Colors.greenAccent,
                      icon: Icons.call,
                      label: "Accept",
                      onTap: () {
                        Navigator.pop(context); // Close incoming screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // FIX: Use the correct parameters for CallScreen
                            builder: (context) => CallScreen(
                              channelName: "simulated_call_channel", // Use a test channel for simulated calls
                              contactName: callerName,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required Color color, required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Icon(icon, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
