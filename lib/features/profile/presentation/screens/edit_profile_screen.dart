import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';

/// Shared by client/lawyer/company — edits the fields every role actually
/// has (`AuthUser.fullName`/`email`); the lawyer's specialty/bio/pricing
/// fields live on her own `LawyerProfile` and are edited separately, see
/// `LawyerProfileEditScreen`.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final Map<String, String?> _errors = {};
  bool _isSaving = false;
  bool _isDirty = false;

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
    super.dispose();
  }

  bool _validate(AppLocalizations l10n) {
    final errors = <String, String?>{};
    errors['name'] = Validators.isRequired(_nameController.text) ? null : l10n.validationRequired;
    errors['email'] = Validators.isValidEmail(_emailController.text) ? null : l10n.validationInvalidEmail;
    setState(() => _errors
      ..clear()
      ..addAll(errors));
    return errors.values.every((e) => e == null);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_validate(l10n)) return;
    setState(() => _isSaving = true);
    final result = await ref
        .read(authControllerProvider.notifier)
        .updateProfile(fullName: _nameController.text.trim(), email: _emailController.text.trim());
    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric))),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileUpdatedMessage)));
        context.pop();
      },
    );
  }

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
                errorText: _errors['name'],
                onChanged: (_) => setState(() => _isDirty = true),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _emailController,
                label: l10n.authEmailLabel,
                keyboardType: TextInputType.emailAddress,
                errorText: _errors['email'],
                onChanged: (_) => setState(() => _isDirty = true),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppButton(label: l10n.commonSave, isLoading: _isSaving, onPressed: _isSaving ? null : _save),
          ),
        ),
      ),
    );
  }
}
