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
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final Iterable<String>? autofillHints;

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
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(_obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
    );
  }
}
