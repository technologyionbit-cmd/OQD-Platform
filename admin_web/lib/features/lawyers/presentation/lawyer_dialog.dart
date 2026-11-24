import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/network/api_call.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/core/routing/route_paths.dart';
import 'package:aqd_admin/core/utils/formatters.dart';
import 'package:aqd_admin/core/widgets/reason_dialog.dart';
import 'package:aqd_admin/core/widgets/snacks.dart';
import 'package:aqd_admin/core/widgets/state_views.dart';
import 'package:aqd_admin/core/widgets/status_chip.dart';
import 'package:aqd_admin/features/auth/presentation/providers/access.dart';
import 'package:aqd_admin/features/consultations/presentation/consultations_screen.dart' show consultationTypeLabel;
import 'package:aqd_admin/features/lawyers/presentation/providers/lawyers_providers.dart';
import 'package:aqd_admin/features/lawyers/presentation/widgets/lawyer_labels.dart';
import 'package:aqd_admin/features/users/presentation/widgets/user_labels.dart';

const _specialties = ['commercial', 'personalStatus', 'criminal', 'labor', 'realEstate', 'corporate', 'intellectualProperty', 'general'];
const _types = ['video', 'voice', 'written'];

final _detail = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final response = await apiCall(() => ref.watch(apiClientProvider).dio.get<Map<String, dynamic>>('/admin/lawyers/$id'));
  return dataOf(response);
});

