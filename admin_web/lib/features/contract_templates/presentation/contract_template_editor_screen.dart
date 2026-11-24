import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/features/auth/presentation/providers/access.dart';
import 'package:aqd_admin/core/network/api_call.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/core/routing/route_paths.dart';
import 'package:aqd_admin/core/widgets/localized_fields.dart';
import 'package:aqd_admin/core/widgets/pdf_attachment_card.dart';
import 'package:aqd_admin/core/widgets/snacks.dart';
import 'package:aqd_admin/core/widgets/state_views.dart';
import 'package:aqd_admin/features/contract_templates/presentation/contract_templates_screen.dart';
import 'package:aqd_admin/features/contracts/presentation/contracts_screen.dart' show contractCategoryLabel;

const _categories = ['employment', 'sale', 'rental', 'partnership', 'nda', 'serviceAgreement', 'other'];
const _types = ['text', 'multiline', 'number', 'date', 'dropdown', 'phone', 'email', 'currency'];

final _detail = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final response = await apiCall(() => ref.watch(apiClientProvider).dio.get<Map<String, dynamic>>('/admin/contract-templates/$id'));
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

class _Option {
  _Option([Map<String, dynamic>? json])
      : value = TextEditingController(text: json?['value'] as String? ?? ''),
        label = _Loc(json?['label'] as Map<String, dynamic>?);

  final TextEditingController value;
  final _Loc label;

  void dispose() {
    value.dispose();
    label.dispose();
  }
}

class _Field {
  _Field([Map<String, dynamic>? json])
      : id = TextEditingController(text: json?['id'] as String? ?? ''),
        type = json?['type'] as String? ?? 'text',
        label = _Loc(json?['label'] as Map<String, dynamic>?),
        isRequired = json?['isRequired'] as bool? ?? true,
        options = [for (final o in (json?['options'] as List<dynamic>? ?? const [])) _Option(o as Map<String, dynamic>)];

  final TextEditingController id;
  String type;
  final _Loc label;
  bool isRequired;
  final List<_Option> options;

  Map<String, dynamic> toJson() => {
        'id': id.text.trim(),
        'type': type,
        'label': label.toJson(),
        'isRequired': isRequired,
        if (type == 'dropdown') 'options': [for (final o in options) {'value': o.value.text.trim(), 'label': o.label.toJson()}],
      };

  void dispose() {
    id.dispose();
    label.dispose();
    for (final o in options) {
      o.dispose();
    }
  }
}

/// Creates or edits a contract template: its name, category and the fields
/// a person fills in. [templateId] is null for a new one.
class ContractTemplateEditorScreen extends ConsumerWidget {
  const ContractTemplateEditorScreen({super.key, this.templateId});

  final String? templateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = templateId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(onPressed: () => context.go(RoutePaths.contractTemplates), icon: const Icon(Icons.arrow_back), label: Text(l10n.backToList)),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: id == null
              ? const _Editor(initial: null)
              : ref.watch(_detail(id)).when(
                    loading: () => const LoadingView(),
                    error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(_detail(id))),
                    data: (d) => _Editor(key: ValueKey('${d['version']}-${d['pdfFileName']}'), initial: d),
                  ),
        ),
      ],
    );
  }
}

class _Editor extends ConsumerStatefulWidget {
  const _Editor({required this.initial, super.key});

  final Map<String, dynamic>? initial;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  final _formKey = GlobalKey<FormState>();
  late final _key = TextEditingController(text: widget.initial?['key'] as String? ?? '');
  late final _title = _Loc(widget.initial?['title'] as Map<String, dynamic>?);
  late String _category = widget.initial?['category'] as String? ?? 'other';
  late bool _active = widget.initial?['isActive'] as bool? ?? true;
  late final List<_Field> _fields = widget.initial == null
      ? [
          _Field({'id': 'partyA', 'type': 'text', 'label': {'ar': 'الطرف الأول', 'en': 'First Party'}, 'isRequired': true}),
          _Field({'id': 'partyB', 'type': 'text', 'label': {'ar': 'الطرف الثاني', 'en': 'Second Party'}, 'isRequired': true}),
        ]
      : [for (final f in (widget.initial!['fields'] as List<dynamic>)) _Field(f as Map<String, dynamic>)];
  bool _saving = false;
  List<String> _serverErrors = const [];

  bool get _isNew => widget.initial == null;

  @override
  void dispose() {
    _key.dispose();
    _title.dispose();
    for (final f in _fields) {
      f.dispose();
    }
    super.dispose();
  }

