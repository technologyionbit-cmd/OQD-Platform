import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/failure_message.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/verification_status.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/providers/my_lawyer_profile_provider.dart';

/// Server-side limits (backend/src/auth/dto/name.rules.ts).
const _personNameMaxLength = 120;
const _companyNameMaxLength = 160;

/// Shared by client/lawyer/company — edits the fields every role actually
/// has (`AuthUser.fullName`/`email`); the lawyer's specialty/bio/pricing
/// fields live on their own `LawyerProfile` and are edited separately, see
/// `LawyerProfileEditScreen`. Every save needs the current password. A
/// verified lawyer is warned that a new name sends the account back to
/// review.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final Map<String, String?> _errors = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).value;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _nameChanged => _nameController.text.trim() != (ref.read(authControllerProvider).value?.fullName ?? '');

  /// Compared the way the server stores it (trimmed, lower-case).
  bool get _emailChanged =>
      _emailController.text.trim().toLowerCase() != (ref.read(authControllerProvider).value?.email ?? '').toLowerCase();

  bool get _isDirty => _nameChanged || _emailChanged;

  bool _validate(AppLocalizations l10n) {
    final errors = <String, String?>{};
    errors['fullName'] = Validators.isRequired(_nameController.text) ? null : l10n.validationRequired;
    errors['email'] = Validators.isValidEmail(_emailController.text) ? null : l10n.validationInvalidEmail;
    errors['currentPassword'] = _passwordController.text.isEmpty ? l10n.validationRequired : null;
    setState(() => _errors
      ..clear()
      ..addAll(errors));
    return errors.values.every((e) => e == null);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_validate(l10n)) return;
    final renamed = _nameChanged;
    setState(() => _isSaving = true);
    final result = await ref
        .read(authControllerProvider.notifier)
        .updateProfile(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          currentPassword: _passwordController.text,
        );
    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold((failure) => _showFailure(failure, l10n), (user) {
      // The marketplace copy of a lawyer's name (and possibly their
      // verification state) changed with it.
      if (renamed && user.role == UserRole.lawyer) ref.invalidate(myLawyerProfileProvider);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileUpdatedMessage)));
      context.pop();
    });
  }

  /// Puts each failure under the field it is about; anything else becomes
  /// a snackbar with the shared wording.
  void _showFailure(Failure failure, AppLocalizations l10n) {
    _passwordController.clear();
    final fieldErrors = <String, String>{
      if (failure case Failure(code: ApiErrorCodes.emailAlreadyRegistered)) 'email': failure.localizedMessage(l10n),
      if (failure case ValidationFailure(code: ApiErrorCodes.validationError, :final fieldErrors))
        for (final field in fieldErrors.keys)
          if (_fieldMessage(field, l10n) case final message?) field: message,
    };
    if (fieldErrors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.localizedMessage(l10n))));
    }
    setState(() => _errors
      ..clear()
      ..addAll(fieldErrors));
  }

  String? _fieldMessage(String field, AppLocalizations l10n) => switch (field) {
    'currentPassword' => l10n.errorCurrentPasswordIncorrect,
    'fullName' => l10n.validationRequired,
    'email' => l10n.validationInvalidEmail,
    _ => null,
  };

  Future<bool> _confirmDiscard() async {
    if (!_isDirty) return true;
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.unsavedChangesTitle),
        content: Text(l10n.unsavedChangesMessage),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.unsavedChangesDiscard)),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authControllerProvider).value;
    final isLawyer = user?.role == UserRole.lawyer;
    final lawyerVerified = isLawyer && ref.watch(myLawyerProfileProvider).value?.verificationStatus == VerificationStatus.verified;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.editProfileTitle)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              AppTextField(
                controller: _nameController,
                label: l10n.authFullName,
                errorText: _errors['fullName'],
                maxLength: user?.role == UserRole.company ? _companyNameMaxLength : _personNameMaxLength,
                onChanged: (_) => setState(() {}),
              ),
              if (lawyerVerified && _nameChanged) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.editProfileLawyerRenameWarning,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.statusColors.warning.foreground),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _emailController,
                label: l10n.authEmailLabel,
                keyboardType: TextInputType.emailAddress,
                errorText: _errors['email'],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _passwordController,
                label: l10n.securityCurrentPasswordLabel,
                helperText: l10n.editProfilePasswordHelper,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                errorText: _errors['currentPassword'],
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppButton(label: l10n.commonSave, isLoading: _isSaving, onPressed: _isSaving || !_isDirty ? null : _save),
          ),
        ),
      ),
    );
  }
}
