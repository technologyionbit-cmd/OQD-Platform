import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_bottom_sheet.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/app_chip.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/lawyers/data/repositories/lawyers_repository_impl.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_specialty.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/providers/lawyer_by_id_provider.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/providers/lawyers_controller.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/consultation_type_x.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/lawyer_specialty_x.dart';

/// Edits the demo lawyer's own `LawyerProfile` — specialty/bio/experience/
/// consultation types & pricing/verification. Deliberately separate from
/// `EditProfileScreen`, which only ever touches `AuthUser` fields shared
/// across all three roles.
class LawyerProfileEditScreen extends ConsumerWidget {
  const LawyerProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lawyerState = ref.watch(lawyerByIdProvider(kDemoLawyerId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lawyerEditProfileTitle)),
      body: switch (lawyerState) {
        AsyncData(value: final lawyer) => _EditForm(lawyer: lawyer),
        AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.invalidate(lawyerByIdProvider(kDemoLawyerId))),
        _ => const LoadingView(),
      },
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.lawyer});

  final LawyerProfile lawyer;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  late final TextEditingController _bioController;
  late final TextEditingController _experienceController;
  late Set<LawyerSpecialty> _specialties;
  late Set<ConsultationType> _consultationTypes;
  late Map<ConsultationType, TextEditingController> _priceControllers;
  bool _isSaving = false;
  bool _isSubmittingVerification = false;
  String? _bioError;
  String? _experienceError;
  Map<ConsultationType, String?> _priceErrors = {};

  @override
  void initState() {
    super.initState();
    final lawyer = widget.lawyer;
    _bioController = TextEditingController(text: lawyer.bio);
    _experienceController = TextEditingController(text: lawyer.yearsOfExperience.toString());
    _specialties = lawyer.specialties.toSet();
    _consultationTypes = lawyer.consultationTypes.toSet();
    _priceControllers = {
      for (final type in ConsultationType.values)
        type: TextEditingController(text: (lawyer.pricing[type] ?? 0).toStringAsFixed(0)),
    };
  }

  @override
  void dispose() {
    _bioController.dispose();
    _experienceController.dispose();
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Returns the parsed years-of-experience on success, populating the
  /// per-field/general error state (shown inline via `AppTextField.errorText`
  /// for bio/experience/price, via a snackbar for the specialty/type
  /// selections since those aren't single-field inputs) and returning null
  /// if anything fails.
  int? _validate(AppLocalizations l10n) {
    final bio = _bioController.text.trim();
    final experience = int.tryParse(_experienceController.text.trim());
    final priceErrors = <ConsultationType, String?>{};
    for (final type in _consultationTypes) {
      final price = double.tryParse(_priceControllers[type]!.text.trim());
      if (price == null || price <= 0) priceErrors[type] = l10n.lawyerPriceRequiredError;
    }

    setState(() {
      _bioError = bio.isEmpty ? l10n.lawyerBioRequiredError : null;
      _experienceError = experience == null || experience < 0 ? l10n.lawyerExperienceInvalidError : null;
      _priceErrors = priceErrors;
    });

    if (_specialties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.lawyerSelectSpecialtyError)));
      return null;
    }
    if (_consultationTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.lawyerSelectConsultationTypeError)));
      return null;
    }
    if (_bioError != null || _experienceError != null || priceErrors.isNotEmpty) return null;
    return experience;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final experience = _validate(l10n);
    if (experience == null) return;

    setState(() => _isSaving = true);
    final updated = widget.lawyer.copyWith(
      bio: _bioController.text.trim(),
      yearsOfExperience: experience,
      specialties: _specialties.toList(),
      consultationTypes: _consultationTypes.toList(),
      pricing: {for (final type in _consultationTypes) type: double.parse(_priceControllers[type]!.text.trim())},
    );

    final repository = ref.read(lawyersRepositoryProvider);
    final result = await repository.updateProfile(updated);
    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold((failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric))), (_) {
      ref.invalidate(lawyerByIdProvider(kDemoLawyerId));
      ref.read(lawyersControllerProvider.notifier).refresh();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileUpdatedMessage)));
      context.pop();
    });
  }

  // Mock verification flow — no real document is ever uploaded/sent
  // anywhere. `image_picker` (already a dependency, used the same way by
  // the e-signature upload flow) stands in for "pick a document", the
  // bottom sheet lets the lawyer confirm what they picked, and "submitting"
  // it just flips `hasPendingVerification` via the same `updateProfile`
  // repository call the rest of this form already uses — persisted only in
  // the in-memory mock data source, for the current app session.
  Future<void> _uploadVerificationDocument() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null || !mounted) return; // user cancelled — not an error
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      final confirmed = await _showDocumentPreviewSheet(bytes, l10n);
      if (confirmed != true || !mounted) return;
      await _submitVerificationDocument(l10n);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.chatImagePickError)));
    }
  }

  Future<bool?> _showDocumentPreviewSheet(Uint8List bytes, AppLocalizations l10n) {
    return showAppBottomSheet<bool>(
      context,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.lawyerVerificationDocumentPreviewTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(borderRadius: AppRadii.mdRadius, child: Image.memory(bytes, height: 220, fit: BoxFit.contain)),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l10n.commonCancel,
                    variant: AppButtonVariant.outlined,
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: AppButton(label: l10n.commonUpload, onPressed: () => Navigator.of(sheetContext).pop(true))),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitVerificationDocument(AppLocalizations l10n) async {
    setState(() => _isSubmittingVerification = true);
    final repository = ref.read(lawyersRepositoryProvider);
    final result = await repository.updateProfile(widget.lawyer.copyWith(hasPendingVerification: true));
    if (!mounted) return;
    setState(() => _isSubmittingVerification = false);

    result.fold((failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric))), (_) {
      ref.invalidate(lawyerByIdProvider(kDemoLawyerId));
      ref.read(lawyersControllerProvider.notifier).refresh();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.lawyerVerificationSubmittedMessage)));
    });
  }

  String _verificationStatusLabel(AppLocalizations l10n) {
    if (widget.lawyer.isVerified) return l10n.lawyerVerified;
    if (widget.lawyer.hasPendingVerification) return l10n.lawyerPendingVerification;
    return l10n.lawyerNotVerified;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              AppCard(
                child: Row(
                  children: [
                    Icon(
                      widget.lawyer.isVerified
                          ? Icons.verified
                          : widget.lawyer.hasPendingVerification
                          ? Icons.hourglass_empty
                          : Icons.error_outline,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(l10n.lawyerVerificationSectionTitle, style: Theme.of(context).textTheme.bodyMedium),
                    const Spacer(),
                    // The badge alone carries the status text (it already
                    // ellipsizes internally) — a separate label repeating
                    // the same text left too little room at narrow widths.
                    Flexible(
                      child: StatusBadge(
                        label: _verificationStatusLabel(l10n),
                        tone: widget.lawyer.isVerified
                            ? AppStatusTone.success
                            : widget.lawyer.hasPendingVerification
                            ? AppStatusTone.warning
                            : AppStatusTone.neutral,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (!widget.lawyer.isVerified && !widget.lawyer.hasPendingVerification)
                AppButton(
                  label: l10n.lawyerUploadVerificationDocument,
                  icon: Icons.upload_file_outlined,
                  variant: AppButtonVariant.outlined,
                  isLoading: _isSubmittingVerification,
                  onPressed: _isSubmittingVerification ? null : _uploadVerificationDocument,
                ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(controller: _bioController, label: l10n.lawyerAboutTitle, maxLines: 4, errorText: _bioError),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _experienceController,
                label: l10n.lawyerExperienceTitle,
                keyboardType: TextInputType.number,
                errorText: _experienceError,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.lawyerSpecialtiesTitle, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xxs,
                runSpacing: AppSpacing.xxs,
                children: [
                  for (final specialty in LawyerSpecialty.values)
                    AppChip(
                      label: specialty.label(l10n),
                      selected: _specialties.contains(specialty),
                      onTap: () => setState(() {
                        if (!_specialties.remove(specialty)) _specialties.add(specialty);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.lawyerConsultationTypesTitle, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              for (final type in ConsultationType.values) ...[
                Row(
                  children: [
                    Checkbox(
                      value: _consultationTypes.contains(type),
                      onChanged: (checked) => setState(() {
                        if (checked ?? false) {
                          _consultationTypes.add(type);
                        } else {
                          _consultationTypes.remove(type);
                        }
                      }),
                    ),
                    Expanded(child: Text(type.label(l10n))),
                    if (_consultationTypes.contains(type))
                      SizedBox(
                        width: 100,
                        child: AppTextField(
                          controller: _priceControllers[type]!,
                          label: l10n.lawyerPriceLabel,
                          keyboardType: TextInputType.number,
                          errorText: _priceErrors[type],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppButton(label: l10n.commonSave, isLoading: _isSaving, onPressed: _isSaving ? null : _save),
          ),
        ),
      ],
    );
  }
}
