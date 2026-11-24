import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/biometric_lock.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/phone_verification_prompt.dart';

/// Sits above the router and asks "enable fingerprint / Face ID?" once a
/// sign-in or sign-up has landed on a real screen. Saying "not now" only
/// drops the offer: the next password sign-in offers it again, until the
/// user enables it.
class BiometricOfferHost extends ConsumerStatefulWidget {
  const BiometricOfferHost({required this.navigatorKey, required this.child, super.key});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  ConsumerState<BiometricOfferHost> createState() => _BiometricOfferHostState();
}

class _BiometricOfferHostState extends ConsumerState<BiometricOfferHost> {
  bool _showing = false;

  void _maybeShow() {
    if (_showing) return;
    final offer = ref.read(biometricOfferProvider);
    final user = ref.read(authControllerProvider).value;
    if (offer == null || user == null) return;
    // Wait until the phone-code screen is out of the way.
    if (!user.phoneVerified && ref.read(phoneVerificationPromptProvider)) return;
    if (ref.read(biometricLockProvider)) return;
    _showing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _show(offer));
  }

  Future<void> _show(({String phone, String password}) offer) async {
    final context = widget.navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      _showing = false;
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final service = ref.read(biometricServiceProvider);
    final enable = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            icon: const Icon(Icons.fingerprint_rounded, size: 44),
            title: Text(l10n.authBiometricOfferTitle),
            content: Text(l10n.authBiometricOfferBody, textAlign: TextAlign.center),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.authBiometricOfferLater)),
              FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.authBiometricOfferEnable)),
            ],
          ),
    );
    var saved = false;
    // Confirm with the OS prompt so only the device owner can turn it on.
    if (enable == true && await service.authenticate(l10n.authBiometricReason)) {
      await service.saveCredentials(phone: offer.phone, password: offer.password);
      saved = true;
    }
    ref.read(biometricOfferProvider.notifier).clear();
    _showing = false;
    if (!saved && enable == true && context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l10n.authBiometricFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(biometricOfferProvider, (_, _) => _maybeShow());
    ref.listen(authControllerProvider, (_, _) => _maybeShow());
    ref.listen(phoneVerificationPromptProvider, (_, _) => _maybeShow());
    ref.listen(biometricLockProvider, (_, _) => _maybeShow());
    return widget.child;
  }
}
