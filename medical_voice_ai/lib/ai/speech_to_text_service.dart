import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextService {
  SpeechToTextService._();
  static final SpeechToTextService instance = SpeechToTextService._();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => debugPrint('STT Error: $error'),
        onStatus: (status) => debugPrint('STT Status: $status'),
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('STT Initialization failed: $e');
      return false;
    }
  }

  Future<void> startListening({
    required Function(String) onResult,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    final available = await initialize();
    if (!available) return;

    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      listenFor: listenFor ?? const Duration(minutes: 5),
      pauseFor: pauseFor ?? const Duration(seconds: 10),
      cancelOnError: false,
      partialResults: true,
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
  }
}
