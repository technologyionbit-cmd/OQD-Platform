import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';

/// Six single-digit boxes with auto-advance on input, auto-back on
/// backspace, and a pasted or autofilled code spread over the boxes — the
/// verification-code input of the email and password-reset code screens.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({super.key, required this.length, required this.onChanged});

  final int length;
  final ValueChanged<String> onChanged;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  late final _controllers = List.generate(widget.length, (_) => TextEditingController());
  // Each box's digit before the current edit, to tell typing from pasting.
  late final _digits = List.filled(widget.length, '');
  late final _focusNodes = List.generate(widget.length, (_) => FocusNode());
  // Wraps each field to catch backspace-on-empty for cross-field navigation
  // — a separate node from [_focusNodes] (which the TextField itself owns),
  // created once here rather than per-build to avoid leaking a FocusNode on
  // every keystroke.
  late final _keyListenerNodes = List.generate(widget.length, (_) => FocusNode(skipTraversal: true));

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final node in _keyListenerNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length <= 1) {
      _digits[index] = value;
      if (value.isNotEmpty) _focusAfter(index);
    } else if (value.length == 2 && _controllers[index].selection.isCollapsed && _isTypingOver(index, value)) {
      // A digit typed into a filled box replaces it.
      final caret = _controllers[index].selection.baseOffset.clamp(1, 2);
      _setDigit(index, value[caret - 1]);
      _focusAfter(index);
    } else {
      // A pasted or autofilled code: spread it over this box and the next.
      final digits = value.split('').take(widget.length - index).toList();
      for (var offset = 0; offset < digits.length; offset++) {
        _setDigit(index + offset, digits[offset]);
      }
      _focusAfter(index + digits.length - 1);
    }
    widget.onChanged(_controllers.map((c) => c.text).join());
  }

  /// Whether [value] is the box's single previous digit plus one new one.
  bool _isTypingOver(int index, String value) {
    final previous = _digits[index];
    return previous.isNotEmpty && (value.startsWith(previous) || value.endsWith(previous));
  }

  void _setDigit(int index, String digit) {
    _digits[index] = digit;
    _controllers[index].value = TextEditingValue(text: digit, selection: const TextSelection.collapsed(offset: 1));
  }

  void _focusAfter(int index) {
    if (index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _onKey(int index, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace && _controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Codes read left-to-right regardless of locale; force LTR so box 1 is
    // always the leftmost. Each box flexes to share the available width so
    // six boxes never overflow a narrow screen.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          for (var index = 0; index < widget.length; index++) ...[
            if (index > 0) const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 56),
                child: AspectRatio(
                  aspectRatio: 44 / 52,
                  child: KeyboardListener(
                    focusNode: _keyListenerNodes[index],
                    onKeyEvent: (event) => _onKey(index, event),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      // No maxLength: it would cut a pasted code to one
                      // digit before _onDigitChanged could spread it.
                      autofillHints: index == 0 ? const [AutofillHints.oneTimeCode] : null,
                      style: Theme.of(context).textTheme.titleLarge,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: BorderSide(color: AppColors.primary)),
                      ),
                      onChanged: (value) => _onDigitChanged(index, value),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
