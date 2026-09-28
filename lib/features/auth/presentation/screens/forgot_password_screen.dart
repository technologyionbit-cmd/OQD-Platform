import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/failure_message.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_form_error.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_scaffold.dart';

/// Step 1 of the password reset: the account email. The server answers
/// the same whether or not the email has an account, so on success this
/// always moves on to the code screen.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  String? _emailError;
  String? _formError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    // The keyboard's "done" action bypasses the button's loading state.
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();

    final emailError = !Validators.isRequired(email)
        ? l10n.validationRequired
        : !Validators.isValidEmail(email)
        ? l10n.validationInvalidEmail
        : null;
    setState(() {
      _emailError = emailError;
      _formError = null;
      _isSubmitting = emailError == null;
    });
    if (emailError != null) return;

    final result = await ref.read(authRepositoryProvider).requestPasswordReset(email: email);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success():
        unawaited(context.push(RoutePaths.otpVerification, extra: email));
      case ResultFailure(failure: ValidationFailure(code: ApiErrorCodes.validationError)):
        setState(() => _emailError = l10n.validationInvalidEmail);
      case ResultFailure(:final failure):
        setState(() => _formError = failure.localizedMessage(l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AuthScaffold(
      icon: Icons.mark_email_unread_outlined,
      title: l10n.authForgotPasswordTitle,
      subtitle: l10n.authForgotPasswordSubtitle,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _emailController,
              label: l10n.authEmailLabel,
              errorText: _emailError,
              maxLength: Validators.emailMaxLength,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              onSubmitted: (_) => _send(),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(color: context.statusColors.info.background, borderRadius: AppRadii.mdRadius),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: context.statusColors.info.foreground),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: Text(l10n.authEmailInfo, style: Theme.of(context).textTheme.bodySmall)),
                ],
              ),
            ),
            AuthFormError(_formError),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: l10n.authSendCode, isLoading: _isSubmitting, onPressed: _send),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(l10n.authRememberPassword, style: Theme.of(context).textTheme.bodyMedium),
                  TextButton(onPressed: () => context.go(RoutePaths.login), child: Text(l10n.authLoginTitle)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
