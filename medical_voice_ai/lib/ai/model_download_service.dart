import 'dart:io';
import 'package:flutter/foundation.dart';
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
        retries: 5,
        allowPause: true,
      );

      debugPrint('Starting download for $modelName from $url');

      final result = await FileDownloader().download(
        task,
        onProgress: (progress) {
          if (progress >= 0.0 && progress <= 1.0) {
            onProgress(progress);
          }
        },
      );

      switch (result.status) {
        case TaskStatus.complete:
          debugPrint('Download complete: $modelName');
          onCompleted();
          break;
        case TaskStatus.canceled:
          onError('Download canceled');
          break;
        case TaskStatus.failed:
          onError('Download failed: ${result.status}');
          break;
        case TaskStatus.notFound:
          onError('Model file not found on server');
          break;
        default:
          onError('Download stopped: ${result.status}');
          break;
      }
    } catch (e) {
      debugPrint('Exception during download: $e');
      onError(e.toString());
    }
  }

  Future<void> cancelAllDownloads() async {
    await FileDownloader().cancelTasksWithIds(
        await FileDownloader().allTaskIds());
  }
}
