import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aqd_ionbit/app.dart';
import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/repositories/auth_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'prefs.onboarding_seen': true});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
          authRepositoryProvider.overrideWithValue(repository),
        ],
        child: const AqdApp(),
      ),
    );
  }

  setUp(() => repository = _MockAuthRepository());

  testWidgets('shows the brand and a loader while the session resolves', (tester) async {
    final pending = Completer<Result<AuthUser?>>();
    when(() => repository.restoreSession()).thenAnswer((_) => pending.future);

    await pumpApp(tester);
    await tester.pump();

    expect(find.text('عقد'), findsOneWidget);
    expect(find.text('منصتك القانونية الذكية'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsNothing);

    pending.complete(const Result.success(null));
    await tester.pumpAndSettle();
  });

  testWidgets('stays on splash with a retry when the server is unreachable, then recovers', (tester) async {
    when(() => repository.restoreSession()).thenAnswer((_) async => const Result.failure(NetworkFailure()));

    await pumpApp(tester);
    await tester.pumpAndSettle();

    expect(find.text('تعذّر الاتصال بالشبكة، تحقق من الاتصال بالإنترنت'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsNothing);

    when(() => repository.restoreSession()).thenAnswer((_) async => const Result.success(null));
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.text('تسجيل الدخول'), findsOneWidget);
    verify(() => repository.restoreSession()).called(2);
  });
}
