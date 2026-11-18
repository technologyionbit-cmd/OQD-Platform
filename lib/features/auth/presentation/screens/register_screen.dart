import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/config/app_config.dart';
import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/failure_message.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/utils/jordan_mobile.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/core/widgets/phone_field.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';
import 'package:aqd_ionbit/features/auth/presentation/password_rules.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_form_error.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/sanad_auth_page.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/sanad_button.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/password_strength_meter.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/terms_consent_field.dart';

/// Backend field name -> this form's error key, where they differ.
const _fieldKeys = {'acceptTerms': 'terms', 'termsVersion': 'terms'};

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _acceptedTerms = false;

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final Map<String, String?> _errors = {};
  String? _formError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate(AppLocalizations l10n) {
    final errors = <String, String?>{};

    void requireField(String key, TextEditingController controller) {
      errors[key] =
          Validators.isRequired(controller.text)
              ? null
              : l10n.validationRequired;
    }

    requireField('fullName', _fullNameController);

    errors['phone'] =
        Validators.isValidJordanMobile(_phoneController.text)
            ? null
            : l10n.validationInvalidJordanMobile;
    errors['email'] =
        !Validators.isRequired(_emailController.text)
            ? l10n.validationRequired
            : !Validators.isValidEmail(_emailController.text)
            ? l10n.validationInvalidEmail
            : null;
    errors['password'] = newPasswordError(_passwordController.text, l10n);
    errors['terms'] = _acceptedTerms ? null : l10n.validationTermsRequired;

    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
      _formError = null;
    });
    return errors.values.every((error) => error == null);
  }

  RegisterRequest _buildRequest() {
    // Validated before this runs, so it normalizes.
    final phone =
        JordanMobile.normalize(_phoneController.text) ??
        _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    const termsVersion = AppConfig.termsVersion;

    return RegisterRequest.individual(
      fullName: _fullNameController.text.trim(),
      phone: phone,
      email: email,
      password: password,
      acceptTerms: _acceptedTerms,
      termsVersion: termsVersion,
    );
  }

  Future<void> _submit() async {
    // The keyboard's "done" action bypasses the button's disabled state.
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();
    if (!_validate(l10n)) return;

    setState(() => _isSubmitting = true);
    final result = await ref
        .read(authControllerProvider.notifier)
        .register(_buildRequest());
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // On success the router (watching authControllerProvider) moves on to
    // phone verification — this screen never navigates itself.
    if (result case ResultFailure(:final failure)) {
      setState(() => _applyFailure(failure, l10n));
    }
  }

  /// Puts each server error on its field, in the user's language. Server
  /// text is never shown: a known code picks the message, and any other
  /// field error gets a generic one for that field.
  void _applyFailure(Failure failure, AppLocalizations l10n) {
    final codeField = switch (failure.code) {
      ApiErrorCodes.emailAlreadyRegistered => 'email',
      ApiErrorCodes.phoneAlreadyRegistered => 'phone',
      _ => null,
    };
    if (codeField != null) {
      _errors[codeField] = failure.localizedMessage(l10n);
      return;
    }

    if (failure case ValidationFailure(
      code: ApiErrorCodes.validationError,
      :final fieldErrors,
    ) when fieldErrors.isNotEmpty) {
      final visible = _visibleFieldKeys();
      var shownOnAField = false;
      for (final backendField in fieldErrors.keys) {
        final key = _fieldKeys[backendField] ?? backendField;
        if (!visible.contains(key)) continue;
        _errors[key] = _genericFieldMessage(key, l10n);
        shownOnAField = true;
      }
      if (shownOnAField) return;
    }
    _formError = failure.localizedMessage(l10n);
  }

  Set<String> _visibleFieldKeys() => {
    'fullName',
    'phone',
    'email',
    'password',
    'terms',
  };

  String _genericFieldMessage(String key, AppLocalizations l10n) =>
      switch (key) {
        'email' => l10n.validationInvalidEmail,
        'phone' => l10n.validationInvalidJordanMobile,
        'password' => l10n.authPasswordRulesHint,
        'terms' => l10n.validationTermsRequired,
        _ => l10n.validationInvalidValue,
      };

  Future<void> _openLink(String url) async {
    final opened = await ref.read(linkLauncherProvider)(Uri.parse(url));
    if (opened || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.errorLinkOpenFailed)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = ref.watch(appConfigProvider);

    return SanadAuthPage(
      title: l10n.authRegisterTitle,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._fields(l10n),
            const SizedBox(height: AppSpacing.sm),
            TermsConsentField(
              value: _acceptedTerms,
              errorText: _errors['terms'],
              onChanged:
                  (value) => setState(() {
                    _acceptedTerms = value;
                    if (value) _errors['terms'] = null;
                  }),
              onOpenTerms: () => _openLink(config.termsUrl),
              onOpenPrivacy: () => _openLink(config.privacyUrl),
            ),
            AuthFormError(_formError),
            const SizedBox(height: AppSpacing.lg),
            SanadButton(
              label: l10n.authRegisterSubmit,
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              children: [
                Text(
                  l10n.authAlreadyHaveAccount,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                GestureDetector(
                  onTap: () => context.go(RoutePaths.login),
                  child: Text(
                    l10n.authLoginTitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  List<Widget> _fields(AppLocalizations l10n) {
    return [
      AppTextField(
        controller: _fullNameController,
        label: l10n.authFullName,
        prefixIcon: Icons.person_outline_rounded,
        errorText: _errors['fullName'],
        maxLength: Validators.nameMaxLength,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.name],
      ),
      const SizedBox(height: AppSpacing.md),
      PhoneField(
        controller: _phoneController,
        label: l10n.authPhoneLabel,
        errorText: _errors['phone'],
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        controller: _emailController,
        label: l10n.authEmailLabel,
        prefixIcon: Icons.mail_outline_rounded,
        errorText: _errors['email'],
        maxLength: Validators.emailMaxLength,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.email],
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        controller: _passwordController,
        label: l10n.authPasswordLabel,
        prefixIcon: Icons.lock_rounded,
        errorText: _errors['password'],
        textDirection: Directionality.of(context),
        toggleLabels: (l10n.commonShow, l10n.commonHide),
        helperText: l10n.authPasswordRulesHint,
        obscureText: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        autofillHints: const [AutofillHints.newPassword],
      ),
      PasswordStrengthMeter(controller: _passwordController),
    ];
  }
}