  void _move(int from, int to) {
    if (to < 0 || to >= _fields.length) return;
    setState(() => _fields.insert(to, _fields.removeAt(from)));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _serverErrors = const [];
    });
    final body = {
      if (_isNew) 'key': _key.text.trim(),
      'category': _category,
      'title': _title.toJson(),
      'fields': [for (final f in _fields) f.toJson()],
      'isActive': _active,
    };
    final dio = ref.read(apiClientProvider).dio;
    try {
      if (_isNew) {
        await apiCall(() => dio.post<void>('/admin/contract-templates', data: body));
      } else {
        await apiCall(() => dio.put<void>('/admin/contract-templates/${widget.initial!['id']}', data: body));
        ref.invalidate(_detail(widget.initial!['id'] as String));
      }
      ref.invalidate(contractTemplatesProvider);
      if (mounted) {
        showSuccessSnack(context, l10n.templateSaved);
        if (_isNew) context.go(RoutePaths.contractTemplates);
      }
    } on ValidationFailure catch (error) {
      if (mounted) {
        setState(() => _serverErrors = [for (final list in error.fieldErrors.values) ...list]);
        showFailureSnack(context, error);
      }
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
              Expanded(child: Text(_isNew ? l10n.templateNew : l10n.templateEdit, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
              FilledButton.icon(
                onPressed: _saving || !canManage(ref, 'contractTemplates') ? null : _save,
                icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
                label: Text(l10n.save),
              ),
            ],
          ),
          if (!_isNew) ...[
            const SizedBox(height: 8),
            Text(l10n.templateVersionNote(widget.initial!['version'] as int), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
          if (_serverErrors.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final e in _serverErrors) Text('• $e')]),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _key,
                    enabled: _isNew,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(labelText: l10n.templateKey, helperText: _isNew ? l10n.templateKeyHelp : null),
                    validator: (v) => RegExp(r'^[a-z][a-zA-Z0-9]{1,39}$').hasMatch((v ?? '').trim()) ? null : l10n.templateKeyHelp,
                  ),
                  const SizedBox(height: 12),
                  LocalizedFields(label: l10n.colTitle, ar: _title.ar, en: _title.en, maxLength: 120),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: InputDecoration(labelText: l10n.colCategory),
                    items: [for (final c in _categories) DropdownMenuItem(value: c, child: Text(contractCategoryLabel(l10n, c)))],
                    onChanged: (v) => setState(() => _category = v ?? _category),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(l10n.templateActive), subtitle: Text(l10n.templateActiveHelp), value: _active, onChanged: (v) => setState(() => _active = v)),
                ],
              ),
            ),
          ),
          if (!_isNew) ...[
            const SizedBox(height: 16),
            PdfAttachmentCard(
              path: '/admin/contract-templates/${widget.initial!['id']}',
              fileName: widget.initial!['hasPdf'] == true ? widget.initial!['pdfFileName'] as String? : null,
              canManage: canManage(ref, 'contractTemplates'),
              onChanged: () {
                ref.invalidate(_detail(widget.initial!['id'] as String));
                ref.invalidate(contractTemplatesProvider);
              },
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(l10n.templateFields, style: theme.textTheme.titleMedium)),
                      OutlinedButton.icon(onPressed: () => setState(() => _fields.add(_Field())), icon: const Icon(Icons.add, size: 18), label: Text(l10n.templateAddField)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(l10n.templatePartyNote, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  for (final (i, f) in _fields.indexed)
                    _FieldCard(
                      key: ObjectKey(f),
                      index: i,
                      field: f,
                      onChanged: () => setState(() {}),
                      onUp: i == 0 ? null : () => _move(i, i - 1),
                      onDown: i == _fields.length - 1 ? null : () => _move(i, i + 1),
                      onRemove: () => setState(() => _fields.removeAt(i)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.index, required this.field, required this.onChanged, required this.onUp, required this.onDown, required this.onRemove, super.key});

  final int index;
  final _Field field;
  final VoidCallback onChanged;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(top: 14, right: 12, left: 12), child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.w700))),
              Expanded(
                child: TextFormField(
                  controller: field.id,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(labelText: l10n.templateFieldId),
                  validator: (v) => RegExp(r'^[a-zA-Z][a-zA-Z0-9]{0,39}$').hasMatch((v ?? '').trim()) ? null : l10n.templateFieldIdHelp,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: field.type,
                  decoration: InputDecoration(labelText: l10n.colType),
                  items: [for (final t in _types) DropdownMenuItem(value: t, child: Text(_typeLabel(l10n, t)))],
                  onChanged: (v) {
                    field.type = v ?? field.type;
                    if (field.type == 'dropdown' && field.options.isEmpty) field.options.add(_Option());
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Row(children: [Text(l10n.templateRequired), Switch(value: field.isRequired, onChanged: (v) {
                field.isRequired = v;
                onChanged();
              })]),
              ItemControls(onUp: onUp, onDown: onDown, onRemove: onRemove),
            ],
          ),
          LocalizedFields(label: l10n.templateFieldLabel, ar: field.label.ar, en: field.label.en),
          if (field.type == 'dropdown') ...[
            const SizedBox(height: 8),
            for (final (i, o) in field.options.indexed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: TextFormField(
                        controller: o.value,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(labelText: l10n.templateOptionValue),
                        validator: (v) => (v ?? '').trim().isEmpty ? l10n.fieldRequired : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: LocalizedFields(label: l10n.templateFieldLabel, ar: o.label.ar, en: o.label.en)),
                    IconButton(
                      onPressed: field.options.length == 1
                          ? null
                          : () {
                              field.options.removeAt(i);
                              onChanged();
                            },
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () {
                  field.options.add(_Option());
                  onChanged();
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.templateAddOption),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _typeLabel(AppLocalizations l, String t) => switch (t) {
      'text' => l.ftText,
      'multiline' => l.ftMultiline,
      'number' => l.ftNumber,
      'date' => l.ftDate,
      'dropdown' => l.ftDropdown,
      'phone' => l.ftPhone,
      'email' => l.ftEmail,
      'currency' => l.ftCurrency,
      _ => t,
    };
