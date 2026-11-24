import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/network/api_call.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/core/utils/formatters.dart';
import 'package:aqd_admin/core/widgets/confirm_dialog.dart';
import 'package:aqd_admin/core/widgets/page_header.dart';
import 'package:aqd_admin/core/widgets/snacks.dart';
import 'package:aqd_admin/core/widgets/state_views.dart';
import 'package:aqd_admin/core/widgets/status_chip.dart';
import 'package:aqd_admin/features/auth/presentation/providers/auth_controller.dart';

/// Permission areas, in the order they are shown. Same names as the server.
const adminModules = [
  'dashboard',
  'users',
  'lawyers',
  'companies',
  'consultations',
  'contracts',
  'contractTemplates',
  'govProcedures',
  'notifications',
  'audit',
];

/// Areas where there is nothing to change, so only "view" exists.
const viewOnlyModules = {'dashboard', 'audit'};

String moduleLabel(AppLocalizations l, String module) => switch (module) {
      'dashboard' => l.navDashboard,
      'users' => l.navUsers,
      'lawyers' => l.modLawyers,
      'companies' => l.navCompanies,
      'consultations' => l.navConsultations,
      'contracts' => l.navContracts,
      'contractTemplates' => l.navContractTemplates,
      'govProcedures' => l.navGovProcedures,
      'notifications' => l.navNotifications,
      'audit' => l.navAudit,
      _ => module,
    };

class AdminAccount {
  const AdminAccount({required this.id, required this.fullName, required this.email, required this.status, required this.fullAccess, required this.permissions, required this.createdAt, this.phone, this.lastLoginAt});

