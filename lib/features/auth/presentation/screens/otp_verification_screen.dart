import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_header.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/otp_code_field.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key, required this.destination});

  final String destination;

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  static const _codeLength = 6;
  static const _resendCooldown = 30;

  String _code = '';
  String? _error;
  bool _isSubmitting = false;
  int _secondsRemaining = _resendCooldown;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _secondsRemaining = _resendCooldown;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _resend() async {
    if (_secondsRemaining > 0) return;
    await ref.read(authRepositoryProvider).requestOtp(destination: widget.destination);
    if (!mounted) return;
    _startCooldown();
  }

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context)!;
    if (_code.length != _codeLength) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final result = await ref.read(authRepositoryProvider).verifyOtp(destination: widget.destination, code: _code);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold((failure) => setState(() => _error = l10n.errorGeneric), (verified) {
      if (!verified) {
        setState(() => _error = l10n.authOtpInvalidCode);
        return;
      }
      context.pushReplacement(RoutePaths.resetPassword, extra: (destination: widget.destination, code: _code));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(icon: Icons.phonelink_lock_outlined, title: l10n.authOtpTitle, subtitle: l10n.authOtpSubtitle(widget.destination)),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OtpCodeField(length: _codeLength, onChanged: (value) => setState(() => _code = value)),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
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
                            l10n.authOtpResendIn('00:${_secondsRemaining.toString().padLeft(2, '0')}'),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                          )
                        : TextButton(onPressed: _resend, child: Text(l10n.authResend)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
