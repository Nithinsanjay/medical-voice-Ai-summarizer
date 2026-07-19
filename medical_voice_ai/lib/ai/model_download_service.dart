import 'dart:io';
import 'package:background_downloader/background_downloader.dart';
import 'package:path_provider/path_provider.dart';

class ModelDownloadService {
  ModelDownloadService._();

  static final ModelDownloadService instance = ModelDownloadService._();

  Future<String> getModelsDirectory() async {
    final dir = await getApplicationSupportDirectory();
    final modelsDir = Directory('${dir.path}/models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir.path;
  }

  Future<String> getModelFilePath(String modelName) async {
    final baseDir = await getModelsDirectory();
    return '$baseDir/$modelName';
  }

  Future<bool> modelExists(String modelName) async {
    final filePath = await getModelFilePath(modelName);
    return File(filePath).exists();
  }

  Future<void> downloadModel(
    String modelName,
    String url, {
    required void Function(double progress) onProgress,
    required void Function() onCompleted,
    required void Function(String error) onError,
  }) async {
    try {
      final task = DownloadTask(
        url: url,
        filename: modelName,
        baseDirectory: BaseDirectory.applicationSupport,
        directory: 'models',
        updates: Updates.statusAndProgress,
      );

      final result = await FileDownloader().download(
        task,
        onProgress: (progress) {
          if (progress >= 0.0 && progress <= 1.0) {
            onProgress(progress);
          }
        },
      );

      if (result.status == TaskStatus.complete) {
        onCompleted();
      } else {
        onError('Download failed with status: ${result.status}');
      }
    } catch (e) {
      onError(e.toString());
    }
  }
}
