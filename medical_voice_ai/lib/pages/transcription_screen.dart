import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TranscriptionScreen extends StatelessWidget {
  const TranscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transcription'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Transcription completed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('Doctor: How are you feeling now?'),
                  SizedBox(height: 8),
                  Text('Patient: I have fever and headache since yesterday.'),
                  SizedBox(height: 8),
                  Text('Doctor: I will prescribe some medicines.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(56)),
              child: const Text('Generate Summary'),
            ),
          ],
        ),
      ),
    );
  }
}
