import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';

/// A phone number field with the country shown as a fixed prefix, so the
/// user types only the local number. Jordan is the only supported country
/// today (the backend accepts `+9627XXXXXXXX` only); the prefix is the one
/// place to extend when more countries are supported.
///
/// Submit still goes through `JordanMobile.normalize`, which accepts a
/// leading 0 or a pasted full number as well.
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints = const [AutofillHints.telephoneNumber],
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  static const _flag = '\u{1F1EF}\u{1F1F4}';
  static const _dialCode = '+962';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final divider = Theme.of(context).colorScheme.outlineVariant;

    return AppTextField(
      controller: controller,
      label: label,
      hintText: '7X XXX XXXX',
      errorText: errorText,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      autofillHints: autofillHints,
      textDirection: TextDirection.ltr,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\s]'))],
      prefix: Padding(
        padding: const EdgeInsetsDirectional.only(start: AppSpacing.md, end: AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(_flag, style: TextStyle(fontSize: 20)),
            const SizedBox(width: AppSpacing.xs),
            Text(_dialCode, textDirection: TextDirection.ltr, style: textTheme.bodyLarge),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(height: 24, child: VerticalDivider(width: 1, thickness: 1, color: divider)),
          ],
        ),
      ),
    );
  }
}
