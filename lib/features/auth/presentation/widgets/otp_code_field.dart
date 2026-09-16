import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';

/// Six single-digit boxes with auto-advance on input and auto-back on
/// backspace — the verification-code input used by the OTP screen.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({super.key, required this.length, required this.onChanged});

  final int length;
  final ValueChanged<String> onChanged;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  late final _controllers = List.generate(widget.length, (_) => TextEditingController());
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
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    widget.onChanged(_controllers.map((c) => c.text).join());
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
                      maxLength: 1,
                      style: Theme.of(context).textTheme.titleLarge,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: AppRadii.smRadius, borderSide: const BorderSide(color: AppColors.primary)),
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
