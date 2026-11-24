import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_admin/core/routing/app_router.dart';
import 'package:aqd_admin/core/routing/route_paths.dart';

void main() {
  String? redirect(AsyncValue<Object?> auth, String location, {bool isAdmin = true}) =>
      redirectFor(auth: auth, isAdmin: isAdmin, location: location);

  const loading = AsyncLoading<Object?>();
  const signedOut = AsyncData<Object?>(null);
  const signedIn = AsyncData<Object?>('admin');

  test('holds on splash while the session is restored', () {
    expect(redirect(loading, RoutePaths.users), RoutePaths.splash);
    expect(redirect(loading, RoutePaths.splash), isNull);
  });

  test('holds on splash when the server cannot be reached (not signed out)', () {
    const error = AsyncError<Object?>('offline', StackTrace.empty);
    expect(redirect(error, RoutePaths.users), RoutePaths.splash);
    expect(redirect(error, RoutePaths.login), RoutePaths.splash);
  });

  test('signed-out users can only see login', () {
    expect(redirect(signedOut, RoutePaths.users), RoutePaths.login);
    expect(redirect(signedOut, RoutePaths.splash), RoutePaths.login);
    expect(redirect(signedOut, RoutePaths.login), isNull);
  });

  test('signed-in admins leave splash/login/root for the dashboard and keep other routes', () {
    expect(redirect(signedIn, RoutePaths.splash), RoutePaths.dashboard);
    expect(redirect(signedIn, RoutePaths.login), RoutePaths.dashboard);
    expect(redirect(signedIn, '/'), RoutePaths.dashboard);
    expect(redirect(signedIn, RoutePaths.users), isNull);
  });

  test('a signed-in non-admin is sent to the 403 page for every route', () {
    expect(redirect(signedIn, RoutePaths.users, isAdmin: false), RoutePaths.forbidden);
    expect(redirect(signedIn, RoutePaths.dashboard, isAdmin: false), RoutePaths.forbidden);
    expect(redirect(signedIn, RoutePaths.forbidden, isAdmin: false), isNull);
  });
}
