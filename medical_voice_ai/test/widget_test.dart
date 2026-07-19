import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medical_voice_ai/pages/summary_screen.dart';

void main() {
  testWidgets('summary screen renders structured prescription sections',
      (WidgetTester tester) async {
    const rawSummary = '''
SUMMARY: Patient reports fever and headache.
MEDICINES:
- Paracetamol 500 mg: Twice daily after food.
INSTRUCTIONS:
- Drink fluids.
FOLLOW UP: Return after 5 days.
''';

    await tester.pumpWidget(
      const MaterialApp(
        home: SummaryScreen(
          transcript: 'Doctor and patient transcript',
          rawSummary: rawSummary,
          patientName: 'Test Patient',
        ),
      ),
    );

    expect(find.text('Clinical Summary'), findsOneWidget);
    expect(find.text('Patient reports fever and headache.'), findsOneWidget);
    expect(find.text('Prescribed Medicines'), findsOneWidget);
    expect(find.text('Paracetamol 500 mg'), findsOneWidget);
    expect(find.text('Twice daily after food.'), findsOneWidget);
    expect(find.text('Follow Up'), findsOneWidget);
    expect(find.text('Return after 5 days.'), findsOneWidget);
  });
}
