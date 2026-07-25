import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'model_download_service.dart';

class QwenService {
  QwenService._();
  static final QwenService instance = QwenService._();

  InferenceModel? _model;
  Completer<void>? _initCompleter;

  String buildSystemInstruction() {
    return '''
You are a professional medical transcription and summarization assistant.
The doctor-patient conversation may be in English, Hindi, Tamil, Telugu, or a code-mixed Indian language.
Your task is to understand the clinical meaning and produce a structured medical summary in English.

IMPORTANT RULES:
- Extract every medically relevant detail, especially medicines, dosages, frequencies, diagnoses, symptoms, vitals, and follow-up instructions.
- Do not omit medicines just because they are spoken in Hindi, Tamil, Telugu, or transliterated form.
- If a medicine name appears in a regional language, preserve it in the MEDICINES section and add the best English translation in brackets when obvious.
- If the transcript is noisy or mixed-language, infer the intended medicine and dosage from context.
- Keep the final summary in English, but preserve regional-language medicine names whenever possible.

Return the answer using this EXACT format:

VITALS:
- [BP, weight, pulse, temperature, or "Not mentioned"]

DIAGNOSIS:
- [Primary diagnosis or impression]

SUMMARY:
- [Short patient-friendly summary of the visit]

MEDICINES:
- [Medicine name and dosage]: [frequency and duration]

FOLLOW UP:
- [Specific follow-up and instructions]
''';
  }

  Future<void> initialize([String? modelPath]) async {
    if (_model != null) return;

    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();

    try {
      // Migrate from .bin to .litertlm if needed
      final oldPath = await ModelDownloadService.instance.getModelFilePath(
        'qwen3_0_6b.bin',
      );
      final newPath = await ModelDownloadService.instance.getModelFilePath(
        'qwen3_0_6b.litertlm',
      );

      if (File(oldPath).existsSync() && !File(newPath).existsSync()) {
        await File(oldPath).rename(newPath);
        debugPrint('Migrated Qwen model from .bin to .litertlm');
      }

      // Check if it's already active in the engine
      try {
        _model = await FlutterGemma.getActiveModel(maxTokens: 1024);
      } catch (e) {
        debugPrint('No active model found or engine not ready: $e');
        _model = null;
      }

      if (_model != null) {
        debugPrint('Qwen model was already active.');
        _initCompleter!.complete();
        return;
      }

      String path = modelPath ?? '';
      if (path.isEmpty) {
        path = newPath;
      }

      if (!File(path).existsSync()) {
        final error =
            'Qwen model file not found at $path. Please download it from the Models screen.';
        debugPrint(error);
        throw Exception(error);
      }

      debugPrint('Initializing Qwen model from $path...');
      await FlutterGemma.installModel(
        modelType: ModelType.qwen3,
        fileType: ModelFileType.litertlm,
      ).fromFile(path).install();

      _model = await FlutterGemma.getActiveModel(maxTokens: 1024);
      if (_model == null) {
        throw Exception(
          'Inference model could not be activated after installation.',
        );
      }
      debugPrint('Qwen model successfully initialized.');
      _initCompleter!.complete();
    } catch (e) {
      debugPrint('Qwen model initialization error: $e');
      _initCompleter!.completeError(e);
      _initCompleter = null; // Allow retry
      rethrow;
    }
  }

  Future<String> summarize(String transcript) async {
    try {
      await initialize();
    } catch (e) {
      throw Exception(
        'Initialization failed: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }

    if (_model == null) {
      throw Exception('Qwen model not initialized. Check model downloads.');
    }

    final session = await _model!.createSession(
      systemInstruction: buildSystemInstruction(),
    );

    try {
      await session.addQueryChunk(
        Message.text(
          text:
              'TRANSCRIPT TO ANALYZE:\n$transcript\n\nPlease follow the format exactly and ensure every medicine mentioned is captured.',
          isUser: true,
        ),
      );
      final response = await session.getResponse();
      return response;
    } finally {
      await session.close();
    }
  }

  Future<void> close() async {
    await _model?.close();
    _model = null;
  }
}
