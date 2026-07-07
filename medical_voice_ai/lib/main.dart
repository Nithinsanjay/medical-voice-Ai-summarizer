import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_screen.dart';
import 'pages/history_screen.dart';
import 'pages/models_screen.dart';
import 'pages/settings_screen.dart';
import 'pages/download_screen.dart';
import 'state/consultation_viewmodel.dart';
import 'state/history_viewmodel.dart';
import 'state/model_download_viewmodel.dart';
import 'state/settings_viewmodel.dart';
import 'state/reminder_viewmodel.dart';

void main() {
  runApp(const VoiceAiApp());
}

class VoiceAiApp extends StatelessWidget {
  const VoiceAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConsultationViewModel()),
        ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        ChangeNotifierProvider(create: (_) => ModelDownloadViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => ReminderViewModel()),
      ],
      child: MaterialApp(
        title: 'Voice AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B22C4), brightness: Brightness.light),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F5FF),
        ),
        home: const VoiceAiRoot(),
      ),
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
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DownloadScreen()));
              },
              label: const Text('Download LLM'),
              icon: const Icon(Icons.cloud_download),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
