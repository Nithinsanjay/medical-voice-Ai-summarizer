import 'dart:io';

import 'package:whisper_ggml_plus/whisper_ggml_plus.dart';
import 'package:path_provider/path_provider.dart';

class LocalSttService {
  LocalSttService._();
  static final LocalSttService instance = LocalSttService._();

  Whisper? _whisper;

  Future<void> initialize(String modelPath) async {
    _whisper ??= await Whisper.create(modelPath);
  }

  Future<String> transcribe(File recordingFile) async {
    if (_whisper == null) {
      throw Exception('Whisper model not initialized');
    }
    final result = await _whisper!.transcribeAudio(recordingFile.path);
    return result.text;
  }
}
