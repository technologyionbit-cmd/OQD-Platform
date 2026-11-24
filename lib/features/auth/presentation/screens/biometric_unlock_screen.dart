import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/biometric_lock.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/sanad_button.dart';

/// Shown on app start when a session exists and biometric sign-in is on:
/// the OS prompt opens by itself and, once verified, the app opens straight
/// to the home — no password.
class BiometricUnlockScreen extends ConsumerStatefulWidget {
  const BiometricUnlockScreen({super.key});

  @override
  ConsumerState<BiometricUnlockScreen> createState() => _BiometricUnlockScreenState();
}

class _BiometricUnlockScreenState extends ConsumerState<BiometricUnlockScreen> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _failed = false);
    final ok = await ref.read(biometricServiceProvider).authenticate(l10n.authBiometricReason);
    if (!mounted) return;
    if (ok) {
      // The router redirect moves on to the role's home.
      ref.read(biometricLockProvider.notifier).unlock();
    } else {
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.surface,
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
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.infoBackground),
                      child: const Icon(Icons.fingerprint_rounded, size: 60, color: AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(l10n.authBiometricUnlockTitle, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    if (_failed) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(l10n.authBiometricFailed, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SanadButton(label: l10n.authBiometricRetry, icon: Icons.fingerprint_rounded, onPressed: _authenticate),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      // Signing out clears the lock; the router lands on welcome.
                      onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                      child: Text(l10n.authBiometricUsePassword),
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
