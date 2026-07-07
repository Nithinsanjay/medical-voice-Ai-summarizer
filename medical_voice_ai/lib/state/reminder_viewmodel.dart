import 'package:flutter/material.dart';

class ReminderItem {
  ReminderItem({
    required this.title,
    required this.time,
    this.enabled = true,
  });

  final String title;
  final String time;
  bool enabled;
}

class ReminderViewModel extends ChangeNotifier {
  final List<ReminderItem> _reminders = [
    ReminderItem(title: 'Paracetamol 500 mg', time: '08:00 AM'),
    ReminderItem(title: 'Amoxicillin 250 mg', time: '02:00 PM'),
  ];

  List<ReminderItem> get reminders => List.unmodifiable(_reminders);

  void toggleReminder(int index, bool enabled) {
    _reminders[index].enabled = enabled;
    notifyListeners();
  }
}