/// One lawyer: correct their public profile and prices, remove an abusive
/// review, or take their verification away.
class LawyerDialog extends ConsumerWidget {
  const LawyerDialog({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(_detail(id));
    return AlertDialog(
      title: Text(detail.value?['fullName'] as String? ?? l10n.lawDetailTitle),
      content: SizedBox(
        width: 720,
        child: detail.when(
          loading: () => const SizedBox(height: 200, child: LoadingView()),
          error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(_detail(id))),
          data: (d) => _Body(key: ValueKey(d.hashCode), data: d),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.close))],
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  final _formKey = GlobalKey<FormState>();
  late final _bio = TextEditingController(text: widget.data['bio'] as String);
  late final _years = TextEditingController(text: '${widget.data['yearsOfExperience']}');
  late final Set<String> _selected = {for (final s in widget.data['specialties'] as List<dynamic>) s as String};
  late final Map<String, TextEditingController> _prices = {
    for (final t in _types) t: TextEditingController(text: ((widget.data['pricing'] as Map<String, dynamic>)[t] as num?)?.toString() ?? ''),
  };
  late final Map<String, bool> _offered = {for (final t in _types) t: (widget.data['pricing'] as Map<String, dynamic>).containsKey(t)};
  bool _saving = false;

  String get _id => widget.data['id'] as String;
  bool get _manage => canManage(ref, 'lawyers');

  @override
  void dispose() {
    _bio.dispose();
    _years.dispose();
    for (final c in _prices.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selected.isEmpty) {
      showFailureSnack(context, l10n.lawPickSpecialty);
      return;
    }
    setState(() => _saving = true);
    try {
      await apiCall(
        () => ref.read(apiClientProvider).dio.put<void>('/admin/lawyers/$_id', data: {
          'bio': _bio.text.trim(),
          'yearsOfExperience': int.parse(_years.text.trim()),
          'specialties': _selected.toList(),
          'pricing': {for (final t in _types) if (_offered[t] ?? false) t: double.parse(_prices[t]!.text.trim())},
        }),
      );
      ref.invalidate(_detail(_id));
      ref.invalidate(lawyersPageProvider);
      if (mounted) showSuccessSnack(context, l10n.lawSaved);
    } on Object catch (error) {
      if (mounted) showFailureSnack(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _post(String path, String reason, String done) async {
    try {
      await apiCall(() => ref.read(apiClientProvider).dio.post<void>(path, data: {'reason': reason}));
      ref.invalidate(_detail(_id));
      ref.invalidate(lawyersPageProvider);
      if (mounted) showSuccessSnack(context, done);
    } on Object catch (error) {
      if (mounted) showFailureSnack(context, error);
    }
  }

  Future<void> _removeReview(Map<String, dynamic> review) async {
    final l10n = AppLocalizations.of(context);
    final reason = await showReasonDialog(context, title: l10n.lawRemoveReviewTitle, message: l10n.lawRemoveReviewBody, confirmLabel: l10n.lawRemoveReview);
    if (reason == null || !mounted) return;
    await _post('/admin/lawyers/$_id/reviews/${review['id']}/remove', reason, l10n.lawReviewRemoved);
  }

  Future<void> _revoke() async {
    final l10n = AppLocalizations.of(context);
    final reason = await showReasonDialog(context, title: l10n.lawRevokeTitle, message: l10n.lawRevokeBody, confirmLabel: l10n.lawRevoke);
    if (reason == null || !mounted) return;
    await _post('/admin/lawyers/$_id/revoke-verification', reason, l10n.lawRevoked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final d = widget.data;
    final status = d['verificationStatus'] as String;
    final reviews = (d['reviews'] as List<dynamic>).cast<Map<String, dynamic>>();
    final manage = _manage;

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusChip(label: verificationLabel(l10n, status), tone: verificationTone(status)),
                Text(d['email'] as String),
                Text((d['phone'] as String?) ?? '-', textDirection: TextDirection.ltr),
                Text('${l10n.colBarLicense}: ${d['barLicenseNumber']}'),
                Text('${l10n.colConsultations}: ${d['consultationsCount']}'),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('${RoutePaths.users}/${d['userId']}');
                  },
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(l10n.lawOpenAccount),
                ),
              ],
            ),
            if (status == 'rejected' && d['rejectionReason'] != null) ...[
              const SizedBox(height: 8),
              Text('${l10n.verRejected}: ${d['rejectionReason']}', style: TextStyle(color: theme.colorScheme.error)),
            ],
            const Divider(height: 28),
            TextFormField(
              controller: _bio,
              enabled: manage,
              maxLines: 4,
              maxLength: 2000,
              decoration: InputDecoration(labelText: l10n.lawBio),
              validator: (v) => (v ?? '').trim().isEmpty ? l10n.fieldRequired : null,
            ),
            SizedBox(
              width: 200,
              child: TextFormField(
                controller: _years,
                enabled: manage,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.colExperience),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  return n == null || n < 0 || n > 70 ? l10n.fieldRequired : null;
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.colSpecialties, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in _specialties)
                  FilterChip(
                    label: Text(specialtyLabel(l10n, s)),
                    selected: _selected.contains(s),
                    onSelected: manage ? (v) => setState(() => v ? _selected.add(s) : _selected.remove(s)) : null,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.lawPricing, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            for (final t in _types)
              Row(
                children: [
                  Switch(value: _offered[t] ?? false, onChanged: manage ? (v) => setState(() => _offered[t] = v) : null),
                  SizedBox(width: 110, child: Text(consultationTypeLabel(l10n, t))),
                  SizedBox(
                    width: 140,
                    child: TextFormField(
                      controller: _prices[t],
                      enabled: manage && (_offered[t] ?? false),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.colPrice, isDense: true),
                      validator: (v) {
                        if (!(_offered[t] ?? false)) return null;
                        final n = double.tryParse((v ?? '').trim());
                        return n == null || n <= 0 ? l10n.fieldRequired : null;
                      },
                    ),
                  ),
                ],
              ),
            if (manage) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined, size: 18),
                    label: Text(l10n.save),
                  ),
                  const SizedBox(width: 12),
                  if (status == 'verified')
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                      onPressed: _revoke,
                      icon: const Icon(Icons.gpp_bad_outlined, size: 18),
                      label: Text(l10n.lawRevoke),
                    ),
                ],
              ),
            ],
            const Divider(height: 28),
            Text('${l10n.lawReviews} (${d['reviewsCount']})  ·  ${l10n.colRating}: ${(d['rating'] as num).toStringAsFixed(1)}', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (reviews.isEmpty)
              Text(l10n.lawNoReviews)
            else
              for (final r in reviews)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(radius: 14, child: Text('${r['rating']}')),
                  title: Text((r['comment'] as String?)?.isNotEmpty == true ? r['comment'] as String : '-'),
                  subtitle: Text('${r['reviewer']}  ·  ${formatDate(context, DateTime.parse(r['createdAt'] as String))}'),
                  trailing: manage ? IconButton(tooltip: l10n.lawRemoveReview, icon: Icon(Icons.delete_outline, color: theme.colorScheme.error), onPressed: () => _removeReview(r)) : null,
                ),
          ],
        ),
      ),
    );
  }
}
