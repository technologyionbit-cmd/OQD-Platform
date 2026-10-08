import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aqd_ionbit/app.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/locale_controller.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/consultation_room/data/datasources/consultation_room_data_source_provider.dart';
import 'package:aqd_ionbit/features/consultation_room/data/datasources/consultation_room_mock_data_source.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_data_source_provider.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_mock_data_source.dart';
import 'package:aqd_ionbit/features/contracts/data/datasources/contracts_data_source_provider.dart';
import 'package:aqd_ionbit/features/contracts/data/datasources/contracts_mock_data_source.dart';
import 'package:aqd_ionbit/features/gov_documents/data/datasources/gov_documents_data_source_provider.dart';
import 'package:aqd_ionbit/features/gov_documents/data/datasources/gov_documents_mock_data_source.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_data_source_provider.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_mock_data_source.dart';
import 'package:aqd_ionbit/features/notifications/data/datasources/notifications_data_source_provider.dart';
import 'package:aqd_ionbit/features/notifications/data/datasources/notifications_mock_data_source.dart';
import 'test_doubles.dart';
export 'test_doubles.dart' show MockAuthRepository, MockTokenManager;

/// Overrides [LocaleController.build] so a test can pin the locale
/// directly instead of driving the language-toggle UI to get there.
class FixedLocaleController extends LocaleController {
  FixedLocaleController(this._locale);
  final Locale _locale;

  @override
  Locale build() => _locale;
}

const testClient = AuthUser(id: 'u_client', fullName: 'Client User', email: 'client@aqd.test', phone: '+962791234567', role: UserRole.client, phoneVerified: true);
const testLawyer = AuthUser(id: 'u_lawyer', fullName: 'Lawyer User', email: 'lawyer@aqd.test', phone: '+962791234567', role: UserRole.lawyer, phoneVerified: true);
const testCompany = AuthUser(id: 'u_company', fullName: 'Company User', email: 'company@aqd.test', phone: '+962791234567', role: UserRole.company, phoneVerified: true);
const _testTokens = AuthTokens(accessToken: 'access', refreshToken: 'refresh');

class RoleTestHarness {
  RoleTestHarness(this.container, this.repository);

  final ProviderContainer container;
  final MockAuthRepository repository;
}

/// Pumps `AqdApp` already logged in as [user]. Pass [size]/[locale] to pin
/// the viewport/language for a responsive or locale-specific assertion;
/// omitted, the test just gets the default test surface and Arabic.
Future<RoleTestHarness> pumpAuthenticatedApp(
  WidgetTester tester, {
  required AuthUser user,
  Size? size,
  Locale locale = const Locale('ar'),
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  SharedPreferences.setMockInitialValues({'prefs.onboarding_seen': true});
  final prefs = await SharedPreferences.getInstance();

  final repository = MockAuthRepository();
  final tokenManager = MockTokenManager();
  when(tokenManager.loadFromStorage).thenAnswer((_) async => null);
  when(() => tokenManager.current).thenReturn(null);
  when(
    () => repository.login(phone: any(named: 'phone'), password: any(named: 'password')),
  ).thenAnswer((_) async => Result.success((user: user, tokens: _testTokens)));
  when(repository.restoreSession).thenAnswer((_) async => const Result.success(null));
  when(repository.logout).thenAnswer((_) async {});

  final container = ProviderContainer(
    overrides: [
      appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
      authRepositoryProvider.overrideWithValue(repository),
      // These features talk to the real API; screens under test get the
      // seeded in-memory data instead.
      consultationRoomRemoteDataSourceProvider.overrideWithValue(ConsultationRoomMockDataSource()),
      consultationsRemoteDataSourceProvider.overrideWithValue(ConsultationsMockDataSource()),
      contractsRemoteDataSourceProvider.overrideWithValue(ContractsMockDataSource()),
      govDocumentsRemoteDataSourceProvider.overrideWithValue(GovDocumentsMockDataSource()),
      lawyersRemoteDataSourceProvider.overrideWithValue(LawyersMockDataSource()),
      notificationsRemoteDataSourceProvider.overrideWithValue(NotificationsMockDataSource()),
      tokenManagerProvider.overrideWithValue(tokenManager),
      localeControllerProvider.overrideWith(() => FixedLocaleController(locale)),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const AqdApp()));
  await tester.pumpAndSettle();
  await container.read(authControllerProvider.notifier).login(phone: user.phone!, password: 'Password123');
  await tester.pumpAndSettle();
  // The landing shell's tabs each kick off their own mock-latency fetches
  // (contracts/documents/team/consultations/...) — flush those explicitly
  // rather than relying on `pumpAndSettle` to catch every last one, since a
  // bare `Future.delayed` timer doesn't always keep it looping.
  await tester.pump(const Duration(milliseconds: 700));

  return RoleTestHarness(container, repository);
}
