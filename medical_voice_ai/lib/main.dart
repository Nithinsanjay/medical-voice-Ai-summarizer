import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:provider/provider.dart';
import 'pages/home_screen.dart';
import 'pages/history_screen.dart';
import 'pages/models_screen.dart';
import 'pages/settings_screen.dart';
import 'state/consultation_viewmodel.dart';
import 'state/history_viewmodel.dart';
import 'state/model_download_viewmodel.dart';
import 'state/settings_viewmodel.dart';
import 'state/reminder_viewmodel.dart';
import 'data/database/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(VoiceAiApp(initialization: _initializeApp()));
}

Future<void> _initializeApp() async {
  await FileDownloader().configure(globalConfig: [
    (Config.requestTimeout, const Duration(seconds: 100)),
  ]);
  await FlutterGemma.initialize(inferenceEngines: const [LiteRtLmEngine()]);
  await DatabaseService.instance.initialize();
}

class VoiceAiApp extends StatelessWidget {
  const VoiceAiApp({super.key, required this.initialization});

  final Future<void> initialization;

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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5B22C4),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F5FF),
        ),
        home: _StartupGate(initialization: initialization),
      ),
    );
  }
}

class _StartupGate extends StatelessWidget {
  const _StartupGate({required this.initialization});

  final Future<void> initialization;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return const VoiceAiRoot();
        }

        if (snapshot.hasError) {
          return _StartupScreen(error: snapshot.error.toString());
        }

        return const _StartupScreen();
      },
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen({this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;

    return Scaffold(
      backgroundColor: const Color(0xFF050024),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/medicalvoiceailogo.png',
                  width: 148,
                  height: 148,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Medical Voice AI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasError ? 'Startup failed' : 'Preparing clinical assistant',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),
                if (hasError)
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red.shade100,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  )
                else
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      color: Color(0xFFE65CFF),
                    ),
                  ),
              ],
            ),
          ),
        ),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const HomeScreen(),
      Consumer<HistoryViewModel>(
        builder: (ctx, vm, _) => const HistoryScreen(),
      ),
      const ModelsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_selectedIndex]),
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
    );
  }
}
