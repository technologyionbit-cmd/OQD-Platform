import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aqd_ionbit/app.dart';
import 'package:aqd_ionbit/core/localization/locale_controller.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';

class _MockTokenManager extends Mock implements TokenManager {}

void main() {
  late AppPreferences preferences;

  Future<void> pumpFirstLaunch(WidgetTester tester, {List<Locale>? deviceLocales}) async {
    SharedPreferences.setMockInitialValues({});
    preferences = AppPreferences(await SharedPreferences.getInstance());
    final tokenManager = _MockTokenManager();
    when(tokenManager.loadFromStorage).thenAnswer((_) async => null);
    when(() => tokenManager.current).thenReturn(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWithValue(preferences),
          tokenManagerProvider.overrideWithValue(tokenManager),
          if (deviceLocales != null) deviceLocalesProvider.overrideWithValue(deviceLocales),
        ],
        child: const AqdApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  const slide1 = 'مساعدك القانوني في جيبك';
  const slide2 = 'عقود ذكية بدقائق';
  const slide3 = 'تواصل مباشرة مع محامين موثوقين';
  const loginTitle = 'تسجيل الدخول';

  testWidgets('walks through the slides and "Get started" lands on login', (tester) async {
    await pumpFirstLaunch(tester);
    expect(find.text(slide1), findsOneWidget);

    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.text(slide2), findsOneWidget);

    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.text(slide3), findsOneWidget);

    await tester.tap(find.text('ابدأ'));
    await tester.pumpAndSettle();

    expect(find.text(loginTitle), findsOneWidget);
    expect(preferences.hasSeenOnboarding, isTrue);
  });

  testWidgets('Skip lands on login and is hidden on the last slide', (tester) async {
    await pumpFirstLaunch(tester);
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    // Kept in the tree (so the top bar doesn't shift) but not tappable.
    expect(find.text('تخطي').hitTestable(), findsNothing);

    await tester.tap(find.text('ابدأ'));
    await tester.pumpAndSettle();
    expect(find.text(loginTitle), findsOneWidget);
  });

  testWidgets('Skip from the first slide completes onboarding', (tester) async {
    await pumpFirstLaunch(tester);

    await tester.tap(find.text('تخطي'));
    await tester.pumpAndSettle();

    expect(find.text(loginTitle), findsOneWidget);
    expect(preferences.hasSeenOnboarding, isTrue);
  });

  testWidgets('system back returns to the previous slide instead of leaving', (tester) async {
    await pumpFirstLaunch(tester);
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.text(slide2), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text(slide1), findsOneWidget);
  });

  testWidgets('announces the current slide to screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpFirstLaunch(tester);

    expect(find.bySemanticsLabel('الشريحة 1 من 3'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('starts in English on an English device', (tester) async {
    await pumpFirstLaunch(tester, deviceLocales: const [Locale('en', 'US')]);

    expect(find.text('Your legal assistant in your pocket'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
  });

  testWidgets('the language switch changes the language and remembers it', (tester) async {
    await pumpFirstLaunch(tester);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Your legal assistant in your pocket'), findsOneWidget);
    expect(preferences.localeCode, 'en');
  });
}
