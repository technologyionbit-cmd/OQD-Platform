import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';

/// The explicit "I agree to the Terms of Service and Privacy Policy"
/// checkbox on the register form. Tapping the sentence toggles the box;
/// tapping either link calls [onOpenTerms] / [onOpenPrivacy] instead.
class TermsConsentField extends StatefulWidget {
  const TermsConsentField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
    this.errorText,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;
  final String? errorText;

  @override
  State<TermsConsentField> createState() => _TermsConsentFieldState();
}

class _TermsConsentFieldState extends State<TermsConsentField> {
  // Recognizers own gesture state, so they live (and die) with this State.
  late final _termsTap = TapGestureRecognizer()..onTap = () => widget.onOpenTerms();
  late final _privacyTap = TapGestureRecognizer()..onTap = () => widget.onOpenPrivacy();

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    const linkStyle = TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline);
    final errorText = widget.errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => widget.onChanged(!widget.value),
          child: Row(
            children: [
              Checkbox(
                value: widget.value,
                isError: errorText != null,
                onChanged: (checked) => widget.onChanged(checked ?? false),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: theme.textTheme.bodySmall,
                    children: [
                      TextSpan(text: l10n.authTermsCheckboxPrefix),
                      TextSpan(text: l10n.authTermsOfService, style: linkStyle, recognizer: _termsTap),
                      TextSpan(text: l10n.authTermsAgreementJoiner),
                      TextSpan(text: l10n.authPrivacyPolicy, style: linkStyle, recognizer: _privacyTap),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Semantics(
            liveRegion: true,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 12),
              child: Text(errorText, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
            ),
          ),
      ],
    );
  }
}
