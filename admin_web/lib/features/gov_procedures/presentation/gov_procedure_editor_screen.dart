import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/features/auth/presentation/providers/access.dart';
import 'package:aqd_admin/core/network/api_call.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/core/routing/route_paths.dart';
import 'package:aqd_admin/core/widgets/localized_fields.dart';
import 'package:aqd_admin/core/widgets/pdf_attachment_card.dart';
import 'package:aqd_admin/core/widgets/snacks.dart';
import 'package:aqd_admin/core/widgets/state_views.dart';
import 'package:aqd_admin/features/gov_procedures/presentation/gov_procedures_screen.dart';

final _detail = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final response = await apiCall(() => ref.watch(apiClientProvider).dio.get<Map<String, dynamic>>('/admin/gov-procedures/$id'));
  return dataOf(response);
});

class _Loc {
  _Loc([Map<String, dynamic>? json])
      : ar = TextEditingController(text: json?['ar'] as String? ?? ''),
        en = TextEditingController(text: json?['en'] as String? ?? '');

  final TextEditingController ar;
  final TextEditingController en;

  Map<String, String> toJson() => {'ar': ar.text.trim(), 'en': en.text.trim()};
  void dispose() {
    ar.dispose();
    en.dispose();
  }
}

class _Doc {
  _Doc(Map<String, dynamic>? json)
      : id = json?['id'] as String?,
        title = _Loc(json?['title'] as Map<String, dynamic>?);

  final String? id;
  final _Loc title;
}

class _Step {
  _Step(Map<String, dynamic>? json)
      : id = json?['id'] as String?,
        title = _Loc(json?['title'] as Map<String, dynamic>?),
        description = _Loc(json?['description'] as Map<String, dynamic>?);

  final String? id;
  final _Loc title;
  final _Loc description;
}

/// Edits one government procedure the app shows: how long it takes, how
/// it is accessed, the documents needed and the steps. Saved changes show
/// in the app straight away.
class GovProcedureEditorScreen extends ConsumerWidget {
  const GovProcedureEditorScreen({required this.procedureId, super.key});

  final String procedureId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(_detail(procedureId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(onPressed: () => context.go(RoutePaths.govProcedures), icon: const Icon(Icons.arrow_back), label: Text(l10n.backToList)),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: detail.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(_detail(procedureId))),
            data: (d) => _Editor(key: ValueKey(d.hashCode), procedureId: procedureId, initial: d),
          ),
        ),
      ],
    );
  }
}

class _Editor extends ConsumerStatefulWidget {
  const _Editor({required this.procedureId, required this.initial, super.key});

  final String procedureId;
  final Map<String, dynamic> initial;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  final _formKey = GlobalKey<FormState>();
  late String _access = widget.initial['accessType'] as String;
  late final _duration = _Loc(widget.initial['durationLabel'] as Map<String, dynamic>);
  late final List<_Doc> _docs = [for (final d in (widget.initial['requiredDocuments'] as List<dynamic>)) _Doc(d as Map<String, dynamic>)];
  late final List<_Step> _steps = [for (final s in (widget.initial['steps'] as List<dynamic>)) _Step(s as Map<String, dynamic>)];
  bool _saving = false;

  @override
  void dispose() {
    _duration.dispose();
    for (final d in _docs) {
      d.title.dispose();
    }
    for (final s in _steps) {
      s.title.dispose();
      s.description.dispose();
    }
    super.dispose();
  }

  void _move<T>(List<T> list, int from, int to) {
    if (to < 0 || to >= list.length) return;
    setState(() => list.insert(to, list.removeAt(from)));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await apiCall(
        () => ref.read(apiClientProvider).dio.put<void>(
          '/admin/gov-procedures/${widget.procedureId}',
          data: {
            'accessType': _access,
            'durationLabel': _duration.toJson(),
            'requiredDocuments': [
              for (final d in _docs) {if (d.id != null) 'id': d.id, 'title': d.title.toJson()},
            ],
            'steps': [
              for (final s in _steps) {if (s.id != null) 'id': s.id, 'title': s.title.toJson(), 'description': s.description.toJson()},
            ],
          },
        ),
      );
      ref.invalidate(_detail(widget.procedureId));
      ref.invalidate(govProceduresProvider);
      if (mounted) showSuccessSnack(context, l10n.govSaved);
    } on Object catch (error) {
      if (mounted) showFailureSnack(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(child: Text(govTypeLabel(l10n, widget.initial['type'] as String), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
              FilledButton.icon(
                onPressed: _saving || !canManage(ref, 'govProcedures') ? null : _save,
                icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
                label: Text(l10n.save),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PdfAttachmentCard(
            path: '/admin/gov-procedures/${widget.procedureId}',
            fileName: widget.initial['hasPdf'] == true ? widget.initial['pdfFileName'] as String? : null,
            canManage: canManage(ref, 'govProcedures'),
            onChanged: () {
              ref.invalidate(_detail(widget.procedureId));
              ref.invalidate(govProceduresProvider);
            },
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.colAccess, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _access,
                    decoration: InputDecoration(labelText: l10n.colAccess),
                    items: [
                      DropdownMenuItem(value: 'directLink', child: Text(l10n.accessDirectLink)),
                      DropdownMenuItem(value: 'guide', child: Text(l10n.accessGuide)),
                    ],
                    onChanged: (v) => setState(() => _access = v ?? _access),
                  ),
                  const SizedBox(height: 12),
                  LocalizedFields(label: l10n.colDuration, ar: _duration.ar, en: _duration.en),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ListCard(
            title: l10n.colDocuments,
            addLabel: l10n.govAddDocument,
            onAdd: () => setState(() => _docs.add(_Doc(null))),
            children: [
              for (final (i, d) in _docs.indexed)
                _Item(
                  key: ObjectKey(d),
                  index: i,
                  controls: ItemControls(onUp: i == 0 ? null : () => _move(_docs, i, i - 1), onDown: i == _docs.length - 1 ? null : () => _move(_docs, i, i + 1), onRemove: () => setState(() => _docs.removeAt(i))),
                  child: LocalizedFields(label: l10n.colTitle, ar: d.title.ar, en: d.title.en, maxLines: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _ListCard(
            title: l10n.colSteps,
            addLabel: l10n.govAddStep,
            onAdd: () => setState(() => _steps.add(_Step(null))),
            children: [
              for (final (i, s) in _steps.indexed)
                _Item(
                  key: ObjectKey(s),
                  index: i,
                  controls: ItemControls(onUp: i == 0 ? null : () => _move(_steps, i, i - 1), onDown: i == _steps.length - 1 ? null : () => _move(_steps, i, i + 1), onRemove: () => setState(() => _steps.removeAt(i))),
                  child: Column(
                    children: [
                      LocalizedFields(label: l10n.colTitle, ar: s.title.ar, en: s.title.en),
                      const SizedBox(height: 12),
                      LocalizedFields(label: l10n.govStepDescription, ar: s.description.ar, en: s.description.en, maxLines: 3),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.title, required this.addLabel, required this.onAdd, required this.children});

  final String title;
  final String addLabel;
  final VoidCallback onAdd;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add, size: 18), label: Text(addLabel)),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.index, required this.controls, required this.child, super.key});

  final int index;
  final Widget controls;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor), borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 14, right: 12, left: 12), child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.w700))),
          Expanded(child: child),
          controls,
        ],
      ),
    );
  }
}
