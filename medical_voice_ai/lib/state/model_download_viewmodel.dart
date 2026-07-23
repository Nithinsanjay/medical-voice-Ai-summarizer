import 'dart:io';
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
      size: '580 MB',
      description: 'Offline local LLM for generating structured clinical summaries.',
      status: ModelStatus.notDownloaded,
    ),
  ];

  List<ModelInfo> get models => List.unmodifiable(_models);

  Future<void> checkModelsStatus() async {
    // Check Whisper
    final whisperExists = await ModelDownloadService.instance.modelExists('ggml-tiny.bin') || 
                          File(await LocalSttService.instance.getWhisperModelPath()).existsSync();
    
    if (_models[0].status != ModelStatus.downloading) {
      _models[0].status = whisperExists ? ModelStatus.installed : ModelStatus.notDownloaded;
      _models[0].progress = whisperExists ? 1.0 : 0.0;
    }

    // Check Qwen
    final qwenExists = await ModelDownloadService.instance.modelExists('qwen3_0_6b.litertlm') || 
                       await ModelDownloadService.instance.modelExists('qwen3_0_6b.bin');
    
    if (_models[1].status != ModelStatus.downloading) {
      _models[1].status = qwenExists ? ModelStatus.installed : ModelStatus.notDownloaded;
      _models[1].progress = qwenExists ? 1.0 : 0.0;
    }

    notifyListeners();

    // Auto-initialize services if files are present
    if (whisperExists) {
      LocalSttService.instance.initialize();
    }
    if (qwenExists) {
      QwenService.instance.initialize();
    }
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
      url = 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin?download=true';
    } else {
      fileName = 'qwen3_0_6b.litertlm';
      url = 'https://huggingface.co/litert-community/Qwen3-0.6B/resolve/main/Qwen3-0.6B.litertlm';
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

  Future<void> removeModel(int index) async {
    final model = _models[index];
    final fileName = index == 0 ? 'ggml-tiny.bin' : 'qwen3_0_6b.litertlm';
    final filePath = await ModelDownloadService.instance.getModelFilePath(fileName);
    final file = File(filePath);
    
    if (await file.exists()) {
      await file.delete();
    }
    
    // Also check for .bin if it was renamed
    if (index == 1) {
      final binPath = await ModelDownloadService.instance.getModelFilePath('qwen3_0_6b.bin');
      final binFile = File(binPath);
      if (await binFile.exists()) {
        await binFile.delete();
      }
    }

    model.status = ModelStatus.notDownloaded;
    model.progress = 0.0;
    notifyListeners();
  }
}
