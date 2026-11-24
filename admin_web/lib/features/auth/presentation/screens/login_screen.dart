import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/core/errors/failure_message.dart';
import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/theme/app_colors.dart';
import 'package:aqd_admin/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_admin/features/auth/presentation/widgets/access_denied_card.dart';

/// Jordanian mobile in any common spelling the backend accepts.
final _phonePattern = RegExp(r'^(\+?962|0)?7[789]\d{7}$');

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  bool _submitting = false;
  bool _denied = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _submitting) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).login(
            phone: _phone.text.replaceAll(RegExp(r'[\s-]'), ''),
            password: _password.text,
          );
      // The router moves on once the auth state holds the user.
    } on ForbiddenFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        if (failure.code == ApiErrorCodes.accountInactive) {
          _error = l10n.accountInactive;
        } else {
          _denied = true;
          _password.clear();
        }
      });
    } on UnauthorizedFailure {
      if (mounted) setState(() => _error = l10n.signInFailed);
    } on Object catch (error) {
      if (mounted) setState(() => _error = failureMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final notice = ref.watch(signInNoticeProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _denied
                    ? AccessDeniedCard(onBack: () => setState(() => _denied = false))
                    : Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(Icons.balance, size: 40, color: AppColors.primary),
                            const SizedBox(height: 16),
                            Text(l10n.signInTitle, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text(
                              l10n.signInSubtitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 24),
                            if (notice == SignInNotice.sessionExpired && _error == null) ...[
                              _Banner(message: l10n.sessionExpiredNotice, color: AppColors.warning, background: AppColors.warningBackground),
                              const SizedBox(height: 16),
                            ],
                            if (_error != null) ...[
                              _Banner(message: _error!, color: AppColors.error, background: AppColors.errorBackground),
                              const SizedBox(height: 16),
                            ],
                            TextFormField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              textDirection: TextDirection.ltr,
                              autofillHints: const [AutofillHints.username],
                              decoration: InputDecoration(labelText: l10n.phoneLabel, hintText: l10n.phoneHint, prefixIcon: const Icon(Icons.phone_outlined)),
                              validator: (value) {
                                final text = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
                                if (text.isEmpty) return l10n.fieldRequired;
                                return _phonePattern.hasMatch(text) ? null : l10n.phoneInvalid;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscure,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                labelText: l10n.passwordLabel,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                ),
                              ),
                              validator: (value) => (value ?? '').isEmpty ? l10n.fieldRequired : null,
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: _submitting ? null : _submit,
                              child: _submitting
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text(l10n.signInAction),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.message, required this.color, required this.background});

  final String message;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(10)),
      child: Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
