import 'package:flutter/material.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';

/// The Arabic and English versions of one piece of text, side by side.
/// Both are required: the app shows whichever the reader uses.
class LocalizedFields extends StatelessWidget {
  const LocalizedFields({required this.label, required this.ar, required this.en, super.key, this.maxLines = 1, this.maxLength});

  final String label;
  final TextEditingController ar;
  final TextEditingController en;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String? required(String? v) => (v ?? '').trim().isEmpty ? l10n.fieldRequired : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: ar,
            maxLines: maxLines,
            maxLength: maxLength,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(labelText: '$label (${l10n.langArabicShort})'),
            validator: required,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: en,
            maxLines: maxLines,
            maxLength: maxLength,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(labelText: '$label (${l10n.langEnglishShort})'),
            validator: required,
          ),
        ),
      ],
    );
  }
}

/// A small up / down / remove button row for an item in an editable list.
class ItemControls extends StatelessWidget {
  const ItemControls({required this.onUp, required this.onDown, required this.onRemove, super.key});

  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(visualDensity: VisualDensity.compact, onPressed: onUp, icon: const Icon(Icons.arrow_upward, size: 18)),
        IconButton(visualDensity: VisualDensity.compact, onPressed: onDown, icon: const Icon(Icons.arrow_downward, size: 18)),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: onRemove,
          color: Theme.of(context).colorScheme.error,
          icon: const Icon(Icons.delete_outline, size: 18),
        ),
      ],
    );
  }
}
