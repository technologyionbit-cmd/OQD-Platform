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

void main() {
  testWidgets('unauthenticated app boot lands on the login screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Never exercise the real secure-storage plugin from widget/unit tests
    // — see TokenManager provider override below. This isn't a stand-in for
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

    // Splash while AuthController resolves the (empty) stored session.
    await tester.pumpAndSettle();

    expect(find.text('عقد'), findsWidgets);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
  });
}
