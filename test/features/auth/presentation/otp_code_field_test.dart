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
}
