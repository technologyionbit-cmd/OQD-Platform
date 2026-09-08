import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_bottom_sheet.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/app_chip.dart';
import 'package:aqd_ionbit/core/widgets/signature_pad.dart';
import 'package:aqd_ionbit/features/profile/domain/entities/saved_signature.dart';
import 'package:aqd_ionbit/features/profile/presentation/providers/saved_signature_controller.dart';

enum _SignTab { saved, upload, draw }

/// The reference's e-signature step (saved / upload / draw, legal consent,
/// green confirm) as a bottom sheet — reuses the same [SignaturePad] and
/// [savedSignatureControllerProvider] the Account → Saved Signature screen
/// manages, so a signature saved there is immediately usable here. Returns
/// `true` once the user taps confirm; the caller is responsible for
/// actually marking the contract signed.
Future<bool?> showContractSignatureSheet(BuildContext context) {
  return showAppBottomSheet<bool>(context, isScrollControlled: true, builder: (sheetContext) => const _ContractSignatureSheetContent());
}

class _ContractSignatureSheetContent extends ConsumerStatefulWidget {
  const _ContractSignatureSheetContent();

  @override
  ConsumerState<_ContractSignatureSheetContent> createState() => _ContractSignatureSheetContentState();
}

class _ContractSignatureSheetContentState extends ConsumerState<_ContractSignatureSheetContent> {
  late _SignTab _tab = ref.read(savedSignatureControllerProvider).hasSignature ? _SignTab.saved : _SignTab.draw;
  List<List<Offset>> _strokes = [];
  Uint8List? _uploadedBytes;

  bool _canConfirm(SavedSignatureState saved) {
    return switch (_tab) {
      _SignTab.saved => saved.hasSignature,
      _SignTab.upload => _uploadedBytes != null,
      _SignTab.draw => _strokes.isNotEmpty,
    };
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() => _uploadedBytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final saved = ref.watch(savedSignatureControllerProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.contractSignTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppChip(
                label: l10n.contractSignTabSaved,
                selected: _tab == _SignTab.saved,
                onTap: saved.hasSignature ? () => setState(() => _tab = _SignTab.saved) : null,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: AppChip(label: l10n.savedSignatureTabUpload, selected: _tab == _SignTab.upload, onTap: () => setState(() => _tab = _SignTab.upload)),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: AppChip(label: l10n.savedSignatureTabDraw, selected: _tab == _SignTab.draw, onTap: () => setState(() => _tab = _SignTab.draw)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        switch (_tab) {
          _SignTab.saved => SizedBox(
            height: 140,
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: !saved.hasSignature
                  ? Center(
                      child: Text(l10n.contractSignNoSavedSignature, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                    )
                  : switch (saved.type!) {
                      SavedSignatureType.drawn => SignaturePad(strokes: saved.strokes, onStrokesChanged: (_) {}, readOnly: true),
                      SavedSignatureType.typed => Center(
                        child: Text(
                          saved.typedText ?? '',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SavedSignatureType.uploaded => saved.imageBytes == null
                          ? Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.image_outlined, color: AppColors.textSecondary),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(l10n.savedSignatureUploadedLabel, style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            )
                          : Image.memory(saved.imageBytes!, fit: BoxFit.contain),
                    },
            ),
          ),
          _SignTab.upload => SizedBox(
            height: 140,
            child: AppCard(
              onTap: _pickImage,
              padding: EdgeInsets.zero,
              child: Center(
                child: _uploadedBytes == null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_upload_outlined, size: 32, color: AppColors.textSecondary),
                          const SizedBox(height: AppSpacing.xs),
                          Text(l10n.savedSignatureUploadPlaceholder, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: AppRadii.mdRadius,
                        child: Image.memory(_uploadedBytes!, height: 140, width: double.infinity, fit: BoxFit.contain),
                      ),
              ),
            ),
          ),
          _SignTab.draw => SizedBox(
            height: 140,
            child: AppCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: AppRadii.mdRadius,
                child: SignaturePad(strokes: _strokes, onStrokesChanged: (s) => setState(() => _strokes = s)),
              ),
            ),
          ),
        },
        if (_tab == _SignTab.draw) ...[
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(onPressed: () => setState(() => _strokes = []), child: Text(l10n.savedSignatureClear)),
          ),
        ] else if (_tab == _SignTab.upload && _uploadedBytes != null) ...[
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(onPressed: () => setState(() => _uploadedBytes = null), child: Text(l10n.savedSignatureClear)),
          ),
        ] else
          const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(color: context.statusColors.warning.background, borderRadius: AppRadii.mdRadius),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: AppColors.secondary, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: Text(l10n.contractSignLegalNotice, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.secondary))),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: l10n.contractSignConfirm,
          variant: AppButtonVariant.success,
          onPressed: _canConfirm(saved) ? () => Navigator.of(context).pop(true) : null,
        ),
      ],
    );
  }
}
