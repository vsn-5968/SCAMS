import 'package:flutter/material.dart';

class RecentsScreen extends StatelessWidget {
  const RecentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final List<Map<String, dynamic>> recentCalls = [
      {'name': 'Scam Likely', 'time': '10:45 AM', 'type': 'missed', 'isScam': true},
      {'name': 'John Doe', 'time': 'Yesterday', 'type': 'outgoing', 'isScam': false},
      {'name': 'Mom', 'time': 'Yesterday', 'type': 'incoming', 'isScam': false},
      {'name': 'Unknown Number', 'time': '2 days ago', 'type': 'incoming', 'isScam': true},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: recentCalls.length,
      itemBuilder: (context, index) {
        final call = recentCalls[index];
        final isMissed = call['type'] == 'missed';
        final isScam = call['isScam'] as bool;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isScam ? Colors.redAccent.withOpacity(0.2) : Colors.greenAccent.withOpacity(0.2),
              child: Icon(
                isScam ? Icons.warning : Icons.person,
                color: isScam ? Colors.redAccent : Colors.greenAccent,
              ),
            ),
            title: Text(
              call['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMissed ? Colors.redAccent : Colors.white,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  _getIconForType(call['type']),
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(call['time']),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.call, color: Color(0xFF00BFA5)),
              onPressed: () {
                // In a real app, this would trigger a call
              },
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'incoming': return Icons.call_received;
      case 'outgoing': return Icons.call_made;
      case 'missed': return Icons.call_missed;
      default: return Icons.call;
    }
  }
}
