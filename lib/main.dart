import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// --- API SERVICE ---
class ApiService {
  // UPDATED: Using your specific Wi-Fi IPv4 address.
  // Make sure your phone and laptop are connected to the SAME Wi-Fi network (AJCE).
  static const String baseUrl = 'http://192.168.39.52:8000';

  // Fetch News from Backend
  static Future<List<dynamic>?> fetchNews() async {
    try {
      print("Fetching news from $baseUrl/news...");
      final response = await http.get(Uri.parse('$baseUrl/news'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Backend error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching news: $e");
    }
    return null;
  }

  // Send Chat Message to Backend
  static Future<String?> sendChatMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"message": message}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response']; // Adjust key based on your FastAPI return structure
      }
    } catch (e) {
      print("Error sending message: $e");
    }
    return null;
  }
}

// --- MOCK DATA & MODELS ---
class Game {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget gameScreen;

  Game({required this.title, required this.description, required this.icon, required this.color, required this.gameScreen});
}

final List<Game> cybersecurityGames = [
  Game(title: "Phishing Frenzy", description: "Spot the fake emails before you get hooked!", icon: Icons.phishing, color: Colors.teal, gameScreen: const PhishingFrenzyGame()),
  Game(title: "Password Fortress", description: "Create and test the strength of your passwords.", icon: Icons.security, color: Colors.blueAccent, gameScreen: const PasswordFortressGame()),
  Game(title: "Data Breach Dash", description: "React quickly to secure the servers from hackers.", icon: Icons.speed, color: Colors.orange, gameScreen: const DataBreachDashGame()),
  Game(title: "Firewall Defender", description: "Configure the firewall to block incoming threats.", icon: Icons.shield, color: Colors.redAccent, gameScreen: const FirewallDefenderGame()),
];

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

