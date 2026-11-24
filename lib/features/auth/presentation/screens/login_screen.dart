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
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/core/widgets/phone_field.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_form_error.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/sanad_auth_page.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/sanad_button.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/biometric_lock.dart';

/// Phone number + password only. The account's role (returned by the backend)
/// decides which shell the router lands on — there is no role selector,
/// so a lawyer signing in goes to the lawyer app, a client to the client
/// app, automatically.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _phoneError;
  String? _passwordError;
  String? _formError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // The keyboard's "done" action bypasses the button's disabled state.
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    final phone = JordanMobile.normalize(_phoneController.text);
    final phoneError =
        !Validators.isRequired(_phoneController.text)
            ? l10n.validationRequired
            : phone == null
            ? l10n.validationInvalidJordanMobile
            : null;
    final passwordError =
        !Validators.isRequired(_passwordController.text)
            ? l10n.validationRequired
            : null;

    setState(() {
      _phoneError = phoneError;
      _passwordError = passwordError;
      _formError = null;
    });
    if (phone == null || passwordError != null) return;

    setState(() => _isSubmitting = true);
    final password = _passwordController.text;
    final result = await ref
        .read(authControllerProvider.notifier)
        .login(phone: phone, password: password);
    // Runs before the mounted check: a successful login makes the router
    // leave (and dispose) this screen immediately.
    if (result is Success) {
      await offerBiometricAfterLogin(ref, phone: phone, password: password);
    }
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
  String _messageFor(Failure failure, AppLocalizations l10n) =>
      switch (failure) {
        UnauthorizedFailure() => l10n.errorInvalidCredentials,
        _ => failure.localizedMessage(l10n),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    // Sanad-style login page: a centered title bar with a chevron, the two
    // fields at the top, a text "show" toggle on the password, the blue
    // button, then a one-line "create account" link.
    return SanadAuthPage(
      title: l10n.authLoginTitle,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PhoneField(
              controller: _phoneController,
              label: l10n.authPhoneLabel,
              errorText: _phoneError,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _passwordController,
              label: l10n.authPasswordLabel,
              prefixIcon: Icons.lock_rounded,
              errorText: _passwordError,
              obscureText: true,
              textDirection: Directionality.of(context),
              toggleLabels: (l10n.commonShow, l10n.commonHide),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              autofillHints: const [AutofillHints.password],
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => context.push(RoutePaths.forgotPassword),
                child: Text(
                  l10n.authForgotPassword,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            AuthFormError(_formError),
            const SizedBox(height: AppSpacing.lg),
            SanadButton(
              label: l10n.authLoginTitle,
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              children: [
                Text(l10n.authNoAccount, style: textTheme.bodyMedium),
                GestureDetector(
                  onTap: () => context.push(RoutePaths.register),
                  child: Text(
                    l10n.authCreateAccountShort,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
