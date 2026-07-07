import 'package:flutter/material.dart';
import '../data/models/model_info.dart';

class ModelDownloadViewModel extends ChangeNotifier {
  final List<ModelInfo> _models = [
    ModelInfo(
      name: 'Gemma 3n E2B',
      size: '2.45 GB',
      description: 'Lightweight model for mobile medical summarization.',
      status: ModelStatus.installed,
      progress: 1,
    ),
    ModelInfo(
      name: 'Gemma 3a 2.6B',
      size: '3.05 GB',
      description: 'Good balance of accuracy and performance.',
    ),
    ModelInfo(
      name: 'Qwen 3 0.6B',
      size: '1.25 GB',
      description: 'Best for quick local summarization.',
    ),
  ];

  List<ModelInfo> get models => List.unmodifiable(_models);

  void downloadModel(int index) {
    final model = _models[index];
    model.status = ModelStatus.downloading;
    model.progress = 0.12;
    notifyListeners();
  }

  void updateProgress(int index, double progress) {
    _models[index].progress = progress;
    notifyListeners();
  }
}
