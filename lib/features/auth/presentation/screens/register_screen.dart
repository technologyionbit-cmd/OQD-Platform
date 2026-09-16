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
import 'package:aqd_ionbit/core/widgets/app_dropdown.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_form_error.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_scaffold.dart';

/// The 8 backend `LawyerSpecialty` values, paired with their localization
/// key. Kept here (not imported from the lawyers feature) so auth stays
/// self-contained — the backend is the authority on the accepted set.
const _specialties = <String>[
  'commercial',
  'personalStatus',
  'criminal',
  'labor',
  'realEstate',
  'corporate',
  'intellectualProperty',
  'general',
];

String _specialtyLabel(String value, AppLocalizations l10n) => switch (value) {
  'commercial' => l10n.specialtyCommercial,
  'personalStatus' => l10n.specialtyPersonalStatus,
  'criminal' => l10n.specialtyCriminal,
  'labor' => l10n.specialtyLabor,
  'realEstate' => l10n.specialtyRealEstate,
  'corporate' => l10n.specialtyCorporate,
  'intellectualProperty' => l10n.specialtyIntellectualProperty,
  _ => l10n.specialtyGeneral,
};

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  UserRole _role = UserRole.client;
  String? _specialty;

  final _fullNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
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
    _registrationNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectRole(UserRole role) {
    setState(() {
      _role = role;
      _errors.clear();
      _formError = null;
    });
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
        errors['specialty'] = _specialty == null ? l10n.validationRequired : null;
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
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    return switch (_role) {
      UserRole.client => RegisterRequest.individual(
        fullName: _fullNameController.text.trim(),
        phone: phone,
        email: email,
        password: password,
      ),
      UserRole.company => RegisterRequest.company(
        companyName: _companyNameController.text.trim(),
        commercialRegistrationNumber: _registrationNumberController.text.trim(),
        email: email,
        phone: phone,
        password: password,
      ),
      UserRole.lawyer => RegisterRequest.lawyer(
        fullName: _fullNameController.text.trim(),
        barLicenseNumber: _licenseNumberController.text.trim(),
        mainSpecialty: _specialty!,
        email: email,
        phone: phone,
        password: password,
      ),
    };
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();
    if (!_validate(l10n)) return;

    setState(() => _isSubmitting = true);
    final result = await ref.read(authControllerProvider.notifier).register(_buildRequest());
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Router redirect reacts to authControllerProvider on success.
    result.fold((failure) => setState(() => _applyFailure(failure, l10n)), (_) {});
  }

  void _applyFailure(Failure failure, AppLocalizations l10n) {
    if (failure case ValidationFailure(:final fieldErrors) when fieldErrors.isNotEmpty) {
      // Surface field-level errors (e.g. "email already registered") on the
      // right input; map backend field names to this form's keys.
      const fieldMap = {
        'commercialRegistrationNumber': 'registrationNumber',
        'barLicenseNumber': 'licenseNumber',
        'mainSpecialty': 'specialty',
      };
      var matchedAField = false;
      fieldErrors.forEach((backendField, messages) {
        final key = fieldMap[backendField] ?? backendField;
        _errors[key] = messages.first;
        matchedAField = true;
      });
      _formError = matchedAField ? null : fieldErrors.values.first.first;
      return;
    }
    _formError = switch (failure) {
      NetworkFailure() => l10n.errorNetwork,
      TimeoutFailure() => l10n.errorTimeout,
      ServerFailure() => l10n.errorServer,
      _ => l10n.errorGeneric,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AuthScaffold(
      icon: Icons.shield_outlined,
      title: l10n.authRegisterTitle,
      subtitle: l10n.authRegisterSubtitle,
      child: AutofillGroup(
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
                    onTap: () => _selectRole(UserRole.lawyer),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AppChip(
                    label: l10n.authAccountTypeCompany,
                    icon: Icons.apartment_outlined,
                    selected: _role == UserRole.company,
                    onTap: () => _selectRole(UserRole.company),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AppChip(
                    label: l10n.authAccountTypeIndividual,
                    icon: Icons.person_outline,
                    selected: _role == UserRole.client,
                    onTap: () => _selectRole(UserRole.client),
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
            AuthFormError(_formError),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: l10n.authRegisterSubmit, isLoading: _isSubmitting, onPressed: _submit),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(l10n.authAlreadyHaveAccount, style: Theme.of(context).textTheme.bodyMedium),
                  TextButton(onPressed: () => context.go(RoutePaths.login), child: Text(l10n.authLoginTitle)),
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
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.name],
    );

    final roleFields = switch (role) {
      UserRole.client => <Widget>[nameField],
      UserRole.company => <Widget>[
        AppTextField(
          controller: _companyNameController,
          label: l10n.authCompanyName,
          errorText: _errors['companyName'],
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _registrationNumberController,
          label: l10n.authCommercialRegistrationNumber,
          errorText: _errors['registrationNumber'],
          textInputAction: TextInputAction.next,
        ),
      ],
      UserRole.lawyer => <Widget>[
        nameField,
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _licenseNumberController,
          label: l10n.authBarLicenseNumber,
          errorText: _errors['licenseNumber'],
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.md),
        AppDropdown<String>(
          label: l10n.authMainSpecialty,
          value: _specialty,
          items: _specialties,
          itemLabel: (value) => _specialtyLabel(value, l10n),
          errorText: _errors['specialty'],
          onChanged: (value) => setState(() {
            _specialty = value;
            _errors['specialty'] = null;
          }),
        ),
      ],
    };

    return [
      ...roleFields,
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        controller: _phoneController,
        label: l10n.authPhoneLabel,
        errorText: _errors['phone'],
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.telephoneNumber],
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        controller: _emailController,
        label: l10n.authEmailLabel,
        errorText: _errors['email'],
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.email],
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        controller: _passwordController,
        label: l10n.authPasswordLabel,
        errorText: _errors['password'],
        obscureText: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        autofillHints: const [AutofillHints.newPassword],
      ),
    ];
  }
}
