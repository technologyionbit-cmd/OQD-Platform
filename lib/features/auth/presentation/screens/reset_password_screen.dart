import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_header.dart';

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
      NetworkFailure() => l10n.errorNetwork,
      TimeoutFailure() => l10n.errorTimeout,
      ServerFailure() => l10n.errorServer,
      _ => l10n.errorGeneric,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(
              icon: Icons.lock_reset_outlined,
              title: l10n.authResetPasswordTitle,
              subtitle: l10n.authResetPasswordSubtitle,
              showBackButton: !_succeeded,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: _succeeded ? _buildSuccessState(context, l10n) : _buildForm(context, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _passwordController,
          label: l10n.authNewPassword,
          errorText: _passwordError,
          obscureText: true,
          autofillHints: const [AutofillHints.newPassword],
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _confirmController,
          label: l10n.authConfirmPassword,
          errorText: _confirmError,
          obscureText: true,
        ),
        if (_formError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(_formError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: l10n.authResetPasswordSubmit, isLoading: _isSubmitting, onPressed: _submit),
      ],
    );
  }

  Widget _buildSuccessState(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: context.statusColors.success.background, shape: BoxShape.circle),
          child: Icon(Icons.check, color: context.statusColors.success.foreground, size: 40),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.authResetPasswordSuccessTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.authResetPasswordSuccessSubtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: l10n.authGoToLogin, onPressed: () => context.go(RoutePaths.login)),
      ],
    );
  }
}
