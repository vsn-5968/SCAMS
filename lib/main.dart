import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:permission_handler/permission_handler.dart'; // Not needed at top level for now
import 'screens/dialer_screen.dart';
import 'screens/recents_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/incoming_call_screen.dart'; // Import the new screen

void main() {
  runApp(const ScamDetectorApp());
}

class ScamDetectorApp extends StatelessWidget {
  const ScamDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrueGuard',
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
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DialerScreen(),
    const RecentsScreen(),
    const ContactsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrueGuard Dialer'),
        centerTitle: true,
        leading: const Icon(Icons.security, color: Color(0xFF00BFA5)),
        actions: [
          // Simulate Incoming Call Button
          IconButton(
            icon: const Icon(Icons.add_call, color: Colors.redAccent),
            tooltip: "Simulate Scam Call",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IncomingCallScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1B263B),
        selectedItemColor: const Color(0xFF00BFA5),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dialpad),
            label: "Keypad",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Recents",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: "Contacts",
          ),
        ],
      ),
    );
  }
}
