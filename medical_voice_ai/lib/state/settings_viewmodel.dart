import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SttEngine { whisper, system }

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel() {
    _loadSettings();
  }

  bool _useOfflineModel = true;
  bool _autoDownloadRecommended = false;
  SttEngine _preferredSttEngine = SttEngine.whisper;
  String _doctorName = '';
  String _clinicName = '';

  bool get useOfflineModel => _useOfflineModel;
  bool get autoDownloadRecommended => _autoDownloadRecommended;
  SttEngine get preferredSttEngine => _preferredSttEngine;
  String get doctorName => _doctorName;
  String get clinicName => _clinicName;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _doctorName = prefs.getString('doctor_name') ?? '';
    _clinicName = prefs.getString('clinic_name') ?? '';
    _useOfflineModel = prefs.getBool('use_offline') ?? true;
    _autoDownloadRecommended = prefs.getBool('auto_download') ?? false;
    _preferredSttEngine = SttEngine.values[prefs.getInt('stt_engine') ?? 0];
    notifyListeners();
  }

  void toggleOfflineModel(bool value) async {
    _useOfflineModel = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('use_offline', value);
  }

  void toggleAutoDownload(bool value) async {
    _autoDownloadRecommended = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('auto_download', value);
  }

  void setSttEngine(SttEngine engine) async {
    _preferredSttEngine = engine;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('stt_engine', engine.index);
  }

  void updateDoctorProfile(String name, String clinic) async {
    _doctorName = name;
    _clinicName = clinic;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('doctor_name', name);
    prefs.setString('clinic_name', clinic);
  }
}
