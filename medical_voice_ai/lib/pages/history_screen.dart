import 'package:flutter/material.dart';
import '../data/models/consultation.dart';
import '../utils/helpers.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final consultations = <Consultation>[];

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: consultations.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = consultations[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: ListTile(
              title: Text(item.chiefComplaint),
              subtitle: Text('${formatDate(item.dateTime)} • ${item.patientName}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}
