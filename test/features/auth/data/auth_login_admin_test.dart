import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/features/auth/data/datasources/auth_remote_data_source_impl.dart';

/// FE-02: the backend can authenticate an `admin`, a role this app has no
/// shell for. The login must end in a typed, localizable refusal and must
/// revoke the session the server just opened.
void main() {
  Dio dioReturning(Map<String, dynamic> loginBody, List<RequestOptions> seen) {
    final dio = Dio(BaseOptions(baseUrl: 'http://test/v1'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          seen.add(options);
          if (options.path == '/auth/login') {
            handler.resolve(Response(requestOptions: options, statusCode: 200, data: loginBody));
          } else {
            handler.resolve(Response(requestOptions: options, statusCode: 204));
          }
        },
      ),
    );
    return dio;
  }

  Map<String, dynamic> sessionFor(String role) => {
    'data': {
      'user': {'id': 'u1', 'fullName': 'X', 'email': 'x@test.com', 'role': role, 'phoneVerified': true},
      'tokens': {'accessToken': 'access', 'refreshToken': 'refresh-1'},
    },
  };

  test('admin login → ForbiddenFailure(unsupportedRole) and the session is revoked via /auth/logout', () async {
    final seen = <RequestOptions>[];
    final source = AuthRemoteDataSourceImpl(dioReturning(sessionFor('admin'), seen));

    await expectLater(
      source.login(phone: '+962790000000', password: 'pw'),
      throwsA(isA<ForbiddenFailure>().having((f) => f.code, 'code', ApiErrorCodes.unsupportedRole)),
    );

    final logout = seen.where((r) => r.path == '/auth/logout').toList();
    expect(logout, hasLength(1));
    expect((logout.single.data as Map)['refreshToken'], 'refresh-1');
  });

  test('a normal client login still succeeds and does not call logout', () async {
    final seen = <RequestOptions>[];
    final source = AuthRemoteDataSourceImpl(dioReturning(sessionFor('client'), seen));

    final result = await source.login(phone: '+962790000000', password: 'pw');

    expect(result.user.role.name, 'client');
    expect(result.tokens.refreshToken, 'refresh-1');
    expect(seen.where((r) => r.path == '/auth/logout'), isEmpty);
  });
}
