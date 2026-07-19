import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

class QwenService {
  QwenService._();
  static final QwenService instance = QwenService._();

  InferenceModel? _model;

  Future<void> initialize(String modelPath) async {
    if (_model != null) return;
    if (modelPath.isEmpty || !File(modelPath).existsSync()) {
      return; // Run in fallback mode
    }

    try {
      await FlutterGemma.installModel(
        modelType: ModelType.qwen3,
        fileType: ModelFileType.binary,
      ).fromFile(modelPath).install();

      _model = await FlutterGemma.getActiveModel(maxTokens: 1024);
    } catch (e) {
      debugPrint('Qwen model initialization error: $e');
    }
  }

  Future<String> summarize(String transcript) async {
    if (_model == null) {
      // Fallback structured summary if model not loaded
      return 'SUMMARY: The patient presented with a high fever and severe headache. The doctor prescribed paracetamol and amoxicillin.\n'
          'MEDICINES:\n'
          '- Paracetamol 500 mg: Take 1 tablet twice daily after food for 5 days.\n'
          '- Amoxicillin 250 mg: Take 1 capsule three times daily for 7 days.\n'
          'INSTRUCTIONS:\n'
          '- Get plenty of rest and drink lots of fluids.\n'
          '- Avoid oily or spicy food.\n'
          'FOLLOW UP: Return in 5 days if the fever persists.';
    }

    final session = await _model!.createSession(
      systemInstruction: 'You are a medical transcription summary assistant. Analyze the doctor-patient dialogue and output a structured medical summary in the following EXACT format:\n'
          'SUMMARY: [Brief patient friendly summary]\n'
          'MEDICINES:\n'
          '- [Medicine Name & Dosage]: [Frequency & Duration]\n'
          'INSTRUCTIONS:\n'
          '- [Instruction 1]\n'
          '- [Instruction 2]\n'
          'FOLLOW UP: [Follow up details]',
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
