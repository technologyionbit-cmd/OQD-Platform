import 'package:flutter/material.dart';

/// Generic labeled dropdown, wired through the same [InputDecorationTheme]
/// as [AppTextField] so it sits visually consistent in any form. Typed on
/// [T] so callers can pass enums/strings/whatever without a cast.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      // `value` keeps this a controlled component (reflects external state
      // changes); `initialValue` would only seed the first build.
      // ignore: deprecated_member_use
      value: value,
      decoration: InputDecoration(labelText: label, errorText: errorText),
      items: [for (final item in items) DropdownMenuItem<T>(value: item, child: Text(itemLabel(item)))],
      onChanged: onChanged,
    );
  }
}
