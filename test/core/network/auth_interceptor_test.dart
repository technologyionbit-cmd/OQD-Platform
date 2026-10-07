import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/core/network/auth_session_ports.dart';
import 'package:aqd_ionbit/core/network/interceptors/auth_interceptor.dart';
import 'package:aqd_ionbit/core/security/secure_storage_service.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';

/// Answers 401 to any request not carrying [validToken], 200 otherwise.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.validToken);

  final String validToken;
  final authHeaders = <String?>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final header = options.headers['Authorization'] as String?;
    authHeaders.add(header);
    final ok = header == 'Bearer $validToken';
    return ResponseBody.fromString(
      jsonEncode(ok ? {'data': 'ok'} : {'message': 'Unauthorized'}),
      ok ? 200 : 401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _InMemoryTokenManager extends TokenManager {
  _InMemoryTokenManager(this._tokens) : super(SecureStorageService());

  AuthTokens? _tokens;

  @override
  AuthTokens? get current => _tokens;

  @override
  Future<void> save(AuthTokens tokens) async => _tokens = tokens;
}

void main() {
  const stale = AuthTokens(accessToken: 'stale', refreshToken: 'r1');
  const fresh = AuthTokens(accessToken: 'fresh', refreshToken: 'r2');

  late Dio dio;
  late _FakeAdapter adapter;
  late int refreshCalls;
  late int sessionExpiredCalls;

  void build(Future<RefreshOutcome> Function() refresh) {
    refreshCalls = 0;
    sessionExpiredCalls = 0;
    adapter = _FakeAdapter(fresh.accessToken);
    final tokenManager = _InMemoryTokenManager(stale);
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        tokenManager: tokenManager,
        // Mirrors the RefreshTokenFn contract the auth repository honors:
        // a success has already been persisted by the time it's reported.
        onRefreshToken: () async {
          refreshCalls++;
          final outcome = await refresh();
          if (outcome case RefreshSucceeded(:final tokens)) await tokenManager.save(tokens);
          return outcome;
        },
        onSessionExpired: () => sessionExpiredCalls++,
      ),
    );
  }

  Future<Failure> failureOf(Future<Object?> request) async {
    try {
      await request;
    } catch (error) {
      return const ApiErrorMapper().map(error);
    }
    fail('expected the request to fail');
  }

  test('refreshes once on 401 and retries with the new access token', () async {
    build(() async => const RefreshSucceeded(fresh));

    final response = await dio.get<Map<String, dynamic>>('/me');

    expect(response.statusCode, 200);
    expect(adapter.authHeaders, ['Bearer stale', 'Bearer fresh']);
    expect(refreshCalls, 1);
    expect(sessionExpiredCalls, 0);
  });

  test('coalesces concurrent 401s into a single refresh', () async {
    build(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return const RefreshSucceeded(fresh);
    });

    await Future.wait([dio.get<dynamic>('/a'), dio.get<dynamic>('/b'), dio.get<dynamic>('/c')]);

    expect(refreshCalls, 1);
  });

  test('a rejected refresh ends the session and surfaces the 401', () async {
    build(() async => const RefreshRejected());

    expect(await failureOf(dio.get<dynamic>('/me')), isA<UnauthorizedFailure>());
    expect(sessionExpiredCalls, 1);
  });

  test('an unavailable refresh keeps the session and surfaces a network failure', () async {
    build(() async => const RefreshUnavailable());

    expect(await failureOf(dio.get<dynamic>('/me')), isA<NetworkFailure>());
    expect(sessionExpiredCalls, 0);
  });

  test('a refresh that throws is treated as unavailable, never as a sign-out', () async {
    build(() async => throw StateError('boom'));

    expect(await failureOf(dio.get<dynamic>('/me')), isA<NetworkFailure>());
    expect(sessionExpiredCalls, 0);
  });
}
