import 'dart:async';

import 'package:mocktail/mocktail.dart';

import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/repositories/auth_repository.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/contracts/domain/repositories/contracts_repository.dart';
import 'package:aqd_ionbit/features/documents/domain/repositories/documents_repository.dart';

/// Test doubles shared by many specs — defined once here instead of in
/// each test file.

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenManager extends Mock implements TokenManager {}

class MockContractsRepository extends Mock implements ContractsRepository {}

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

/// Pins `authControllerProvider` to [user] (or signed out) without a mock
/// repository or the login flow.
class FixedAuthController extends AuthController {
  FixedAuthController(this._user);
  final AuthUser? _user;

  @override
  FutureOr<AuthUser?> build() async => _user;
}
