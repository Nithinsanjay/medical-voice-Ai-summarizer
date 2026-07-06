import 'package:flutter/material.dart';
import 'download_screen.dart';

class ModelsScreen extends StatelessWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Models')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Installed Model',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: Color(0xFF5B22C4)),
              title: const Text('Qwen-3 0.6B'),
              subtitle: const Text('Connected · Ready to use'),
              trailing: TextButton(
                onPressed: () {},
                child: const Text('Disconnect'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Available Models',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _ModelCard(
            name: 'Qwen-3 0.6B',
            size: '0.6 GB',
            status: 'Connected',
            buttonLabel: 'Details',
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          _ModelCard(
            name: 'Gemma-3a 2.6B',
            size: '2.6 GB',
            status: 'Available',
            buttonLabel: 'Download',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const DownloadScreen()));
            },
          ),
          const SizedBox(height: 12),
          _ModelCard(
            name: 'Phi-3 5.8B',
            size: '5.8 GB',
            status: 'Available',
            buttonLabel: 'Download',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const DownloadScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({
    required this.name,
    required this.size,
    required this.status,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String name;
  final String size;
  final String status;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$size · $status',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            ElevatedButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
