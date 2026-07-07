import 'package:flutter/material.dart';
import '../utils/constants.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reminders = [
      {'label': 'Paracetamol 500 mg', 'time': '08:00 AM', 'enabled': true},
      {'label': 'Amoxicillin 250 mg', 'time': '02:00 PM', 'enabled': false},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reminders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: ListTile(
              title: Text(reminder['label'] as String),
              subtitle: Text(reminder['time'] as String),
              trailing: Switch(
                value: reminder['enabled'] as bool,
                onChanged: (_) {},
                activeThumbColor: AppColors.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}
