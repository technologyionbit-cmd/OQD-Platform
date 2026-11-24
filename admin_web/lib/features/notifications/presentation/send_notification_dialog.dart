import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/network/api_call.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/core/widgets/confirm_dialog.dart';
import 'package:aqd_admin/core/widgets/localized_fields.dart';
import 'package:aqd_admin/core/widgets/snacks.dart';
import 'package:aqd_admin/features/users/presentation/widgets/user_labels.dart';

/// Writes one message (in both app languages) and sends it to a single
/// user, everyone with a role, or everyone. Returns true if it was sent.
Future<bool> showSendNotificationDialog(BuildContext context) async {
  final sent = await showDialog<bool>(context: context, builder: (_) => const _SendDialog());
  return sent ?? false;
}

class _SendDialog extends ConsumerStatefulWidget {
  const _SendDialog();

  @override
  ConsumerState<_SendDialog> createState() => _SendDialogState();
}

class _SendDialogState extends ConsumerState<_SendDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleAr = TextEditingController();
  final _titleEn = TextEditingController();
  final _bodyAr = TextEditingController();
  final _bodyEn = TextEditingController();
  final _search = TextEditingController();
  String _audience = 'all';
  String _role = 'client';
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _results = const [];
  Timer? _debounce;
  bool _sending = false;

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [_titleAr, _titleEn, _bodyAr, _bodyEn, _search]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (value.trim().length < 2) {
        setState(() => _results = const []);
        return;
      }
      try {
        final response = await apiCall(
          () => ref.read(apiClientProvider).dio.get<Map<String, dynamic>>('/admin/users', queryParameters: {'q': value.trim(), 'limit': 6, 'status': 'active'}),
        );
        if (mounted) {
          setState(() => _results = (response.data!['data'] as List<dynamic>).cast<Map<String, dynamic>>().where((u) => u['role'] != 'admin').toList());
        }
      } on Object {
        if (mounted) setState(() => _results = const []);
      }
    });
  }

  String _audienceText(AppLocalizations l10n) => switch (_audience) {
        'user' => _user?['fullName'] as String? ?? '',
        'role' => roleLabel(l10n, _role),
        _ => l10n.notifAudienceAll,
      };

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_audience == 'user' && _user == null) {
      showFailureSnack(context, l10n.notifPickUser);
      return;
    }
    final ok = await showConfirmDialog(context, title: l10n.notifConfirmTitle, message: l10n.notifConfirmBody(_audienceText(l10n)), confirmLabel: l10n.notifSend);
    if (!ok || !mounted) return;
    setState(() => _sending = true);
    try {
      final response = await apiCall(
        () => ref.read(apiClientProvider).dio.post<Map<String, dynamic>>('/admin/notifications/send', data: {
          'audience': _audience,
          if (_audience == 'user') 'userId': _user!['id'],
          if (_audience == 'role') 'role': _role,
          'titleAr': _titleAr.text.trim(),
          'titleEn': _titleEn.text.trim(),
          'bodyAr': _bodyAr.text.trim(),
          'bodyEn': _bodyEn.text.trim(),
        }),
      );
      final count = (dataOf(response)['sent'] as num).toInt();
      if (mounted) {
        Navigator.of(context).pop(true);
        showSuccessSnack(context, l10n.notifSent(count));
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _sending = false);
        showFailureSnack(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.notifSendTitle),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: 'all', label: Text(l10n.notifAudienceAll)),
                    ButtonSegment(value: 'role', label: Text(l10n.notifAudienceRole)),
                    ButtonSegment(value: 'user', label: Text(l10n.notifAudienceUser)),
                  ],
                  selected: {_audience},
                  onSelectionChanged: (s) => setState(() => _audience = s.first),
                ),
                const SizedBox(height: 12),
                if (_audience == 'role')
                  DropdownButtonFormField<String>(
                    initialValue: _role,
                    decoration: InputDecoration(labelText: l10n.filterRole),
                    items: [for (final r in ['client', 'lawyer', 'company']) DropdownMenuItem(value: r, child: Text(roleLabel(l10n, r)))],
                    onChanged: (v) => setState(() => _role = v ?? _role),
                  ),
                if (_audience == 'user') ...[
                  if (_user != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_outline),
                      title: Text(_user!['fullName'] as String),
                      subtitle: Text(_user!['email'] as String),
                      trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _user = null)),
                    )
                  else ...[
                    TextField(controller: _search, onChanged: _onSearch, decoration: InputDecoration(labelText: l10n.searchUsersHint, prefixIcon: const Icon(Icons.search))),
                    for (final u in _results)
                      ListTile(
                        dense: true,
                        title: Text(u['fullName'] as String),
                        subtitle: Text('${u['email']}  ·  ${roleLabel(l10n, u['role'] as String)}'),
                        onTap: () => setState(() {
                          _user = u;
                          _results = const [];
                        }),
                      ),
                  ],
                ],
                const SizedBox(height: 12),
                LocalizedFields(label: l10n.colTitle, ar: _titleAr, en: _titleEn, maxLength: 100),
                const SizedBox(height: 4),
                LocalizedFields(label: l10n.notifBody, ar: _bodyAr, en: _bodyEn, maxLines: 3, maxLength: 500),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _sending ? null : () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
        FilledButton.icon(
          onPressed: _sending ? null : _send,
          icon: _sending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_outlined, size: 18),
          label: Text(l10n.notifSend),
        ),
      ],
    );
  }
}
