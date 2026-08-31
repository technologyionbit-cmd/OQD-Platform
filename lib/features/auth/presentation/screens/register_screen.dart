import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_chip.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_header.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  UserRole _role = UserRole.client;

  final _fullNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final Map<String, String?> _errors = {};
  String? _formError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _companyNameController.dispose();
    _licenseNumberController.dispose();
    _specialtyController.dispose();
    _registrationNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate(AppLocalizations l10n) {
    final errors = <String, String?>{};

    void requireField(String key, TextEditingController controller) {
      errors[key] = Validators.isRequired(controller.text) ? null : l10n.validationRequired;
    }

    switch (_role) {
      case UserRole.client:
        requireField('fullName', _fullNameController);
      case UserRole.company:
        requireField('companyName', _companyNameController);
        requireField('registrationNumber', _registrationNumberController);
      case UserRole.lawyer:
        requireField('fullName', _fullNameController);
        requireField('licenseNumber', _licenseNumberController);
        requireField('specialty', _specialtyController);
    }

    errors['phone'] = Validators.isValidPhone(_phoneController.text) ? null : l10n.validationInvalidPhone;
    errors['email'] = !Validators.isRequired(_emailController.text)
        ? l10n.validationRequired
        : !Validators.isValidEmail(_emailController.text)
        ? l10n.validationInvalidEmail
        : null;
    errors['password'] = Validators.isPasswordLongEnough(_passwordController.text) ? null : l10n.validationPasswordTooShort;

    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
      _formError = null;
    });
    return errors.values.every((error) => error == null);
  }

  RegisterRequest _buildRequest() {
    return switch (_role) {
      UserRole.client => RegisterRequest.individual(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
      UserRole.company => RegisterRequest.company(
        companyName: _companyNameController.text.trim(),
        commercialRegistrationNumber: _registrationNumberController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      ),
      UserRole.lawyer => RegisterRequest.lawyer(
        fullName: _fullNameController.text.trim(),
        barLicenseNumber: _licenseNumberController.text.trim(),
        mainSpecialty: _specialtyController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      ),
    };
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_validate(l10n)) return;

    setState(() => _isSubmitting = true);
    final result = await ref.read(authControllerProvider.notifier).register(_buildRequest());
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold((failure) => setState(() => _formError = _messageFor(failure, l10n)), (_) {
      // Router redirect reacts to authControllerProvider once registered.
    });
  }

  String _messageFor(Failure failure, AppLocalizations l10n) {
    return switch (failure) {
      ValidationFailure(:final fieldErrors) when fieldErrors.isNotEmpty => fieldErrors.values.first.first,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(icon: Icons.shield_outlined, title: l10n.authRegisterTitle, subtitle: l10n.authRegisterSubtitle),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppChip(
                          label: l10n.authAccountTypeLawyer,
                          icon: Icons.gavel_outlined,
                          selected: _role == UserRole.lawyer,
                          onTap: () => setState(() => _role = UserRole.lawyer),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: AppChip(
                          label: l10n.authAccountTypeCompany,
                          icon: Icons.apartment_outlined,
                          selected: _role == UserRole.company,
                          onTap: () => setState(() => _role = UserRole.company),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: AppChip(
                          label: l10n.authAccountTypeIndividual,
                          icon: Icons.person_outline,
                          selected: _role == UserRole.client,
                          onTap: () => setState(() => _role = UserRole.client),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ..._fieldsFor(_role, l10n),
                  const SizedBox(height: AppSpacing.sm),
                  Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.bodySmall,
                      children: [
                        TextSpan(text: l10n.authTermsAgreementPrefix),
                        TextSpan(text: l10n.authTermsOfService, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        TextSpan(text: l10n.authTermsAgreementJoiner),
                        TextSpan(text: l10n.authPrivacyPolicy, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  if (_formError != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(_formError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(label: l10n.authRegisterSubmit, isLoading: _isSubmitting, onPressed: _submit),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(l10n.authAlreadyHaveAccount, style: Theme.of(context).textTheme.bodyMedium),
                        TextButton(onPressed: () => context.go(RoutePaths.login), child: Text(l10n.authLoginTitle)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _fieldsFor(UserRole role, AppLocalizations l10n) {
    final nameField = AppTextField(
      controller: _fullNameController,
      label: role == UserRole.lawyer ? l10n.authFullNameTriple : l10n.authFullName,
      errorText: _errors['fullName'],
    );

    final roleFields = switch (role) {
      UserRole.client => [nameField],
      UserRole.company => [
        AppTextField(controller: _companyNameController, label: l10n.authCompanyName, errorText: _errors['companyName']),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _registrationNumberController,
          label: l10n.authCommercialRegistrationNumber,
          errorText: _errors['registrationNumber'],
        ),
      ],
      UserRole.lawyer => [
        nameField,
        const SizedBox(height: AppSpacing.md),
        AppTextField(controller: _licenseNumberController, label: l10n.authBarLicenseNumber, errorText: _errors['licenseNumber']),
        const SizedBox(height: AppSpacing.md),
        AppTextField(controller: _specialtyController, label: l10n.authMainSpecialty, errorText: _errors['specialty']),
      ],
    };

    return [
      ...roleFields,
      const SizedBox(height: AppSpacing.md),
      AppTextField(controller: _phoneController, label: l10n.authPhoneLabel, errorText: _errors['phone'], keyboardType: TextInputType.phone),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        controller: _emailController,
        label: l10n.authEmailLabel,
        errorText: _errors['email'],
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        controller: _passwordController,
        label: l10n.authPasswordLabel,
        errorText: _errors['password'],
        obscureText: true,
        autofillHints: const [AutofillHints.newPassword],
      ),
    ];
  }
}
