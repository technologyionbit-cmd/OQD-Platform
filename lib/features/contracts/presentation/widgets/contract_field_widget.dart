import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/widgets/app_dropdown.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field_type.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contract_draft_controller.dart';

/// Renders the one input widget appropriate for [field.type] and writes
/// every change straight into [ContractDraftController] — this is the
/// entire reason a new contract category never needs a new screen: the
/// form screen just maps `template.fields` through this widget.
class ContractFieldWidget extends ConsumerStatefulWidget {
  const ContractFieldWidget({super.key, required this.field, required this.initialValue});

  final ContractField field;
  final String? initialValue;

  @override
  ConsumerState<ContractFieldWidget> createState() => _ContractFieldWidgetState();
}

class _ContractFieldWidgetState extends ConsumerState<ContractFieldWidget> {
  // Owns its own controller (seeded once from provider state, then
  // write-only back to the provider) rather than rebuilding from
  // `ref.watch` on every keystroke — the standard fix for the
  // Riverpod-driven-TextField cursor-jump pitfall.
  late final _controller = TextEditingController(text: widget.initialValue ?? '');
  bool _dateTextFormatted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Stored date values are ISO strings (parseable, locale-independent);
  /// the field shows a formatted date instead. Reformatting only matters
  /// once — when re-opening a draft that already has a value — so this
  /// runs once via [_dateTextFormatted] rather than on every build.
  void _formatDateTextOnce(BuildContext context) {
    if (_dateTextFormatted || widget.field.type != ContractFieldType.date || _controller.text.isEmpty) return;
    final parsed = DateTime.tryParse(_controller.text);
    if (parsed != null) {
      _controller.text = DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(parsed);
    }
    _dateTextFormatted = true;
  }

  void _setValue(String value) {
    ref.read(contractDraftControllerProvider.notifier).setFieldValue(widget.field.id, value);
  }

  @override
  Widget build(BuildContext context) {
    _formatDateTextOnce(context);
    final l10n = AppLocalizations.of(context)!;
    final errorText = ref.watch(contractDraftControllerProvider.select((state) => state.errors[widget.field.id]));
    final label = widget.field.isRequired ? widget.field.label : '${widget.field.label} ${l10n.commonOptional}';
    // Unlike the text-based fields below, a dropdown has no typing cursor
    // to protect — watching the provider directly (instead of a local
    // controller) is both safe and necessary here, since it's the only
    // way the selected option re-renders after a pick.
    final selectedOption = ref.watch(contractDraftControllerProvider.select((state) => state.fieldValues[widget.field.id]));

    return switch (widget.field.type) {
      // Items are the stable option values; only the shown label follows
      // the language, so a draft survives switching languages.
      ContractFieldType.dropdown => AppDropdown<String>(
        label: label,
        value: widget.field.options.any((option) => option.value == selectedOption) ? selectedOption : null,
        items: [for (final option in widget.field.options) option.value],
        itemLabel: (value) => widget.field.options.firstWhere((option) => option.value == value).label,
        errorText: errorText,
        onChanged: (value) => _setValue(value ?? ''),
      ),
      ContractFieldType.date => AppTextField(
        controller: _controller,
        label: label,
        errorText: errorText,
        readOnly: true,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
        onTap: () => _pickDate(context),
      ),
      ContractFieldType.multiline => AppTextField(
        controller: _controller,
        label: label,
        errorText: errorText,
        maxLines: 4,
        minLines: 3,
        onChanged: _setValue,
      ),
      ContractFieldType.number || ContractFieldType.currency => AppTextField(
        controller: _controller,
        label: label,
        errorText: errorText,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: _setValue,
      ),
      ContractFieldType.phone => AppTextField(
        controller: _controller,
        label: label,
        errorText: errorText,
        keyboardType: TextInputType.phone,
        onChanged: _setValue,
      ),
      ContractFieldType.email => AppTextField(
        controller: _controller,
        label: label,
        errorText: errorText,
        keyboardType: TextInputType.emailAddress,
        onChanged: _setValue,
      ),
      ContractFieldType.text => AppTextField(controller: _controller, label: label, errorText: errorText, onChanged: _setValue),
    };
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(_controller.text) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null || !mounted) return;

    setState(() => _controller.text = DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(picked));
    _setValue(DateTime(picked.year, picked.month, picked.day).toIso8601String());
  }
}
