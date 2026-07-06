import 'package:flutter/material.dart';

class InitializationScreen extends StatelessWidget {
  const InitializationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Initialization')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Initializing Model',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFFEDE7FE),
              child: Icon(
                Icons.check_circle,
                color: Color(0xFF5B22C4),
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const _InitializationStep(text: 'Verifying files', completed: true),
            const _InitializationStep(
              text: 'Loading tokenizer',
              completed: true,
            ),
            const _InitializationStep(text: 'Loading model', completed: true),
            const _InitializationStep(
              text: 'Preparing runtime',
              completed: false,
            ),
            const _InitializationStep(text: 'Warming up', completed: false),
            const SizedBox(height: 24),
            const Text(
              'This may take a few moments. Please wait.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitializationStep extends StatelessWidget {
  const _InitializationStep({required this.text, required this.completed});

  final String text;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? const Color(0xFF5B22C4) : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: completed ? Colors.black : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
