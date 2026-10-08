import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/failure_message.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/presentation/password_rules.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_form_error.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_success_state.dart';

/// Step 3 of the password reset: the new password, sent with the code the
/// previous screen checked. Success signs the account out everywhere, so
/// the user continues from the login screen.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.phone, required this.code});

  final String phone;
  final String code;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _passwordError;
  String? _confirmError;
  String? _formError;
  bool _isSubmitting = false;
  bool _succeeded = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // The keyboard's "done" action bypasses the button's loading state.
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    final passwordError = newPasswordError(_passwordController.text, l10n);
    final confirmError = _confirmController.text == _passwordController.text ? null : l10n.validationPasswordMismatch;

    setState(() {
      _passwordError = passwordError;
      _confirmError = confirmError;
      _formError = null;
      _isSubmitting = passwordError == null && confirmError == null;
    });
    if (!_isSubmitting) return;

    final result = await ref
        .read(authRepositoryProvider)
        .resetPassword(phone: widget.phone, code: widget.code, newPassword: _passwordController.text);
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      if (result case ResultFailure(:final failure)) {
        _applyFailure(failure, l10n);
      } else {
        _succeeded = true;
      }
    });
  }

  /// Server text is never shown: a known code picks the message, and a
  /// rejected password gets the rules hint on its field.
  void _applyFailure(Failure failure, AppLocalizations l10n) {
    switch (failure) {
      // The code expired, got locked, or was used since the previous screen.
      case Failure(code: ApiErrorCodes.invalidVerificationCode || ApiErrorCodes.verificationCodeLocked):
        _formError = l10n.authResetCodeExpired;
      case ValidationFailure(code: ApiErrorCodes.validationError, :final fieldErrors) when fieldErrors.containsKey('newPassword'):
        _passwordError = l10n.authPasswordRulesHint;
      default:
        _formError = failure.localizedMessage(l10n);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AuthScaffold(
      icon: Icons.lock_reset_outlined,
      title: l10n.authResetPasswordTitle,
      subtitle: l10n.authResetPasswordSubtitle,
      showBackButton: !_succeeded,
      child: _succeeded ? _buildSuccessState(l10n) : _buildForm(l10n),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _passwordController,
            label: l10n.authNewPassword,
            errorText: _passwordError,
            helperText: l10n.authPasswordRulesHint,
            obscureText: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _confirmController,
            label: l10n.authConfirmPassword,
            errorText: _confirmError,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            onSubmitted: (_) => _submit(),
          ),
          AuthFormError(_formError),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: l10n.authResetPasswordSubmit, isLoading: _isSubmitting, onPressed: _submit),
        ],
      ),
    );
  }

  Widget _buildSuccessState(AppLocalizations l10n) {
    return AuthSuccessState(
      title: l10n.authResetPasswordSuccessTitle,
      message: l10n.authResetPasswordSuccessSubtitle,
      primaryLabel: l10n.authGoToLogin,
      onPrimary: () => context.go(RoutePaths.login),
    );
  }
}
