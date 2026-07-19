import 'package:flutter/material.dart';
import '../data/models/model_info.dart';
import '../ai/model_download_service.dart';
import '../ai/local_stt_service.dart';
import '../ai/qwen_service.dart';

class ModelDownloadViewModel extends ChangeNotifier {
  ModelDownloadViewModel() {
    checkModelsStatus();
  }

  final List<ModelInfo> _models = [
    ModelInfo(
      name: 'Whisper STT (Tiny)',
      size: '75 MB',
      description: 'Offline speech-to-text model for transcribing doctor-patient conversations.',
      status: ModelStatus.notDownloaded,
    ),
    ModelInfo(
      name: 'Qwen 3 0.6B LLM',
      size: '380 MB',
      description: 'Offline local LLM for generating structured clinical summaries.',
      status: ModelStatus.notDownloaded,
    ),
  ];

  List<ModelInfo> get models => List.unmodifiable(_models);

  Future<void> checkModelsStatus() async {
    // Check Whisper
    final whisperExists = await ModelDownloadService.instance.modelExists('ggml-tiny.bin');
    _models[0].status = whisperExists ? ModelStatus.installed : ModelStatus.notDownloaded;
    _models[0].progress = whisperExists ? 1.0 : 0.0;

    // Check Qwen
    final qwenExists = await ModelDownloadService.instance.modelExists('qwen2.5-0.5b-instruct-gpu-int4.bin');
    _models[1].status = qwenExists ? ModelStatus.installed : ModelStatus.notDownloaded;
    _models[1].progress = qwenExists ? 1.0 : 0.0;

    notifyListeners();
  }

  Future<void> downloadModel(int index) async {
    final model = _models[index];
    if (model.status == ModelStatus.installed || model.status == ModelStatus.downloading) return;

    model.status = ModelStatus.downloading;
    model.progress = 0.0;
    notifyListeners();

    String fileName;
    String url;

    if (index == 0) {
      fileName = 'ggml-tiny.bin';
      url = 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin';
    } else {
      fileName = 'qwen2.5-0.5b-instruct-gpu-int4.bin';
      url = 'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct/resolve/main/qwen2.5-0.5b-instruct-gpu-int4.bin';
    }

    await ModelDownloadService.instance.downloadModel(
      fileName,
      url,
      onProgress: (progress) {
        model.progress = progress;
        notifyListeners();
      },
      onCompleted: () async {
        model.status = ModelStatus.installed;
        model.progress = 1.0;
        notifyListeners();
        // Initialize services if successfully downloaded
        if (index == 0) {
          await LocalSttService.instance.initialize();
        } else {
          final filePath = await ModelDownloadService.instance.getModelFilePath(fileName);
          await QwenService.instance.initialize(filePath);
        }
      },
      onError: (error) {
        model.status = ModelStatus.notDownloaded;
        model.progress = 0.0;
        notifyListeners();
        debugPrint('Download error for $fileName: $error');
      },
    );
  }
}
