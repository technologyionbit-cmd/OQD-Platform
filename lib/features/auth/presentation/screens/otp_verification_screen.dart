import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/failure_message.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/utils/jordan_mobile.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_form_error.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/otp_code_field.dart';

/// Step 2 of the password reset: the 6-digit code texted to [phone]. A
/// right code opens the new-password screen, which sends it again.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key, required this.phone});

  /// Normalized, +9627XXXXXXXX.
  final String phone;

  /// Matches the server's default OTP_RESEND_COOLDOWN_SECONDS. A 429 with
  /// Retry-After replaces it with the server's actual wait.
  static const resendCooldown = Duration(seconds: 60);

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  static const _codeLength = 6;

  String _code = '';
  String? _error;
  bool _isSubmitting = false;
  bool _isResending = false;
  int _secondsRemaining = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // The previous screen just sent a code.
    _startCooldown(OtpVerificationScreen.resendCooldown);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown(Duration wait) {
    _timer?.cancel();
    _secondsRemaining = wait.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _confirm() async {
    if (_isSubmitting || _code.length != _codeLength) return;
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    final code = _code;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final result = await ref.read(authRepositoryProvider).verifyPasswordResetCode(phone: widget.phone, code: code);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success():
        context.pushReplacement(RoutePaths.resetPassword, extra: (phone: widget.phone, code: code));
      case ResultFailure(:final failure):
        setState(() => _error = _messageFor(failure, l10n));
    }
  }

  Future<void> _resend() async {
    if (_isResending || _secondsRemaining > 0) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isResending = true;
      _error = null;
    });
    final result = await ref.read(authRepositoryProvider).requestPasswordReset(phone: widget.phone);
    if (!mounted) return;
    setState(() => _isResending = false);

    switch (result) {
      case Success():
        setState(() => _startCooldown(OtpVerificationScreen.resendCooldown));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.authCodeResent)));
      case ResultFailure(failure: RateLimitedFailure(:final retryAfter?)):
        // The server knows the real wait; the countdown shows it.
        setState(() => _startCooldown(retryAfter));
      case ResultFailure(:final failure):
        setState(() => _error = failure.localizedMessage(l10n));
    }
  }

  /// A malformed code (plain 422) reads the same as a wrong one.
  String _messageFor(Failure failure, AppLocalizations l10n) => switch (failure) {
    ValidationFailure(code: ApiErrorCodes.validationError) => l10n.authOtpInvalidCode,
    _ => failure.localizedMessage(l10n),
  };

  String _countdownLabel() {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AuthScaffold(
      icon: Icons.sms_outlined,
      title: l10n.authOtpTitle,
      subtitle: l10n.authOtpSubtitle(JordanMobile.display(widget.phone)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OtpCodeField(length: _codeLength, onChanged: (value) => setState(() => _code = value)),
          AuthFormError(_error),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: l10n.authOtpConfirm,
            isLoading: _isSubmitting,
            onPressed: _code.length == _codeLength ? _confirm : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: _secondsRemaining > 0
                ? Text(
                    l10n.authOtpResendIn(_countdownLabel()),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  )
                : TextButton(onPressed: _isResending ? null : _resend, child: Text(l10n.authResend)),
          ),
        ],
      ),
    );
  }
}
