import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/model_info.dart';
import '../state/model_download_viewmodel.dart';
import '../state/history_viewmodel.dart';
import '../utils/constants.dart';
import 'download_screen.dart';
import 'history_screen.dart';
import 'recording_screen.dart';
import 'reminders_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RemindersScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            AppStrings.appSubtitle,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          const _ActiveModelCard(),
          const SizedBox(height: 20),
          _PrimaryActionCard(
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RecordingScreen())),
          ),
          const SizedBox(height: 20),
          _ActionGrid(
            onRecord: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RecordingScreen())),
            onHistory: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                      create: (_) => HistoryViewModel(),
                      child: const HistoryScreen(),
                    ))),
            onDownload: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                      create: (_) => ModelDownloadViewModel(),
                      child: const DownloadScreen(),
                    ))),
            onReminders: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RemindersScreen())),
          ),
          const SizedBox(height: 24),
          const _TipCard(),
        ],
      ),
    );
  }
}

class _ActiveModelCard extends StatelessWidget {
  const _ActiveModelCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelDownloadViewModel>(
      builder: (context, vm, _) {
        final qwen = vm.models.length > 1 ? vm.models[1] : null;
        final whisper = vm.models.isNotEmpty ? vm.models[0] : null;

        final isReady = qwen?.status == ModelStatus.installed &&
            whisper?.status == ModelStatus.installed;

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 3,
          shadowColor: AppColors.primary.withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isReady
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    isReady ? Icons.memory : Icons.download_outlined,
                    color: isReady ? Colors.green : Colors.orange,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isReady ? 'Qwen 3 0.6B + Whisper' : 'Models Required',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isReady
                            ? '✓ Ready for offline use'
                            : 'Download AI models to get started',
                        style: TextStyle(
                            color: isReady ? Colors.green : Colors.orange,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (!isReady)
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                                  value: context
                                      .read<ModelDownloadViewModel>(),
                                  child: const DownloadScreen(),
                                ))),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary),
                    child: const Text('Download'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.3),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Icon(Icons.mic, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'Start New Consultation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Record a doctor–patient conversation and get an AI-generated prescription summary.',
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Start Recording',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.onRecord,
    required this.onHistory,
    required this.onDownload,
    required this.onReminders,
  });

  final VoidCallback onRecord;
  final VoidCallback onHistory;
  final VoidCallback onDownload;
  final VoidCallback onReminders;

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.mic_none, 'label': 'Record', 'action': onRecord},
      {'icon': Icons.history, 'label': 'History', 'action': onHistory},
      {
        'icon': Icons.download_for_offline_outlined,
        'label': 'Download AI',
        'action': onDownload
      },
      {
        'icon': Icons.notifications_active_outlined,
        'label': 'Reminders',
        'action': onReminders
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3.0,
      children: items.map((item) {
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          elevation: 2,
          shadowColor: Colors.black12,
          child: InkWell(
            onTap: item['action'] as VoidCallback,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(item['icon'] as IconData,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item['label'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade100),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.teal.shade600),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Tip: Speak clearly and in a quiet environment for best transcription accuracy.',
              style: TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
