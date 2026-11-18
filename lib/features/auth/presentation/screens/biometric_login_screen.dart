import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/failure_message.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/sanad_button.dart';

enum _Phase { checking, notSetUp, unavailable, ready, signingIn }

/// Fingerprint sign-in page: prompts as soon as it opens, and offers a retry.
/// On success the router's redirect moves to the role's home.
class BiometricLoginScreen extends ConsumerStatefulWidget {
  const BiometricLoginScreen({super.key});

  @override
  ConsumerState<BiometricLoginScreen> createState() =>
      _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends ConsumerState<BiometricLoginScreen> {
  _Phase _phase = _Phase.checking;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final service = ref.read(biometricServiceProvider);
    if (!await service.isAvailable()) {
      if (mounted) setState(() => _phase = _Phase.unavailable);
      return;
    }
    if (!await service.hasSavedCredentials()) {
      if (mounted) setState(() => _phase = _Phase.notSetUp);
      return;
    }
    if (!mounted) return;
    setState(() => _phase = _Phase.ready);
    await _authenticate();
  }

  Future<void> _authenticate() async {
    final l10n = AppLocalizations.of(context)!;
    final service = ref.read(biometricServiceProvider);
    setState(() => _error = null);
    final ok = await service.authenticate(l10n.authBiometricReason);
    if (!mounted) return;
    if (!ok) {
      setState(() => _error = l10n.authBiometricFailed);
      return;
    }
    final creds = await service.readCredentials();
    if (!mounted) return;
    if (creds == null) {
      setState(() => _phase = _Phase.notSetUp);
      return;
    }
    setState(() => _phase = _Phase.signingIn);
    final result = await ref
        .read(authControllerProvider.notifier)
        .login(phone: creds.phone, password: creds.password);
    if (!mounted) return;
    if (result case ResultFailure(:final failure)) {
      if (failure is UnauthorizedFailure) {
        // Password changed elsewhere: the saved login is stale.
        await service.clearCredentials();
        if (!mounted) return;
        setState(() {
          _phase = _Phase.notSetUp;
          _error = l10n.authBiometricExpired;
        });
      } else {
        setState(() {
          _phase = _Phase.ready;
          _error = failure.localizedMessage(l10n);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final message = switch (_phase) {
      _Phase.notSetUp => _error ?? l10n.authBiometricNotSetUp,
      _Phase.unavailable => l10n.authBiometricUnavailable,
      _ => _error,
    };
    final busy = _phase == _Phase.checking || _phase == _Phase.signingIn;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.infoBackground,
                      ),
                      child:
                          busy
                              ? const Padding(
                                padding: EdgeInsets.all(36),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              )
                              : const Icon(
                                Icons.fingerprint_rounded,
                                size: 60,
                                color: AppColors.primary,
                              ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.authBiometricLogin,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_phase == _Phase.ready)
                      SanadButton(
                        label: l10n.authBiometricRetry,
                        icon: Icons.fingerprint_rounded,
                        onPressed: _authenticate,
                      ),
                    if (_phase == _Phase.notSetUp ||
                        _phase == _Phase.unavailable)
                      SanadButton(
                        label: l10n.authLoginTitle,
                        onPressed:
                            () => context.pushReplacement(RoutePaths.login),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
