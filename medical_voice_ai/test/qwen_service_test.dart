import 'package:flutter_test/flutter_test.dart';
import 'package:medical_voice_ai/ai/qwen_service.dart';

void main() {
  group('QwenService prompt construction', () {
    test('includes multilingual and medicine preservation instructions', () {
      final prompt = QwenService.instance.buildSystemInstruction();

      expect(prompt, contains('Hindi'));
      expect(prompt, contains('Tamil'));
      expect(prompt, contains('Telugu'));
      expect(prompt, contains('medicine'));
      expect(prompt, contains('Do not omit'));
    });
  });
}
