import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_form_error.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_success_state.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.destination, required this.code});

  final String destination;
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
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    final passwordError = Validators.isPasswordLongEnough(_passwordController.text) ? null : l10n.validationPasswordTooShort;
    final confirmError = _confirmController.text == _passwordController.text ? null : l10n.validationPasswordMismatch;

    setState(() {
      _passwordError = passwordError;
      _confirmError = confirmError;
      _formError = null;
    });
    if (passwordError != null || confirmError != null) return;

    setState(() => _isSubmitting = true);
    final result = await ref
        .read(authRepositoryProvider)
        .resetPassword(destination: widget.destination, code: widget.code, newPassword: _passwordController.text);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold((failure) => setState(() => _formError = _messageFor(failure, l10n)), (_) => setState(() => _succeeded = true));
  }

  String _messageFor(Failure failure, AppLocalizations l10n) {
    return switch (failure) {
      ValidationFailure(:final fieldErrors) when fieldErrors.isNotEmpty => fieldErrors.values.first.first,
      NetworkFailure() => l10n.errorNetwork,
      TimeoutFailure() => l10n.errorTimeout,
      ServerFailure() => l10n.errorServer,
      _ => l10n.errorGeneric,
    };
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
