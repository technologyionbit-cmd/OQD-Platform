import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aqd_ionbit/app/app.dart';
import 'package:aqd_ionbit/core/config/env_config.dart';
import 'package:aqd_ionbit/core/config/environment.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';

class _MockTokenManager extends Mock implements TokenManager {}

Future<void> _pumpApp(WidgetTester tester, {required Map<String, Object> initialPrefs}) async {
  SharedPreferences.setMockInitialValues(initialPrefs);
  final prefs = await SharedPreferences.getInstance();

  // Never exercise the real secure-storage plugin from widget/unit tests —
  // see TokenManager provider override below. This isn't a stand-in for
  // real backend integration (that's AuthMockDataSource's job); it's the
  // standard Riverpod seam for keeping tests off platform channels.
  final tokenManager = _MockTokenManager();
  when(() => tokenManager.loadFromStorage()).thenAnswer((_) async => null);
  when(() => tokenManager.current).thenReturn(null);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        envConfigProvider.overrideWithValue(EnvConfig.forEnvironment(Environment.development)),
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        tokenManagerProvider.overrideWithValue(tokenManager),
      ],
      child: const AqdApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first-ever launch shows onboarding before login', (tester) async {
    await _pumpApp(tester, initialPrefs: {});

    expect(find.text('مساعدك القانوني في جيبك'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsNothing);
  });

  testWidgets('unauthenticated launch after onboarding lands on the login screen', (tester) async {
    await _pumpApp(tester, initialPrefs: {'prefs.onboarding_seen': true});

    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('أهلاً بعودتك! سجل دخولك للمتابعة'), findsOneWidget);
  });
}
