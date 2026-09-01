import 'package:flutter/material.dart';

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
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.hintText,
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

  /// Set alongside [onTap] for a field that opens a picker (date, etc.)
  /// instead of accepting direct keyboard input.
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final String? hintText;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      autofillHints: widget.autofillHints,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.obscureText ? null : widget.minLines,
      onChanged: widget.onChanged,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        errorText: widget.errorText,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(_obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : widget.suffixIcon,
      ),
    );
  }
}
