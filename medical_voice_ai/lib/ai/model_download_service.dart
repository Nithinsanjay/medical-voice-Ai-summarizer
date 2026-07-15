import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:path_provider/path_provider.dart';

class ModelDownloadService {
  ModelDownloadService._();

  static final ModelDownloadService instance = ModelDownloadService._();

  Future<String> getModelsDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${dir.path}/models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir.path;
  }

  Future<String> getModelFilePath(String modelName) async {
    final baseDir = await getModelsDirectory();
    return '$baseDir/$modelName.gguf';
  }

  Future<Task> startModelDownload(String modelName, Uri url) async {
    final filePath = await getModelFilePath(modelName);
    final destination = File(filePath);
    final task = await BackgroundDownloader.instance.download(
      url,
      destination.path,
    );
    task.addListener(
      onProgress: (progress) {
        // progress 0.0 - 1.0
      },
      onComplete: () {},
      onError: (error) {
        // handle error
      },
    );
    return task;
  }

  Future<bool> modelExists(String modelName) async {
    final filePath = await getModelFilePath(modelName);
    return File(filePath).exists();
  }
}
