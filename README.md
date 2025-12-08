import 'package:flutter/material.dart';

void main() {
runApp(const MyApp());
}

// MyApp is the root widget of the application.
class MyApp extends StatelessWidget {
const MyApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Dialer App',
// The theme is based on the provided image, using a dark navy blue.
theme: ThemeData(
brightness: Brightness.dark,
primaryColor: const Color(0xFF1A234E), // A dark blue shade
scaffoldBackgroundColor: const Color(0xFF1A234E),
cardColor: const Color(0xFF2C3A6A), // A lighter shade for cards
bottomNavigationBarTheme: const BottomNavigationBarThemeData(
backgroundColor: Color(0xFF1A234E),
selectedItemColor: Colors.white,
unselectedItemColor: Colors.white54,
type: BottomNavigationBarType.fixed,
),
appBarTheme: const AppBarTheme(
backgroundColor: Color(0xFF1A234E),
elevation: 0,
titleTextStyle: TextStyle(
color: Colors.white,
fontSize: 20,
fontWeight: FontWeight.bold,
),
iconTheme: IconThemeData(color: Colors.white),
),
textTheme: const TextTheme(
bodyLarge: TextStyle(color: Colors.white),
bodyMedium: TextStyle(color: Colors.white70),
headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
),
),
home: const MainScreen(),
debugShowCheckedModeBanner: false,
);
}
}

// MainScreen is the stateful widget that manages the bottom navigation bar and pages.
class MainScreen extends StatefulWidget {
const MainScreen({super.key});

@override
State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
int _selectedIndex = 0; // Index for the current tab

// List of widgets to display in the body based on the selected tab.
static const List<Widget> _widgetOptions = <Widget>[
DialerTab(),
RecentsTab(),
ContactsTab(),
AwarenessTab(),
];

void _onItemTapped(int index) {
setState(() {
_selectedIndex = index;
});
}

// App bar titles corresponding to each tab.
final List<String> _appBarTitles = [
'Dialer',
'Recents',
'Contacts',
'Awareness'
];

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text(_appBarTitles[_selectedIndex]),
),
body: Center(
child: _widgetOptions.elementAt(_selectedIndex),
),
// The bottom navigation bar for switching between sections.
bottomNavigationBar: BottomNavigationBar(
items: const <BottomNavigationBarItem>[
BottomNavigationBarItem(
icon: Icon(Icons.dialpad),
label: 'Dialer',
),
BottomNavigationBarItem(
icon: Icon(Icons.history),
label: 'Recents',
),
BottomNavigationBarItem(
icon: Icon(Icons.contacts),
label: 'Contacts',
),
BottomNavigationBarItem(
icon: Icon(Icons.campaign),
label: 'Awareness',
),
],
currentIndex: _selectedIndex,
onTap: _onItemTapped,
),
);
}
}

// --- Dialer Tab Widget ---
class DialerTab extends StatefulWidget {
const DialerTab({super.key});

@override
State<DialerTab> createState() => _DialerTabState();
}

class _DialerTabState extends State<DialerTab> {
String _dialedNumber = '';

void _onNumberPressed(String number) {
setState(() {
_dialedNumber += number;
});
}

void _onDeletePressed() {
if (_dialedNumber.isNotEmpty) {
setState(() {
_dialedNumber = _dialedNumber.substring(0, _dialedNumber.length - 1);
});
}
}

@override
Widget build(BuildContext context) {
return SafeArea(
child: Column(
mainAxisAlignment: MainAxisAlignment.end,
children: [
// Display for the number being dialed.
Expanded(
child: Center(
child: Text(
_dialedNumber,
style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w300),
textAlign: TextAlign.center,
),
),
),
// The keypad.
_buildKeypad(),
// Action buttons (call, delete).
Padding(
padding: const EdgeInsets.symmetric(vertical: 20.0),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
const SizedBox(width: 64),
FloatingActionButton(
onPressed: () {
// TODO: Implement call functionality
},
backgroundColor: Colors.green,
child: const Icon(Icons.call, color: Colors.white),
),
IconButton(
onPressed: _onDeletePressed,
icon: const Icon(Icons.backspace_outlined),
iconSize: 32,
color: Colors.white70,
),
],
),
)
],
),
);
}

