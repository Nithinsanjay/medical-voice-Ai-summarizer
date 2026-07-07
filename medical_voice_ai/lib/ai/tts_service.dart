class TtsService {
  TtsService._();

  static final TtsService instance = TtsService._();

  Future<void> speak(String text) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
