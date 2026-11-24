import 'package:flutter/material.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/routing/route_paths.dart';
import 'package:aqd_admin/features/auth/domain/admin_user.dart';

/// Permission area of the screens that only a full-access admin may open.
const fullAccessOnly = 'admins';

/// One entry of the sidebar. The shell, the breadcrumbs and the router all
/// read this list, so adding a module means adding one line here.
///
/// [module] is the permission area (same names as the server). Null means
/// every admin may open it; [fullAccessOnly] means full-access admins only.
class NavItem {
  const NavItem({required this.path, required this.icon, required this.label, this.module});

  final String path;
  final IconData icon;
  final String Function(AppLocalizations l10n) label;
  final String? module;

  bool allowedFor(AdminUser? user) {
    if (user == null) return false;
    if (module == null) return true;
    if (module == fullAccessOnly) return user.fullAccess;
    return user.can(module!);
  }
}

final List<NavItem> navItems = [
  NavItem(path: RoutePaths.dashboard, icon: Icons.space_dashboard_outlined, label: (l) => l.navDashboard, module: 'dashboard'),
  NavItem(path: RoutePaths.users, icon: Icons.people_outline, label: (l) => l.navUsers, module: 'users'),
  NavItem(path: RoutePaths.lawyerVerifications, icon: Icons.verified_user_outlined, label: (l) => l.navLawyerVerifications, module: 'lawyers'),
  NavItem(path: RoutePaths.lawyers, icon: Icons.gavel_outlined, label: (l) => l.navLawyers, module: 'lawyers'),
  NavItem(path: RoutePaths.companies, icon: Icons.business_outlined, label: (l) => l.navCompanies, module: 'companies'),
  NavItem(path: RoutePaths.consultations, icon: Icons.video_camera_front_outlined, label: (l) => l.navConsultations, module: 'consultations'),
  NavItem(path: RoutePaths.contracts, icon: Icons.description_outlined, label: (l) => l.navContracts, module: 'contracts'),
  NavItem(path: RoutePaths.contractTemplates, icon: Icons.article_outlined, label: (l) => l.navContractTemplates, module: 'contractTemplates'),
  NavItem(path: RoutePaths.govProcedures, icon: Icons.account_balance_outlined, label: (l) => l.navGovProcedures, module: 'govProcedures'),
  NavItem(path: RoutePaths.notifications, icon: Icons.notifications_none, label: (l) => l.navNotifications, module: 'notifications'),
  NavItem(path: RoutePaths.admins, icon: Icons.admin_panel_settings_outlined, label: (l) => l.navAdmins, module: fullAccessOnly),
  NavItem(path: RoutePaths.audit, icon: Icons.history_outlined, label: (l) => l.navAudit, module: 'audit'),
  NavItem(path: RoutePaths.settings, icon: Icons.settings_outlined, label: (l) => l.navSettings),
];

/// The sidebar entries this admin may open.
List<NavItem> navItemsFor(AdminUser? user) => [for (final item in navItems) if (item.allowedFor(user)) item];

/// The nav item a location belongs to (`/users/123` belongs to `/users`).
NavItem? navItemFor(String location) {
  for (final item in navItems) {
    if (location == item.path || location.startsWith('${item.path}/')) return item;
  }
  return null;
}
