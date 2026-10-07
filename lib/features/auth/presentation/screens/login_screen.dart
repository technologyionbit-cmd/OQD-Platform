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
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/language_switch_button.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_form_error.dart';

/// Email + password only. The account's role (returned by the backend)
/// decides which shell the router lands on — there is no role selector,
/// so a lawyer signing in goes to the lawyer app, a client to the client
/// app, automatically.
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
    // The keyboard's "done" action bypasses the button's disabled state.
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    final emailError =
        !Validators.isRequired(_emailController.text)
            ? l10n.validationRequired
            : !Validators.isValidEmail(_emailController.text)
            ? l10n.validationInvalidEmail
            : null;
    final passwordError = !Validators.isRequired(_passwordController.text) ? l10n.validationRequired : null;

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

    // On success the router's redirect (watching authControllerProvider)
    // navigates to the role's home — this screen never navigates itself.
    // Leaving it disposes the AutofillGroup, which commits the credentials
    // so the platform password manager offers to save them.
    if (result case ResultFailure(:final failure)) {
      setState(() => _formError = _messageFor(failure, l10n));
    }
  }

  /// A 401 here means wrong credentials, not an expired session.
  String _messageFor(Failure failure, AppLocalizations l10n) => switch (failure) {
    UnauthorizedFailure() => l10n.errorInvalidCredentials,
    _ => failure.localizedMessage(l10n),
  };

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
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(alignment: AlignmentDirectional.centerEnd, child: LanguageSwitchButton()),
                    const Center(
                      child: IconBadge(
                        icon: Icons.gavel_rounded,
                        backgroundColor: AppColors.navy,
                        iconColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.authLoginTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      l10n.authLoginSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      controller: _emailController,
                      label: l10n.authEmailLabel,
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _passwordController,
                      label: l10n.authPasswordLabel,
                      errorText: _passwordError,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      autofillHints: const [AutofillHints.password],
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => context.push(RoutePaths.forgotPassword),
                        child: Text(l10n.authForgotPassword),
                      ),
                    ),
                    AuthFormError(_formError),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(label: l10n.authLoginSubmit, isLoading: _isSubmitting, onPressed: _submit),
                    const SizedBox(height: AppSpacing.lg),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(l10n.authNoAccount, style: Theme.of(context).textTheme.bodyMedium),
                          TextButton(
                            onPressed: () => context.push(RoutePaths.register),
                            child: Text(l10n.authCreateAccount),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
