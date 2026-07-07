import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  bool _useOfflineModel = true;
  bool _autoDownloadRecommended = false;

  bool get useOfflineModel => _useOfflineModel;
  bool get autoDownloadRecommended => _autoDownloadRecommended;

  void toggleOfflineModel(bool value) {
    _useOfflineModel = value;
    notifyListeners();
  }

  void toggleAutoDownload(bool value) {
    _autoDownloadRecommended = value;
    notifyListeners();
  }
}
