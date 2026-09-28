import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_theme.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/consultation_room/data/datasources/consultation_room_data_source_provider.dart';
import 'package:aqd_ionbit/features/consultation_room/data/datasources/consultation_room_mock_data_source.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_data_source_provider.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_mock_data_source.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_remote_data_source.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/availability_slot.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';
import 'package:aqd_ionbit/features/messages/data/datasources/messages_data_source_provider.dart';
import 'package:aqd_ionbit/features/messages/data/datasources/messages_mock_data_source.dart';
import 'package:aqd_ionbit/features/messages/presentation/screens/chat_room_screen.dart';

/// Shared fixtures for `ChatRoomScreen` widget tests, split across several
/// files (one file = one isolate for `flutter test`) rather than one giant
/// file — keeps each run's Timer/AnimationController lifecycle isolated per
/// file instead of accumulating across a long list of `testWidgets`.
const testClient = AuthUser(id: 'u_client_1', fullName: 'أحمد العتيبي', email: 'client@aqd.test', role: UserRole.client, emailVerified: true);
const testLawyer = AuthUser(id: 'u_lawyer_1', fullName: 'سارة المطيري', email: 'lawyer@aqd.test', role: UserRole.lawyer, emailVerified: true);

/// Fixes `authControllerProvider`'s state to a known user without needing a
/// mock repository — mirrors `FixedLocaleController` in
/// `test/support/role_test_harness.dart` for the same reason (pin state,
/// skip unrelated boilerplate).
class FixedAuthController extends AuthController {
  FixedAuthController(this._user);
  final AuthUser? _user;

  @override
  Future<AuthUser?> build() async => _user;
}

/// A single-consultation fake, letting tests control `scheduledAt`/`status`
/// precisely (e.g. "scheduled right now" so the session is immediately
/// joinable) without depending on `ConsultationsMockDataSource`'s seed data
/// being scheduled relative to real wall-clock time. Only the methods the
/// chat room screen's flow actually exercises are meaningfully implemented.
class SingleConsultationDataSource implements ConsultationsRemoteDataSource {
  SingleConsultationDataSource(this._consultation);
  Consultation _consultation;

  @override
  Future<List<Consultation>> getConsultations() async => [_consultation];

  @override
  Future<Consultation> getConsultationById(String id) async => _consultation;

  @override
  Future<List<AvailabilitySlot>> getAvailability(String lawyerId) async => [];

  @override
  Future<AvailabilitySlot> addAvailabilitySlot({required String lawyerId, required DateTime start, required DateTime end}) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeAvailabilitySlot(String slotId) async {}

  @override
  Future<Consultation> bookConsultation({
    required String lawyerId,
    required String lawyerName,
    required ConsultationType type,
    required DateTime scheduledAt,
    required double price,
    required String notes,
  }) => throw UnimplementedError();

  @override
  Future<Consultation> acceptRequest(String id) => throw UnimplementedError();

  @override
  Future<Consultation> rejectRequest(String id, {String? reason}) => throw UnimplementedError();

  @override
  Future<Consultation> cancel(String id, {String? reason}) async {
    _consultation = _consultation.copyWith(status: ConsultationStatus.cancelled);
    return _consultation;
  }

  @override
  Future<Consultation> reschedule({required String id, required DateTime newDateTime}) => throw UnimplementedError();

  @override
  Future<Consultation> complete(String id) async {
    _consultation = _consultation.copyWith(status: ConsultationStatus.completed);
    return _consultation;
  }

  @override
  Future<Consultation> markMissed(String id) async {
    _consultation = _consultation.copyWith(status: ConsultationStatus.missed);
    return _consultation;
  }

  @override
  Future<Consultation> markFailed(String id) async {
    _consultation = _consultation.copyWith(status: ConsultationStatus.failed);
    return _consultation;
  }
}

class FakeImagePickerPlatform extends ImagePickerPlatform {
  FakeImagePickerPlatform({this.result, this.shouldThrow = false});

  final XFile? result;
  final bool shouldThrow;

  @override
  Future<XFile?> getImageFromSource({required ImageSource source, ImagePickerOptions options = const ImagePickerOptions()}) async {
    if (shouldThrow) throw StateError('picker unavailable');
    return result;
  }
}

Consultation readyConsultation({String id = 'cons_test_ready', ConsultationStatus status = ConsultationStatus.confirmed}) {
  return Consultation(
    id: id,
    lawyerId: 'lwr_seed_1',
    lawyerName: 'سارة المطيري',
    clientName: 'أحمد العتيبي',
    type: ConsultationType.written,
    status: status,
    scheduledAt: DateTime.now(),
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    price: 100,
  );
}

Future<ProviderContainer> pumpChatRoom(
  WidgetTester tester, {
  required AuthUser user,
  required String consultationId,
  ConsultationsRemoteDataSource? consultationsDataSource,
  MessagesMockDataSource? messagesDataSource,
  Locale locale = const Locale('en'),
}) async {
  final container = ProviderContainer(
    overrides: [
      authControllerProvider.overrideWith(() => FixedAuthController(user)),
      consultationsRemoteDataSourceProvider.overrideWithValue(consultationsDataSource ?? ConsultationsMockDataSource()),
      messagesRemoteDataSourceProvider.overrideWithValue(messagesDataSource ?? MessagesMockDataSource()),
      consultationRoomRemoteDataSourceProvider.overrideWithValue(ConsultationRoomMockDataSource()),
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: RoutePaths.chatRoomFor(RoutePaths.clientBase, consultationId),
    routes: [
      GoRoute(
        path: RoutePaths.clientChatRoomPattern,
        builder: (context, state) => ChatRoomScreen(consultationId: state.pathParameters['id']!),
      ),
      GoRoute(path: RoutePaths.clientConsultationDetailsPattern, builder: (context, state) => const Scaffold(body: Text('details screen'))),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.light,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
      ),
    ),
  );
  // Let the consultation/session/messages providers' mock-latency fetches
  // resolve, and the waiting -> ready -> active auto-chain run to completion
  // (each hop — getConsultations/getSession/join/connect/getMessages — has
  // its own simulated latency, so this needs several rounds).
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
  return container;
}
