import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._() {
    _flutterTts = FlutterTts();
  }

  static final TtsService instance = TtsService._();
  late final FlutterTts _flutterTts;

  Future<void> speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
