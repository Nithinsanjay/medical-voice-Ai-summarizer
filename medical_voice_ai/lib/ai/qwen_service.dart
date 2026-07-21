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

  Future<void> initialize([String? modelPath]) async {
    if (_model != null) return;
    
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();
    
    try {
      // Migrate from .bin to .litertlm if needed
      final oldPath = await ModelDownloadService.instance.getModelFilePath('qwen3_0_6b.bin');
      final newPath = await ModelDownloadService.instance.getModelFilePath('qwen3_0_6b.litertlm');
      
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
        final error = 'Qwen model file not found at $path. Please download it from the Models screen.';
        debugPrint(error);
        throw Exception(error);
      }

      debugPrint('Initializing Qwen model from $path...');
      await FlutterGemma.installModel(
        modelType: ModelType.qwen3,
        fileType: ModelFileType.binary,
      ).fromFile(path).install();

      _model = await FlutterGemma.getActiveModel(maxTokens: 1024);
      if (_model == null) {
        throw Exception('Inference model could not be activated after installation.');
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
      throw Exception('Initialization failed: ${e.toString().replaceAll('Exception: ', '')}');
    }
    
    if (_model == null) {
      throw Exception('Qwen model not initialized. Check model downloads.');
    }

    final session = await _model!.createSession(
      systemInstruction: 'You are a professional medical transcription assistant. Analyze the doctor-patient dialogue and output a structured medical summary in the following EXACT format:\n\n'
          'VITALS:\n'
          '- [e.g. BP, Weight, Pulse, Temp if mentioned]\n'
          'DIAGNOSIS:\n'
          '- [Clinical diagnosis or impression]\n'
          'SUMMARY:\n'
          '- [Brief patient-friendly summary of the visit]\n'
          'MEDICINES:\n'
          '- [Medicine Name & Dosage]: [Frequency & Duration]\n'
          'FOLLOW UP:\n'
          '- [Specific follow-up date or instructions]',
    );

    try {
      await session.addQueryChunk(Message.text(text: transcript, isUser: true));
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
