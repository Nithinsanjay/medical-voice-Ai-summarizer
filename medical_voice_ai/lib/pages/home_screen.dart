import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'recording_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.notifications_none))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(AppStrings.appSubtitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          const _ActiveModelCard(),
          const SizedBox(height: 20),
          _PrimaryActionCard(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RecordingScreen()))),
          const SizedBox(height: 20),
          const _ActionGrid(),
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.memory, color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Gemma 3n E2B', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Ready to use', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Disconnect')),
          ],
        ),
      ),
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
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Start New Consultation', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Text('Begin recording a medical consultation and generate a structured summary.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, minimumSize: const Size.fromHeight(56)),
              child: const Text('Start New Consultation'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.mic_none, 'label': 'Record'},
      {'icon': Icons.history, 'label': 'History'},
      {'icon': Icons.download, 'label': 'Download LLM'},
      {'icon': Icons.notifications, 'label': 'Reminders'},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3.2,
      children: items.map((item) {
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {},
          child: Ink(
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(item['icon'] as IconData, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600))),
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
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(Icons.lightbulb_outline, color: AppColors.primary),
            SizedBox(width: 12),
            Expanded(child: Text('Tip: Speak clearly in a quiet environment for better transcription accuracy.')),
          ],
        ),
      ),
    );
  }
}
