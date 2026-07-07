import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Voice model offline mode'),
          ),
          SwitchListTile(
            value: false,
            onChanged: (_) {},
            title: const Text('Auto-download recommended model'),
          ),
          const SizedBox(height: 24),
          const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About Voice AI'),
            subtitle: Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }
}
