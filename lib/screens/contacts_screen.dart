import 'package:flutter/material.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final List<Map<String, String>> contacts = [
      {'name': 'Alice', 'number': '+1 123-456-7890'},
      {'name': 'Bob', 'number': '+1 234-567-8901'},
      {'name': 'Charlie', 'number': '+1 345-678-9012'},
      {'name': 'David', 'number': '+1 456-789-0123'},
      {'name': 'Eve', 'number': '+1 567-890-1234'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Text(
                contact['name']![0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(contact['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(contact['number']!),
            trailing: IconButton(
              icon: const Icon(Icons.call, color: Colors.grey),
              onPressed: () {
                // In a real app, this would trigger a call
              },
            ),
          ),
        );
      },
    );
  }
}
