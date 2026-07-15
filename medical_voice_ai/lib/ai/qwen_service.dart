import 'dart:io';

import 'package:flutter_gemma/flutter_gemma.dart';

class QwenService {
  QwenService._();
  static final QwenService instance = QwenService._();

  InferenceModel? _model;
  InferenceChat? _chat;

  Future<void> initialize(String modelPath) async {
    if (_model != null) return;
    _model = await FlutterGemma.loadModel(modelPath);
    _chat = await _model!.createChat(
      systemInstruction: 'You are a medical transcription summary assistant.',
    );
  }

  Future<String> summarize(String transcript) async {
    if (_chat == null) {
      throw Exception('Qwen model not initialized');
    }

    await _chat!.addQuery(Message.text(text: transcript, isUser: true));
    final response = await _chat!.generateChatResponse();
    if (response is TextResponse) {
      return response.token;
    }
    return 'Unable to generate summary.';
  }

  Future<void> close() async {
    await _chat?.close();
    _model = null;
  }
}
