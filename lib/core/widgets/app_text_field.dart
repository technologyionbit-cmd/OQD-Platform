import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aqd_ionbit/core/utils/latin_digits_formatter.dart';

/// Standard text field: label, error text, and an optional obscure-toggle
/// for password fields, all wired through the app [InputDecorationTheme] —
/// screens never set border/fill/padding themselves.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.autofillHints,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.prefixIcon,
    this.hintText,
    this.helperText,
    this.maxLength,
    this.prefix,
    this.inputFormatters,
    this.textDirection,
    this.toggleLabels,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final Iterable<String>? autofillHints;

  /// >1 for a multiline field (e.g. a description); ignored when
  /// [obscureText] is set since Flutter disallows obscured multiline text.
  final int maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;

  /// Called when the keyboard action button is pressed — wire it to the
  /// form's submit handler so a form is completable without leaving the
  /// keyboard.
  final ValueChanged<String>? onSubmitted;

  /// Set alongside [onTap] for a field that opens a picker (date, etc.)
  /// instead of accepting direct keyboard input.
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final IconData? prefixIcon;

  /// A custom always-visible leading widget (e.g. a country code); wins over
  /// [prefixIcon].
  final Widget? prefix;
  final List<TextInputFormatter>? inputFormatters;

  /// Forces the whole field's layout direction (icons, text, caret) —
  /// phone and password fields stay LTR in Arabic, like their English look.
  /// Defaults to LTR for [obscureText] fields.
  final TextDirection? textDirection;
  final String? hintText;

  /// (show, hide) words for an obscure-toggle shown as text instead of an
  /// eye icon.
  final (String, String)? toggleLabels;

  /// Guidance under the field (e.g. password rules); [errorText] replaces
  /// it while shown.
  final String? helperText;

  /// Hard cap on characters typed or pasted — set to the server's limit
  /// for the field. No counter is shown.
  final int? maxLength;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscured = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      autofillHints: widget.autofillHints,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.obscureText ? null : widget.minLines,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      maxLength: widget.maxLength,
      // Arabic digits typed on an Arabic keyboard become Latin ones first,
      // so the field's own filters (digits only, etc.) see 0-9.
      inputFormatters: [const LatinDigitsFormatter(), ...?widget.inputFormatters],
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        helperText: widget.helperText,
        helperMaxLines: 2,
        counterText: widget.maxLength == null ? null : '',
        errorText: widget.errorText,
        prefixIcon: widget.prefix ?? (widget.prefixIcon == null ? null : Icon(widget.prefixIcon, size: 20)),
        suffixIcon:
            widget.obscureText
                ? (widget.toggleLabels != null
                    ? TextButton(
                      onPressed: () => setState(() => _obscured = !_obscured),
                      child: Text(_obscured ? widget.toggleLabels!.$1 : widget.toggleLabels!.$2),
                    )
                    : IconButton(
                      icon: Icon(_obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscured = !_obscured),
                    ))
                : widget.suffixIcon,
      ),
    );

    final direction = widget.textDirection ?? (widget.obscureText ? TextDirection.ltr : null);
    return direction == null ? field : Directionality(textDirection: direction, child: field);
  }
}
