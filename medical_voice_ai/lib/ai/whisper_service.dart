class WhisperService {
  WhisperService._();

  static final WhisperService instance = WhisperService._();

  Future<String> transcribeAudio(String audioPath) async {
    await Future.delayed(const Duration(seconds: 1));

    return '''Doctor: How are you feeling now?
Patient: I have fever and headache since yesterday.
Doctor: I will prescribe some medicines.''';
  }
}
