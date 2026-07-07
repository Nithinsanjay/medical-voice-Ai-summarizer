import 'package:flutter/material.dart';
import '../utils/constants.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  bool _isRecording = true;
  final Duration _duration = const Duration(minutes: 2, seconds: 34);

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Consultation'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Recording...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 72,
              backgroundColor: Colors.white,
              child: Icon(
                _isRecording ? Icons.mic : Icons.pause,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _duration.toString().split('.').first.substring(2),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              _isRecording ? 'Tap to pause' : 'Paused',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusChip('Doctor', true),
                const SizedBox(width: 12),
                _buildStatusChip('Patient', false),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _toggleRecording,
              icon: Icon(_isRecording ? Icons.pause : Icons.play_arrow),
              label: Text(_isRecording ? 'Pause' : 'Resume'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, bool active) {
    return Chip(
      label: Text(label),
      backgroundColor: active ? AppColors.primary : Colors.grey.shade200,
      labelStyle: TextStyle(color: active ? Colors.white : Colors.black87),
    );
  }
}
