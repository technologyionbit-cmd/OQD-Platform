import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_admin/core/layout/admin_shell.dart';
import 'package:aqd_admin/core/routing/deferred_screen.dart';
import 'package:aqd_admin/core/routing/forbidden_screen.dart';
import 'package:aqd_admin/core/routing/nav_items.dart';
import 'package:aqd_admin/core/routing/route_paths.dart';
import 'package:aqd_admin/features/audit/presentation/audit_screen.dart' deferred as audit;
import 'package:aqd_admin/features/admins/presentation/admins_screen.dart' deferred as admins;
import 'package:aqd_admin/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_admin/features/auth/presentation/screens/login_screen.dart';
import 'package:aqd_admin/features/auth/presentation/screens/splash_screen.dart';
import 'package:aqd_admin/features/companies/presentation/companies_screen.dart' deferred as companies;
import 'package:aqd_admin/features/consultations/presentation/consultations_screen.dart' deferred as consultations;
import 'package:aqd_admin/features/contracts/presentation/contracts_screen.dart' deferred as contracts;
import 'package:aqd_admin/features/contract_templates/presentation/contract_template_editor_screen.dart' deferred as template_editor;
import 'package:aqd_admin/features/contract_templates/presentation/contract_templates_screen.dart' deferred as templates;
import 'package:aqd_admin/features/dashboard/presentation/dashboard_screen.dart' deferred as dashboard;
import 'package:aqd_admin/features/gov_procedures/presentation/gov_procedure_editor_screen.dart' deferred as gov_editor;
import 'package:aqd_admin/features/gov_procedures/presentation/gov_procedures_screen.dart' deferred as gov;
import 'package:aqd_admin/features/lawyer_verifications/presentation/lawyer_verifications_screen.dart' deferred as verifications;
import 'package:aqd_admin/features/lawyers/presentation/lawyers_screen.dart' deferred as lawyers;
import 'package:aqd_admin/features/notifications/presentation/notifications_screen.dart' deferred as notifications;
import 'package:aqd_admin/features/settings/presentation/settings_screen.dart' deferred as settings;
import 'package:aqd_admin/features/users/presentation/screens/user_detail_screen.dart' deferred as user_detail;
import 'package:aqd_admin/features/users/presentation/screens/users_screen.dart' deferred as users;

/// Where an auth state sends the user, or null to stay. Pure, so the
/// guard logic is tested without building a router.
///
/// [canOpen] says whether the signed-in admin may open a location (their
/// permissions); a location they may not open goes to [homePath], the
/// first screen they can use.
String? redirectFor({
  required AsyncValue<Object?> auth,
  required bool isAdmin,
  required String location,
  bool Function(String location)? canOpen,
  String homePath = RoutePaths.dashboard,
}) {
  final onSplash = location == RoutePaths.splash;
  final onLogin = location == RoutePaths.login;

  // Still restoring the session, or it could not be checked (offline):
  // hold on the splash screen, never flash the sign-in form.
  if (auth.isLoading || auth.hasError) return onSplash ? null : RoutePaths.splash;

  final user = auth.value;
  if (user == null) return onLogin ? null : RoutePaths.login;

  // Signed in: no reason to see splash or sign-in again.
  if (!isAdmin) return location == RoutePaths.forbidden ? null : RoutePaths.forbidden;
  if (onSplash || onLogin || location == RoutePaths.forbidden || location == '/') return homePath;
  if (canOpen != null && !canOpen(location)) return location == homePath ? null : homePath;
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final user = auth.value;
      final allowed = navItemsFor(user);
      return redirectFor(
        auth: auth,
        isAdmin: user?.isAdmin ?? false,
        location: state.matchedLocation,
        homePath: allowed.isEmpty ? RoutePaths.settings : allowed.first.path,
        canOpen: (location) {
          final item = navItemFor(location);
          return item == null || item.allowedFor(user);
        },
      );
    },
    routes: [
      GoRoute(path: '/', redirect: (_, _) => RoutePaths.dashboard),
      GoRoute(path: RoutePaths.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: RoutePaths.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: RoutePaths.forbidden, builder: (_, _) => const ForbiddenScreen()),
      ShellRoute(
        builder: (context, state, child) => AdminShell(location: state.matchedLocation, child: child),
        routes: [
          _module(RoutePaths.dashboard, dashboard.loadLibrary, (_) => dashboard.DashboardScreen()),
          _module(RoutePaths.users, users.loadLibrary, (_) => users.UsersScreen()),
          GoRoute(
            path: '${RoutePaths.users}/:id',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: DeferredScreen(
                loadLibrary: user_detail.loadLibrary,
                builder: (_) => user_detail.UserDetailScreen(userId: state.pathParameters['id']!),
              ),
            ),
          ),
          _module(RoutePaths.lawyerVerifications, verifications.loadLibrary, (_) => verifications.LawyerVerificationsScreen()),
          _module(RoutePaths.lawyers, lawyers.loadLibrary, (_) => lawyers.LawyersScreen()),
          _module(RoutePaths.companies, companies.loadLibrary, (_) => companies.CompaniesScreen()),
          _module(RoutePaths.consultations, consultations.loadLibrary, (_) => consultations.ConsultationsScreen()),
          _module(RoutePaths.contracts, contracts.loadLibrary, (_) => contracts.ContractsScreen()),
          _module(RoutePaths.contractTemplates, templates.loadLibrary, (_) => templates.ContractTemplatesScreen()),
          GoRoute(
            path: '${RoutePaths.contractTemplates}/new',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: DeferredScreen(loadLibrary: template_editor.loadLibrary, builder: (_) => template_editor.ContractTemplateEditorScreen()),
            ),
          ),
          GoRoute(
            path: '${RoutePaths.contractTemplates}/:id',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: DeferredScreen(
                loadLibrary: template_editor.loadLibrary,
                builder: (_) => template_editor.ContractTemplateEditorScreen(templateId: state.pathParameters['id']),
              ),
            ),
          ),
          _module(RoutePaths.govProcedures, gov.loadLibrary, (_) => gov.GovProceduresScreen()),
          GoRoute(
            path: '${RoutePaths.govProcedures}/:id',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: DeferredScreen(
                loadLibrary: gov_editor.loadLibrary,
                builder: (_) => gov_editor.GovProcedureEditorScreen(procedureId: state.pathParameters['id']!),
              ),
            ),
          ),
          _module(RoutePaths.notifications, notifications.loadLibrary, (_) => notifications.NotificationsScreen()),
          _module(RoutePaths.admins, admins.loadLibrary, (_) => admins.AdminsScreen()),
          _module(RoutePaths.audit, audit.loadLibrary, (_) => audit.AuditScreen()),
          _module(RoutePaths.settings, settings.loadLibrary, (_) => settings.SettingsScreen()),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// One module route. The screen's code is downloaded the first time the
/// route is opened (deferred import), not with the first page load.
GoRoute _module(String path, Future<void> Function() load, WidgetBuilder builder) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: DeferredScreen(loadLibrary: load, builder: builder),
    ),
  );
}
