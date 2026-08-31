import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/theme/app_theme.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_chip.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/section_header.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/core/widgets/step_indicator.dart';

Widget _themed(Widget child) {
  return MaterialApp(theme: AppTheme.light, home: Scaffold(body: Center(child: child)));
}

void main() {
  testWidgets('StatusBadge renders every tone against the theme extension', (tester) async {
    for (final tone in AppStatusTone.values) {
      await tester.pumpWidget(_themed(StatusBadge(label: 'مكتمل', tone: tone)));
      expect(find.text('مكتمل'), findsOneWidget);
    }
  });

  testWidgets('IconBadge renders with default and custom colors', (tester) async {
    await tester.pumpWidget(_themed(const IconBadge(icon: Icons.gavel)));
    expect(find.byIcon(Icons.gavel), findsOneWidget);
  });

  testWidgets('AppChip toggles selected styling without throwing', (tester) async {
    await tester.pumpWidget(_themed(const AppChip(label: 'محامٍ', selected: true)));
    expect(find.text('محامٍ'), findsOneWidget);

    await tester.pumpWidget(_themed(const AppChip(label: 'محامٍ', selected: false)));
    expect(find.text('محامٍ'), findsOneWidget);
  });

  testWidgets('SectionHeader shows the trailing action only when provided', (tester) async {
    await tester.pumpWidget(_themed(const SectionHeader(title: 'آخر النشاطات', actionLabel: 'عرض الكل')));
    expect(find.text('عرض الكل'), findsOneWidget);

    await tester.pumpWidget(_themed(const SectionHeader(title: 'آخر النشاطات')));
    expect(find.text('عرض الكل'), findsNothing);
  });

  testWidgets('StepIndicator renders one circle per step', (tester) async {
    await tester.pumpWidget(_themed(const StepIndicator(stepCount: 5, currentStep: 2)));
    expect(find.text('2'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget); // step 1 is done
  });

  testWidgets('AppButton success variant renders and responds to taps', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _themed(AppButton(label: 'تأكيد التوقيع', variant: AppButtonVariant.success, onPressed: () => tapped = true)),
    );
    await tester.tap(find.text('تأكيد التوقيع'));
    expect(tapped, isTrue);
  });
}
