import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/welcome_screen.dart';

/// Signed-out visitors now start on the welcome page. Auth tests that exercise
/// the login/registration screens call this right after the first
/// `pumpAndSettle` to open the login screen the way a visitor would.
Future<void> openLoginFromGuestHome(WidgetTester tester) async {
  GoRouter.of(tester.element(find.byType(WelcomeScreen))).go(RoutePaths.login);
  await tester.pumpAndSettle();
}
