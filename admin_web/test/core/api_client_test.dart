import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_admin/core/config/app_config.dart';
import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/core/network/api_client.dart';
import 'package:aqd_admin/core/network/session_store.dart';

/// Answers from a handler instead of the network.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(int status, Object body) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

void main() {
  late SessionStore session;
  late FakeAdapter adapter;
  late ApiClient client;
  late int refreshCalls;
  late bool expired;

  setUp(() {
    session = SessionStore()..setAccessToken('old');
    refreshCalls = 0;
    expired = false;
  });

  ApiClient build(ResponseBody Function(RequestOptions) handler, {required bool refreshWorks}) {
    adapter = FakeAdapter(handler);
    final dio = Dio()..httpClientAdapter = adapter;
    client = ApiClient(config: const AppConfig(apiBaseUrl: 'http://api.test/v1'), session: session, dio: dio)
      ..registerSessionHandlers(
        refresher: () async {
          refreshCalls++;
          await Future<void>.delayed(const Duration(milliseconds: 10));
          if (refreshWorks) session.setAccessToken('new');
          return refreshWorks;
        },
        onSessionExpired: () => expired = true,
      );
    return client;
  }

  test('sends the access token, the admin client header and credentials', () async {
    build((_) => json(200, {'data': 1}), refreshWorks: true);

    await client.dio.get<dynamic>('/admin/things');

    final request = adapter.requests.single;
    expect(request.headers['Authorization'], 'Bearer old');
    expect(request.headers['X-Requested-With'], 'aqd-admin');
    expect(request.extra['withCredentials'], true);
  });

  test('never attaches the bearer token to /admin-auth calls', () async {
    build((_) => json(200, {'data': 1}), refreshWorks: true);

    await client.dio.post<dynamic>('/admin-auth/refresh');

    expect(adapter.requests.single.headers.containsKey('Authorization'), isFalse);
  });

  test('on 401 refreshes once and retries with the new token', () async {
    build(
      (options) => options.headers['Authorization'] == 'Bearer new' ? json(200, {'data': 'ok'}) : json(401, {'error': {'message': 'x', 'code': 'UNAUTHORIZED'}}),
      refreshWorks: true,
    );

    final response = await client.dio.get<dynamic>('/admin/things');

    expect(response.statusCode, 200);
    expect(refreshCalls, 1);
    expect(adapter.requests, hasLength(2));
  });

  test('concurrent 401s share a single refresh', () async {
    build(
      (options) => options.headers['Authorization'] == 'Bearer new' ? json(200, {'data': 'ok'}) : json(401, {'error': {'message': 'x', 'code': 'UNAUTHORIZED'}}),
      refreshWorks: true,
    );

    await Future.wait([
      client.dio.get<dynamic>('/admin/a'),
      client.dio.get<dynamic>('/admin/b'),
      client.dio.get<dynamic>('/admin/c'),
    ]);

    expect(refreshCalls, 1);
  });

  test('when the refresh fails the session is expired and the 401 surfaces', () async {
    build((_) => json(401, {'error': {'message': 'x', 'code': 'UNAUTHORIZED'}}), refreshWorks: false);

    final error = await client.dio.get<dynamic>('/admin/things').then<Object>((_) => 'no error').catchError((Object e) => e);

    expect(expired, isTrue);
    expect(mapToFailure(error), isA<UnauthorizedFailure>());
  });

  test('does not loop when the retried call is also 401', () async {
    build((_) => json(401, {'error': {'message': 'x', 'code': 'UNAUTHORIZED'}}), refreshWorks: true);

    await expectLater(client.dio.get<dynamic>('/admin/things'), throwsA(isA<DioException>()));

    expect(refreshCalls, 1);
    expect(adapter.requests, hasLength(2));
  });

  group('mapToFailure', () {
    DioException status(int code, [Object? body, Map<String, List<String>>? headers]) => DioException(
          requestOptions: RequestOptions(path: '/x'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/x'),
            statusCode: code,
            data: body,
            headers: Headers.fromMap(headers ?? {}),
          ),
        );

    test('reads the backend envelope', () {
      final failure = mapToFailure(status(422, {
        'error': {
          'message': 'Validation failed',
          'code': 'VALIDATION_ERROR',
          'errors': {
            'phone': ['bad'],
          },
        },
      }));
      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).fieldErrors['phone'], ['bad']);
      expect(failure.code, 'VALIDATION_ERROR');
    });

    test('maps status codes to failure types', () {
      expect(mapToFailure(status(403)), isA<ForbiddenFailure>());
      expect(mapToFailure(status(404)), isA<NotFoundFailure>());
      expect(mapToFailure(status(409)), isA<ConflictFailure>());
      expect(mapToFailure(status(500)), isA<ServerFailure>());
      final limited = mapToFailure(status(429, null, {'retry-after': ['42']}));
      expect((limited as TooManyRequestsFailure).retryAfterSeconds, 42);
    });

    test('maps connection problems', () {
      expect(
        mapToFailure(DioException(requestOptions: RequestOptions(path: '/x'), type: DioExceptionType.connectionError)),
        isA<NetworkFailure>(),
      );
      expect(
        mapToFailure(DioException(requestOptions: RequestOptions(path: '/x'), type: DioExceptionType.receiveTimeout)),
        isA<TimeoutFailure>(),
      );
    });
  });
}
