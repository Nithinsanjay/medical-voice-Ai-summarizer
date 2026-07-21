import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/settings_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _doctorController = TextEditingController();
  final _clinicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vm = context.read<SettingsViewModel>();
    _doctorController.text = vm.doctorName;
    _clinicController.text = vm.clinicName;
  }

  @override
  Widget build(BuildContext context) {
    final settingsVm = context.watch<SettingsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Doctor Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
            controller: _doctorController,
            decoration: const InputDecoration(
              labelText: 'Doctor Full Name',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => settingsVm.updateDoctorProfile(val, _clinicController.text),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _clinicController,
            decoration: const InputDecoration(
              labelText: 'Clinic / Hospital Name',
              prefixIcon: Icon(Icons.local_hospital_outlined),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => settingsVm.updateDoctorProfile(_doctorController.text, val),
          ),
          const Divider(height: 40),
          const Text('Transcription Engine', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          RadioListTile<SttEngine>(
            title: const Text('Whisper (On-device, Offline)'),
            subtitle: const Text('High accuracy, processes after recording'),
            value: SttEngine.whisper,
            groupValue: settingsVm.preferredSttEngine,
            onChanged: (val) => settingsVm.setSttEngine(val!),
          ),
          RadioListTile<SttEngine>(
            title: const Text('System STT (Real-time)'),
            subtitle: const Text('Lower accuracy, instant results'),
            value: SttEngine.system,
            groupValue: settingsVm.preferredSttEngine,
            onChanged: (val) => settingsVm.setSttEngine(val!),
          ),
          const Divider(height: 32),
          const Text('AI Summary Model', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SwitchListTile(
            value: settingsVm.useOfflineModel,
            onChanged: settingsVm.toggleOfflineModel,
            title: const Text('Voice model offline mode'),
          ),
          SwitchListTile(
            value: settingsVm.autoDownloadRecommended,
            onChanged: settingsVm.toggleAutoDownload,
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