// --- MAIN APP ---

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData.dark().copyWith(
      primaryColor: const Color(0xFF00BFA5),
      scaffoldBackgroundColor: const Color(0xFF0D1B2A),
      cardColor: const Color(0xFF1B263B),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D1B2A),
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1B263B),
        selectedItemColor: Color(0xFF00BFA5),
        unselectedItemColor: Colors.grey,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00BFA5),
        secondary: Color(0xFF3D5A80),
        background: Color(0xFF0D1B2A),
        surface: Color(0xFF1B263B),
      ),
    );

    return MaterialApp(
      title: 'Secure Dialer',
      theme: darkTheme,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Secure Dialer'),
          bottom: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3.0,
            tabs: const [
              Tab(icon: Icon(Icons.home), text: "Home"),
              Tab(icon: Icon(Icons.article), text: "News"),
              Tab(icon: Icon(Icons.games), text: "Games"),
              Tab(icon: Icon(Icons.assistant), text: "Assistant"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HomeTab(),
            AwarenessTab(),
            GamesTab(),
            ChatbotTab(),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            indicatorColor: Theme.of(context).colorScheme.secondary,
            tabs: const [
              Tab(icon: Icon(Icons.dialpad)),
              Tab(icon: Icon(Icons.history)),
              Tab(icon: Icon(Icons.contacts)),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                DialerTab(),
                RecentsTab(),
                ContactsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- DIALER WIDGET ---
class DialerTab extends StatefulWidget {
  const DialerTab({super.key});
  @override
  _DialerTabState createState() => _DialerTabState();
}

class _DialerTabState extends State<DialerTab> {
  String _dialedNumber = '';

  void _onNumberPressed(String number) {
    setState(() => _dialedNumber += number);
  }

  void _onDeletePressed() {
    if (_dialedNumber.isNotEmpty) {
      setState(() => _dialedNumber = _dialedNumber.substring(0, _dialedNumber.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(
              _dialedNumber.isEmpty ? 'Dial a number' : _dialedNumber,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: _dialedNumber.isEmpty ? Colors.grey : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        _buildKeypad(),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact Saved (Mock)')));
            },
            icon: const Icon(Icons.person_add_outlined),
            iconSize: 28,
            color: Colors.white70,
          ),
          FloatingActionButton(
            onPressed: () async {
              if (_dialedNumber.isNotEmpty) {
                await FlutterPhoneDirectCaller.callNumber(_dialedNumber);
              }
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.call, color: Colors.white),
          ),
          IconButton(
            onPressed: _onDeletePressed,
            icon: const Icon(Icons.backspace_outlined),
            iconSize: 28,
            color: Colors.white70,
          ),
        ],
      ),
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.4),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => _onNumberPressed(keys[index]['number']!),
          borderRadius: BorderRadius.circular(100),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(keys[index]['number']!, style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w300)),
                if (keys[index]['letters']!.isNotEmpty) Text(keys[index]['letters']!, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RecentsTab extends StatelessWidget {
  const RecentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final List<Map<String, dynamic>> recentCalls = [
      {'name': 'John Doe', 'time': '10:45 AM', 'type': 'outgoing'},
      {'name': 'Jane Smith', 'time': 'Yesterday', 'type': 'missed'},
      {'name': 'Unknown', 'time': '2 days ago', 'type': 'incoming'},
    ];

    IconData getCallIcon(String type) {
      switch (type) {
        case 'incoming': return Icons.call_received;
        case 'outgoing': return Icons.call_made;
        case 'missed': return Icons.call_missed;
        default: return Icons.call;
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: recentCalls.length,
      itemBuilder: (context, index) {
        final call = recentCalls[index];
        final isMissed = call['type'] == 'missed';
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: ListTile(
            leading: Icon(getCallIcon(call['type']), color: isMissed ? Colors.redAccent : Theme.of(context).primaryColor),
            title: Text(call['name'], style: TextStyle(fontWeight: FontWeight.bold, color: isMissed ? Colors.redAccent : Colors.white)),
            subtitle: Text(call['time']),
            trailing: IconButton(icon: const Icon(Icons.call, color: Colors.green), onPressed: () {}),
          ),
        );
      },
    );
  }
}

class ContactsTab extends StatelessWidget {
  const ContactsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final List<Map<String, String>> contacts = [
      {'name': 'Alice', 'number': '+1 123-456-7890'}, {'name': 'Bob', 'number': '+1 234-567-8901'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Text(contact['name']![0], style: const TextStyle(color: Colors.white)),
            ),
            title: Text(contact['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(contact['number']!),
            trailing: IconButton(icon: const Icon(Icons.call, color: Colors.white70), onPressed: () {}),
          ),
        );
      },
    );
  }
}

class AwarenessTab extends StatefulWidget {
  const AwarenessTab({super.key});

  @override
  State<AwarenessTab> createState() => _AwarenessTabState();
}

class _AwarenessTabState extends State<AwarenessTab> {
  // Fallback data (Shows if backend is offline)
  List<dynamic> _newsItems = [
    {
      'title': 'ALERT: "Digital Arrest" Scams Rising',
      'subtitle': 'Scammers posing as Police/CBI. (Fallback)',
      'icon': Icons.videocam_off,
      'source': 'Cyber Crime Portal',
      'url': 'https://cybercrime.gov.in'
    },
    {
      'title': 'Fake "FedEx" Parcel Scam',
      'subtitle': 'Calls claiming illegal items. (Fallback)',
      'icon': Icons.local_shipping,
      'source': 'Consumer Awareness',
      'url': 'https://www.google.com'
    },
  ];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() => _isLoading = true);
    final apiNews = await ApiService.fetchNews();
    if (apiNews != null && apiNews.isNotEmpty) {
      setState(() {
        _newsItems = apiNews;
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Latest Security News', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(onPressed: _fetchNews, icon: const Icon(Icons.refresh))
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _newsItems.length,
              itemBuilder: (context, index) {
                final item = _newsItems[index];
                // Handle safe data access
                final title = item['title'] ?? 'No Title';
                final subtitle = item['subtitle'] ?? item['description'] ?? 'Read more...';
                final source = item['source'] ?? 'News';
                final urlStr = item['url'] ?? 'https://google.com';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                      child: const Icon(Icons.security, color: Colors.white),
                    ),
                    title: Text(title),
                    subtitle: Text("$source - $subtitle"),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () async {
                        final Uri url = Uri.parse(urlStr);
                        try {
                          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                            throw Exception('Could not launch');
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open link.')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GamesTab extends StatelessWidget {
  const GamesTab({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: cybersecurityGames.length,
          itemBuilder: (context, index) {
            final game = cybersecurityGames[index];
            return Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => game.gameScreen),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(game.icon, size: 48, color: game.color),
                      const SizedBox(height: 12),
                      Text(game.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          game.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ChatbotTab extends StatefulWidget {
  const ChatbotTab({super.key});
  @override
  _ChatbotTabState createState() => _ChatbotTabState();
}

class _ChatbotTabState extends State<ChatbotTab> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hello! I'm your security assistant. Connected to Backend!", isUser: false),
  ];
  bool _isSending = false;

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userText = _controller.text;
    setState(() {
      _messages.add(ChatMessage(text: userText, isUser: true));
      _isSending = true;
    });
    _controller.clear();

    // Send to Backend
    final response = await ApiService.sendChatMessage(userText);

    setState(() {
      _isSending = false;
      if (response != null) {
        _messages.add(ChatMessage(text: response, isUser: false));
      } else {
        _messages.add(ChatMessage(text: "Server error. Is it running?", isUser: false));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return Align(
                alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: message.isUser ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(message.text),
                ),
              );
            },
          ),
        ),
        if (_isSending) const Padding(padding: EdgeInsets.all(8.0), child: LinearProgressIndicator()),
        _buildMessageComposer(),
      ],
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Ask about a security threat...",
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

// --- PLACEHOLDER GAME SCREENS ---
class PhishingFrenzyGame extends StatelessWidget { const PhishingFrenzyGame({super.key}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('Phishing Frenzy')), body: const Center(child: Text('Game Screen'))); } }
class PasswordFortressGame extends StatelessWidget { const PasswordFortressGame({super.key}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('Password Fortress')), body: const Center(child: Text('Game Screen'))); } }
class DataBreachDashGame extends StatelessWidget { const DataBreachDashGame({super.key}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('Data Breach Dash')), body: const Center(child: Text('Game Screen'))); } }
class FirewallDefenderGame extends StatelessWidget { const FirewallDefenderGame({super.key}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('Firewall Defender')), body: const Center(child: Text('Game Screen'))); } }