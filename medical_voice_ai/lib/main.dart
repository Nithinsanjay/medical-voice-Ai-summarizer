import 'package:flutter/material.dart';
import 'pages/home_screen.dart';
import 'pages/models_screen.dart';
import 'pages/download_screen.dart';

void main() {
  runApp(const VoiceAiApp());
}

class VoiceAiApp extends StatelessWidget {
  const VoiceAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B22C4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const VoiceAiRoot(),
    );
  }
}

class VoiceAiRoot extends StatefulWidget {
  const VoiceAiRoot({super.key});

  @override
  State<VoiceAiRoot> createState() => _VoiceAiRootState();
}

class _VoiceAiRootState extends State<VoiceAiRoot> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    const HomeScreen(),
    const HistoryScreen(),
    const ModelsScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_filled), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.storage), label: 'Models'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DownloadScreen()),
                );
              },
              label: const Text('Download Model'),
              icon: const Icon(Icons.cloud_download),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: const Center(
        child: Text(
          'Review past consultations here.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Application Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Enable offline voice model'),
          ),
          SwitchListTile(
            value: false,
            onChanged: (_) {},
            title: const Text('Auto-download recommended model'),
          ),
        ],
      ),
    );
  }
}
