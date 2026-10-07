import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/features/auth/presentation/widgets/otp_code_field.dart';

void main() {
  testWidgets('aggregates digits typed across the six boxes in order', (tester) async {
    String? code;

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: OtpCodeField(length: 6, onChanged: (value) => code = value))),
    );

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(6));

    for (var i = 0; i < 6; i++) {
      await tester.enterText(fields.at(i), '$i');
      await tester.pump();
    }

    expect(code, '012345');
  });

  testWidgets('spreads a code pasted into the first box over all six', (tester) async {
    String? code;
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: OtpCodeField(length: 6, onChanged: (value) => code = value))),
    );

    await tester.enterText(find.byType(TextField).first, '482910');
    await tester.pump();

    expect(code, '482910');
    for (final (index, digit) in '482910'.split('').indexed) {
      expect(tester.widget<TextField>(find.byType(TextField).at(index)).controller!.text, digit);
    }
  });

  testWidgets('a paste into a later box fills only the boxes that are left', (tester) async {
    String? code;
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: OtpCodeField(length: 6, onChanged: (value) => code = value))),
    );

    await tester.enterText(find.byType(TextField).at(4), '4829');
    await tester.pump();

    expect(code, '48');
  });

  testWidgets('a digit typed into a filled box replaces it', (tester) async {
    String? code;
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: OtpCodeField(length: 6, onChanged: (value) => code = value))),
    );
    final first = find.byType(TextField).first;

    await tester.enterText(first, '3');
    await tester.pump();
    // The caret sits after the old digit, so the new one is last.
    await tester.enterText(first, '35');
    await tester.pump();

    expect(code, '5');
  });
}
