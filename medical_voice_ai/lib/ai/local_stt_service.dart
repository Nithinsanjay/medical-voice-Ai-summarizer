import 'dart:io';
import 'package:whisper_ggml_plus/whisper_ggml_plus.dart';
import 'model_download_service.dart';

class LocalSttService {
  LocalSttService._();
  static final LocalSttService instance = LocalSttService._();

  final WhisperController _whisperController = WhisperController();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Check if model needs to be migrated from general models folder to Whisper folder
    final whisperPath = await getWhisperModelPath();
    if (!File(whisperPath).existsSync()) {
      final downloadPath = await ModelDownloadService.instance.getModelFilePath('ggml-tiny.bin');
      if (File(downloadPath).existsSync()) {
        final whisperDir = Directory(whisperPath).parent;
        if (!whisperDir.existsSync()) {
          await whisperDir.create(recursive: true);
        }
        await File(downloadPath).copy(whisperPath);
      }
    }

    await _whisperController.initModel(WhisperModel.tiny);
    _isInitialized = true;
  }

  Future<String> getWhisperModelPath() async {
    return await _whisperController.getPath(WhisperModel.tiny);
  }

  Future<String> transcribe(File recordingFile) async {
    await initialize();

    final path = await _whisperController.getPath(WhisperModel.tiny);
    if (!File(path).existsSync()) {
      throw Exception('Whisper model file (ggml-tiny.bin) not found. Please download it from the Models screen.');
    }

    final result = await _whisperController.transcribe(
      model: WhisperModel.tiny,
      audioPath: recordingFile.path,
    );

    if (result == null || result.transcription.text.isEmpty) {
      throw Exception('Transcription produced no result. Ensure the audio is clear.');
    }

    return result.transcription.text;
  }
}