  factory AdminAccount.fromJson(Map<String, dynamic> json) => AdminAccount(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        status: json['status'] as String,
        fullAccess: json['fullAccess'] as bool,
        permissions: [for (final p in json['permissions'] as List<dynamic>) p as String],
        lastLoginAt: json['lastLoginAt'] == null ? null : DateTime.parse(json['lastLoginAt'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String status;
  final bool fullAccess;
  final List<String> permissions;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  bool get isActive => status == 'active';
}

final adminsProvider = FutureProvider.autoDispose<List<AdminAccount>>((ref) async {
  final response = await apiCall(() => ref.watch(apiClientProvider).dio.get<Map<String, dynamic>>('/admin/admins'));
  return [for (final r in response.data!['data'] as List<dynamic>) AdminAccount.fromJson(r as Map<String, dynamic>)];
});

/// Other staff accounts and what each may do. Only a full-access admin
/// can open this page, and nobody can change their own access here.
class AdminsScreen extends ConsumerWidget {
  const AdminsScreen({super.key});

  Future<void> _toggleActive(BuildContext context, WidgetRef ref, AdminAccount admin) async {
    final l10n = AppLocalizations.of(context);
    if (admin.isActive) {
      final ok = await showConfirmDialog(context, title: l10n.adminDeactivateTitle, message: l10n.adminDeactivateBody(admin.fullName), confirmLabel: l10n.adminDeactivate, destructive: true);
      if (!ok || !context.mounted) return;
    }
    try {
      await apiCall(() => ref.read(apiClientProvider).dio.post<void>('/admin/admins/${admin.id}/${admin.isActive ? 'deactivate' : 'activate'}'));
      ref.invalidate(adminsProvider);
      if (context.mounted) showSuccessSnack(context, admin.isActive ? l10n.adminDeactivated : l10n.adminActivated);
    } on Object catch (error) {
      if (context.mounted) showFailureSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final admins = ref.watch(adminsProvider);
    final me = ref.watch(authControllerProvider).value?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: l10n.navAdmins,
          subtitle: l10n.adminsSubtitle,
          actions: [FilledButton.icon(onPressed: () => showDialog<void>(context: context, builder: (_) => const AdminFormDialog()), icon: const Icon(Icons.person_add_alt_1_outlined), label: Text(l10n.adminAdd))],
        ),
        Expanded(
          child: admins.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(adminsProvider)),
            data: (list) => SingleChildScrollView(
              child: Card(
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text(l10n.colName)),
                      DataColumn(label: Text(l10n.colEmail)),
                      DataColumn(label: Text(l10n.colPhone)),
                      DataColumn(label: Text(l10n.colPermissions)),
                      DataColumn(label: Text(l10n.colStatus)),
                      DataColumn(label: Text(l10n.colLastLogin)),
                      const DataColumn(label: SizedBox.shrink()),
                    ],
                    rows: [
                      for (final a in list)
                        DataRow(cells: [
                          DataCell(Text(a.id == me ? '${a.fullName}  (${l10n.adminYou})' : a.fullName, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(a.email)),
                          DataCell(Text(a.phone ?? '-', textDirection: TextDirection.ltr)),
                          DataCell(StatusChip(label: a.fullAccess ? l10n.adminAccessFull : l10n.adminAccessCount(a.permissions.length), tone: a.fullAccess ? StatusTone.info : StatusTone.neutral)),
                          DataCell(StatusChip(label: a.isActive ? l10n.statusActive : l10n.statusSuspended, tone: a.isActive ? StatusTone.success : StatusTone.warning)),
                          DataCell(Text(a.lastLoginAt == null ? l10n.never : formatDateTime(context, a.lastLoginAt))),
                          DataCell(
                            a.id == me
                                ? const SizedBox.shrink()
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(tooltip: l10n.adminEditAccess, icon: const Icon(Icons.tune, size: 20), onPressed: () => showDialog<void>(context: context, builder: (_) => AdminFormDialog(existing: a))),
                                      IconButton(tooltip: l10n.adminSetPassword, icon: const Icon(Icons.key_outlined, size: 20), onPressed: () => showDialog<void>(context: context, builder: (_) => _PasswordDialog(admin: a))),
                                      IconButton(
                                        tooltip: a.isActive ? l10n.adminDeactivate : l10n.adminActivate,
                                        icon: Icon(a.isActive ? Icons.block : Icons.check_circle_outline, size: 20),
                                        onPressed: () => _toggleActive(context, ref, a),
                                      ),
                                    ],
                                  ),
                          ),
                        ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Create an admin, or change what an existing one may do. [existing]
/// is null when creating.
class AdminFormDialog extends ConsumerStatefulWidget {
  const AdminFormDialog({super.key, this.existing});

  final AdminAccount? existing;

  @override
  ConsumerState<AdminFormDialog> createState() => _AdminFormDialogState();
}

class _AdminFormDialogState extends ConsumerState<AdminFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.fullName);
  late final _email = TextEditingController(text: widget.existing?.email);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  final _password = TextEditingController();
  late bool _full = widget.existing?.fullAccess ?? false;

  /// module -> 0 none, 1 view, 2 manage
  late final Map<String, int> _levels = {
    for (final m in adminModules)
      m: (widget.existing?.permissions.contains('$m.manage') ?? false)
          ? 2
          : (widget.existing?.permissions.contains('$m.view') ?? false)
              ? 1
              : 0,
  };
  bool _saving = false;

  bool get _isNew => widget.existing == null;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> get _permissions => [
        for (final m in adminModules) ...[
          if ((_levels[m] ?? 0) >= 1) '$m.view',
          if ((_levels[m] ?? 0) == 2) '$m.manage',
        ],
      ];

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final dio = ref.read(apiClientProvider).dio;
    final access = {'fullAccess': _full, 'permissions': _full ? <String>[] : _permissions};
    try {
      if (_isNew) {
        await apiCall(() => dio.post<void>('/admin/admins', data: {'fullName': _name.text.trim(), 'email': _email.text.trim(), 'phone': _phone.text.trim(), 'password': _password.text, ...access}));
      } else {
        await apiCall(() => dio.put<void>('/admin/admins/${widget.existing!.id}/access', data: access));
      }
      ref.invalidate(adminsProvider);
      if (mounted) {
        Navigator.of(context).pop();
        showSuccessSnack(context, _isNew ? l10n.adminCreated : l10n.adminAccessSaved);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        showFailureSnack(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    String? required(String? v) => (v ?? '').trim().isEmpty ? l10n.fieldRequired : null;

    return AlertDialog(
      title: Text(_isNew ? l10n.adminAdd : '${l10n.adminEditAccess}: ${widget.existing!.fullName}'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isNew) ...[
                  TextFormField(controller: _name, decoration: InputDecoration(labelText: l10n.colName), validator: required),
                  const SizedBox(height: 12),
                  TextFormField(controller: _email, textDirection: TextDirection.ltr, decoration: InputDecoration(labelText: l10n.colEmail), validator: (v) => (v ?? '').contains('@') ? null : l10n.fieldRequired),
                  const SizedBox(height: 12),
                  TextFormField(controller: _phone, textDirection: TextDirection.ltr, decoration: InputDecoration(labelText: l10n.colPhone, helperText: l10n.adminPhoneHelp), validator: required),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.adminPassword, helperText: l10n.adminPasswordHelp),
                    validator: (v) => _strongPassword(v ?? '') ? null : l10n.adminPasswordHelp,
                  ),
                  const Divider(height: 28),
                ],
                SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(l10n.adminFullAccessToggle), subtitle: Text(l10n.adminFullAccessHelp), value: _full, onChanged: (v) => setState(() => _full = v)),
                if (!_full) ...[
                  const SizedBox(height: 8),
                  Text(l10n.adminPermissions, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  for (final m in adminModules)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(moduleLabel(l10n, m))),
                          SegmentedButton<int>(
                            showSelectedIcon: false,
                            style: const ButtonStyle(visualDensity: VisualDensity.compact),
                            segments: [
                              ButtonSegment(value: 0, label: Text(l10n.permNone)),
                              ButtonSegment(value: 1, label: Text(l10n.permView)),
                              if (!viewOnlyModules.contains(m)) ButtonSegment(value: 2, label: Text(l10n.permManage)),
                            ],
                            selected: {_levels[m] ?? 0},
                            onSelectionChanged: (s) => setState(() => _levels[m] = s.first),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(onPressed: _saving ? null : _save, child: Text(_isNew ? l10n.adminAdd : l10n.save)),
      ],
    );
  }
}

class _PasswordDialog extends ConsumerStatefulWidget {
  const _PasswordDialog({required this.admin});

  final AdminAccount admin;

  @override
  ConsumerState<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends ConsumerState<_PasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await apiCall(() => ref.read(apiClientProvider).dio.post<void>('/admin/admins/${widget.admin.id}/password', data: {'password': _password.text}));
      if (mounted) {
        Navigator.of(context).pop();
        showSuccessSnack(context, l10n.adminPasswordDone);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        showFailureSnack(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text('${l10n.adminSetPassword}: ${widget.admin.fullName}'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.adminSetPasswordBody),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.adminPassword, helperText: l10n.adminPasswordHelp),
                validator: (v) => _strongPassword(v ?? '') ? null : l10n.adminPasswordHelp,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(onPressed: _saving ? null : _save, child: Text(l10n.save)),
      ],
    );
  }
}

/// Same rule as the server: 8+ characters with a letter and a digit.
bool _strongPassword(String v) => v.length >= 8 && RegExp(r'[A-Za-z]').hasMatch(v) && RegExp(r'\d').hasMatch(v);
