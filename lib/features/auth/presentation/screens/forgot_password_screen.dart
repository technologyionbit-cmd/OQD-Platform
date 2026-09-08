import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_chip.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_header.dart';

enum _RecoveryMethod { sms, email }

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  _RecoveryMethod _method = _RecoveryMethod.sms;
  final _destinationController = TextEditingController();

  String? _fieldError;
  String? _formError;
  bool _isSubmitting = false;
  bool _sent = false;

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final destination = _destinationController.text.trim();

    final error = _method == _RecoveryMethod.sms
        ? (Validators.isValidPhone(destination) ? null : l10n.validationInvalidPhone)
        : (Validators.isValidEmail(destination) ? null : l10n.validationInvalidEmail);

    setState(() {
      _fieldError = error;
      _formError = null;
    });
    if (error != null) return;

    setState(() => _isSubmitting = true);
    final result = await ref.read(authRepositoryProvider).requestOtp(destination: destination);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold((failure) => setState(() => _formError = _messageFor(failure, l10n)), (_) => setState(() => _sent = true));
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
              icon: Icons.mark_email_unread_outlined,
              title: l10n.authForgotPasswordTitle,
              subtitle: l10n.authForgotPasswordSubtitle,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: _sent ? _buildSentState(context, l10n) : _buildRequestForm(context, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestForm(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AppChip(
                label: l10n.authMethodSms,
                icon: Icons.sms_outlined,
                selected: _method == _RecoveryMethod.sms,
                onTap: () => setState(() {
                  _method = _RecoveryMethod.sms;
                  _fieldError = null;
                }),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: AppChip(
                label: l10n.authMethodEmail,
                icon: Icons.email_outlined,
                selected: _method == _RecoveryMethod.email,
                onTap: () => setState(() {
                  _method = _RecoveryMethod.email;
                  _fieldError = null;
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: _destinationController,
          label: _method == _RecoveryMethod.sms ? l10n.authPhoneLabel : l10n.authEmailLabel,
          errorText: _fieldError,
          keyboardType: _method == _RecoveryMethod.sms ? TextInputType.phone : TextInputType.emailAddress,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(color: context.statusColors.info.background, borderRadius: AppRadii.mdRadius),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: context.statusColors.info.foreground),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  _method == _RecoveryMethod.sms ? l10n.authSmsInfo : l10n.authEmailInfo,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        if (_formError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(_formError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppButton(label: l10n.authSendCode, isLoading: _isSubmitting, onPressed: _send),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(l10n.authRememberPassword, style: Theme.of(context).textTheme.bodyMedium),
              TextButton(onPressed: () => context.go(RoutePaths.login), child: Text(l10n.authLoginTitle)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSentState(BuildContext context, AppLocalizations l10n) {
    final destination = _destinationController.text.trim();
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
        Text(l10n.authSentTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _method == _RecoveryMethod.sms ? l10n.authSentSubtitleSms : l10n.authSentSubtitleEmail,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: l10n.authEnterCode,
          onPressed: () => context.push(RoutePaths.otpVerification, extra: destination),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(onPressed: _send, child: Text(l10n.authResend)),
      ],
    );
  }
}
