import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _formError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    final emailError = !Validators.isRequired(_emailController.text)
        ? l10n.validationRequired
        : !Validators.isValidEmail(_emailController.text)
        ? l10n.validationInvalidEmail
        : null;
    final passwordError = !Validators.isRequired(_passwordController.text)
        ? l10n.validationRequired
        : !Validators.isPasswordLongEnough(_passwordController.text)
        ? l10n.validationPasswordTooShort
        : null;

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _formError = null;
    });
    if (emailError != null || passwordError != null) return;

    setState(() => _isSubmitting = true);
    final result = await ref
        .read(authControllerProvider.notifier)
        .login(email: _emailController.text.trim(), password: _passwordController.text);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold((failure) => setState(() => _formError = _messageFor(failure, l10n)), (_) {
      // Navigation is driven by the router's redirect reacting to
      // authControllerProvider — this screen doesn't navigate itself.
    });
  }

  String _messageFor(Failure failure, AppLocalizations l10n) {
    return switch (failure) {
      UnauthorizedFailure() => l10n.errorInvalidCredentials,
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.appName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(l10n.authLoginTitle, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _emailController,
                    label: l10n.authEmailLabel,
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _passwordController,
                    label: l10n.authPasswordLabel,
                    errorText: _passwordError,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                  ),
                  if (_formError != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(_formError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(label: l10n.authLoginSubmit, isLoading: _isSubmitting, onPressed: _submit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
