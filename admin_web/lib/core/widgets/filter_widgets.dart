import 'dart:async';

import 'package:flutter/material.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/utils/formatters.dart';

/// Search box that reports the text once the admin pauses typing, so each
/// keystroke does not hit the server.
class DebouncedSearchField extends StatefulWidget {
  const DebouncedSearchField({
    required this.initialValue,
    required this.hint,
    required this.onChanged,
    super.key,
    this.delay = const Duration(milliseconds: 400),
  });

  final String initialValue;
  final String hint;
  final ValueChanged<String> onChanged;
  final Duration delay;

  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialValue);
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _changed(String value) {
    _timer?.cancel();
    _timer = Timer(widget.delay, () => widget.onChanged(value.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _changed,
      onSubmitted: (value) {
        _timer?.cancel();
        widget.onChanged(value.trim());
      },
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _controller.clear();
                    _timer?.cancel();
                    widget.onChanged('');
                  },
                ),
        ),
      ),
    );
  }
}

/// A labelled dropdown whose first entry is "All" (value null).
class FilterDropdown<T> extends StatelessWidget {
  const FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
    this.width = 170,
  });

  final String label;
  final T? value;

  /// value -> text shown for it.
  final Map<T, String> options;
  final ValueChanged<T?> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<T?>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [
          DropdownMenuItem<T?>(child: Text(l10n.filterAll)),
          for (final entry in options.entries) DropdownMenuItem<T?>(value: entry.key, child: Text(entry.value)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

/// Picks one calendar day; shows [label] until a day is chosen, with a
/// clear button after.
class DateFilterButton extends StatelessWidget {
  const DateFilterButton({required this.label, required this.value, required this.onChanged, super.key});

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.event, size: 18),
          label: Text(value == null ? label : '$label: ${formatDate(context, value)}'),
          onPressed: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? now,
              firstDate: DateTime(2024),
              lastDate: DateTime(now.year + 1),
            );
            if (picked != null) onChanged(picked);
          },
        ),
        if (value != null)
          IconButton(tooltip: l10n.clearDates, icon: const Icon(Icons.close, size: 18), onPressed: () => onChanged(null)),
      ],
    );
  }
}