// Helper widget to build the number pad.
Widget _buildKeypad() {
final List<Map<String, String>> keys = [
{'number': '1', 'letters': ''},
{'number': '2', 'letters': 'ABC'},
{'number': '3', 'letters': 'DEF'},
{'number': '4', 'letters': 'GHI'},
{'number': '5', 'letters': 'JKL'},
{'number': '6', 'letters': 'MNO'},
{'number': '7', 'letters': 'PQRS'},
{'number': '8', 'letters': 'TUV'},
{'number': '9', 'letters': 'WXYZ'},
{'number': '*', 'letters': ''},
{'number': '0', 'letters': '+'},
{'number': '#', 'letters': ''},
];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
      ),
      itemCount: keys.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => _onNumberPressed(keys[index]['number']!),
          borderRadius: BorderRadius.circular(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                keys[index]['number']!,
                style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w300),
              ),
              if (keys[index]['letters']!.isNotEmpty)
                Text(
                  keys[index]['letters']!,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
            ],
          ),
        );
      },
    );
}
}

// --- Recents Tab Widget ---
class RecentsTab extends StatelessWidget {
const RecentsTab({super.key});

@override
Widget build(BuildContext context) {
// Mock data for recent calls.
final List<Map<String, dynamic>> recentCalls = [
{'name': 'John Doe', 'time': '10:45 AM', 'type': 'outgoing'},
{'name': 'Jane Smith', 'time': 'Yesterday', 'type': 'missed'},
{'name': 'Unknown', 'time': '2 days ago', 'type': 'incoming'},
{'name': 'Mom', 'time': '3 days ago', 'type': 'outgoing'},
];

    IconData getCallIcon(String type) {
      switch (type) {
        case 'incoming':
          return Icons.call_received;
        case 'outgoing':
          return Icons.call_made;
        case 'missed':
          return Icons.call_missed;
        default:
          return Icons.call;
      }
    }

    Color getCallColor(String type) {
      return type == 'missed' ? Colors.red : Colors.white;
    }

    return ListView.builder(
      itemCount: recentCalls.length,
      itemBuilder: (context, index) {
        final call = recentCalls[index];
        return ListTile(
          leading: Icon(getCallIcon(call['type']), color: getCallColor(call['type'])),
          title: Text(call['name'], style: TextStyle(color: getCallColor(call['type']))),
          subtitle: Text(call['time']),
          trailing: IconButton(
            icon: const Icon(Icons.call, color: Colors.green),
            onPressed: () {
              // TODO: Implement call functionality
            },
          ),
        );
      },
    );
}
}

// --- Contacts Tab Widget ---
class ContactsTab extends StatelessWidget {
const ContactsTab({super.key});

@override
Widget build(BuildContext context) {
// Mock data for contacts.
final List<Map<String, String>> contacts = [
{'name': 'Alice', 'number': '+1 123-456-7890'},
{'name': 'Bob', 'number': '+1 234-567-8901'},
{'name': 'Charlie', 'number': '+1 345-678-9012'},
{'name': 'David', 'number': '+1 456-789-0123'},
{'name': 'Eve', 'number': '+1 567-890-1234'},
];

    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.white24,
            child: Text(contact['name']![0]),
          ),
          title: Text(contact['name']!),
          subtitle: Text(contact['number']!),
          trailing: IconButton(
            icon: const Icon(Icons.call_outlined, color: Colors.white70),
            onPressed: () {
              // TODO: Implement call functionality
            },
          ),
        );
      },
    );
}
}

// --- Awareness Tab Widget ---
class AwarenessTab extends StatelessWidget {
const AwarenessTab({super.key});

@override
Widget build(BuildContext context) {
// Mock data for awareness news, based on the provided image.
final List<Map<String, dynamic>> newsItems = [
{
'title': 'New UPI Scam Targets Students',
'subtitle': '20:21, 1:04 PM',
'icon': Icons.lock_outline,
},
{
'title': 'Fake Loan Apps Shut Down',
'subtitle': 'Yesterday, 40miny',
'icon': Icons.phone_android,
},
{
'title': 'Telecom Fraud Ring Busteds',
'subtitle': 'Turning Shotdniny',
'icon': Icons.cell_tower,
},
];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Scam News',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          // Urgent notification card.
          Card(
            color: Colors.red.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.red),
            ),
            child: const ListTile(
              leading: Icon(Icons.error, color: Colors.red),
              title: Text(
                'Urgent: New phishing scam reported!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // List of other news items.
          Expanded(
            child: ListView.builder(
              itemCount: newsItems.length,
              itemBuilder: (context, index) {
                final item = newsItems[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white12,
                      child: Icon(item['icon'], color: Colors.white70),
                    ),
                    title: Text(item['title']),
                    subtitle: Text(item['subtitle']),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
}
}
