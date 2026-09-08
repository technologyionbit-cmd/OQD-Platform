import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/app_chip.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/core/widgets/signature_pad.dart';
import 'package:aqd_ionbit/features/profile/domain/entities/saved_signature.dart';
import 'package:aqd_ionbit/features/profile/presentation/providers/saved_signature_controller.dart';

enum _SignatureTab { draw, upload, type }

/// Account → Saved Signature — mirrors the reference's three-tab
/// e-signature picker (draw / upload / type), but as a standalone "manage
/// my saved signature" screen rather than a mid-contract step.
class SavedSignatureScreen extends ConsumerStatefulWidget {
  const SavedSignatureScreen({super.key});

  @override
  ConsumerState<SavedSignatureScreen> createState() => _SavedSignatureScreenState();
}

class _SavedSignatureScreenState extends ConsumerState<SavedSignatureScreen> {
  _SignatureTab _tab = _SignatureTab.draw;
  List<List<Offset>> _strokes = [];
  Uint8List? _uploadedBytes;
  final _typedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final saved = ref.read(savedSignatureControllerProvider);
    if (saved.type == SavedSignatureType.drawn) _strokes = saved.strokes;
    if (saved.type == SavedSignatureType.uploaded) _uploadedBytes = saved.imageBytes;
    if (saved.type == SavedSignatureType.typed) _typedController.text = saved.typedText ?? '';
    if (saved.type != null) {
      _tab = switch (saved.type!) {
        SavedSignatureType.drawn => _SignatureTab.draw,
        SavedSignatureType.uploaded => _SignatureTab.upload,
        SavedSignatureType.typed => _SignatureTab.type,
      };
    }
  }

  @override
  void dispose() {
    _typedController.dispose();
    super.dispose();
  }

  bool get _canSave => switch (_tab) {
    _SignatureTab.draw => _strokes.isNotEmpty,
    _SignatureTab.upload => _uploadedBytes != null,
    _SignatureTab.type => _typedController.text.trim().isNotEmpty,
  };

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() => _uploadedBytes = bytes);
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(savedSignatureControllerProvider.notifier);
    switch (_tab) {
      case _SignatureTab.draw:
        if (_strokes.isEmpty) return;
        notifier.saveDrawn(_strokes);
      case _SignatureTab.upload:
        if (_uploadedBytes == null) return;
        notifier.saveUploaded(_uploadedBytes!);
      case _SignatureTab.type:
        if (_typedController.text.trim().isEmpty) return;
        notifier.saveTyped(_typedController.text.trim());
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.savedSignatureSavedMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final saved = ref.watch(savedSignatureControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.savedSignatureTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            if (saved.hasSignature) ...[
              AppCard(child: _SavedSignaturePreview(saved: saved)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.savedSignatureLastSaved(DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(saved.savedAt!)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Row(
              children: [
                Expanded(
                  child: AppChip(
                    label: l10n.savedSignatureTabDraw,
                    icon: Icons.draw_outlined,
                    selected: _tab == _SignatureTab.draw,
                    onTap: () => setState(() => _tab = _SignatureTab.draw),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AppChip(
                    label: l10n.savedSignatureTabUpload,
                    icon: Icons.image_outlined,
                    selected: _tab == _SignatureTab.upload,
                    onTap: () => setState(() => _tab = _SignatureTab.upload),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AppChip(
                    label: l10n.savedSignatureTabType,
                    icon: Icons.text_fields_outlined,
                    selected: _tab == _SignatureTab.type,
                    onTap: () => setState(() => _tab = _SignatureTab.type),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            switch (_tab) {
              _SignatureTab.draw => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      height: 220,
                      child: ClipRRect(
                        borderRadius: AppRadii.mdRadius,
                        child: SignaturePad(strokes: _strokes, onStrokesChanged: (s) => setState(() => _strokes = s)),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(onPressed: () => setState(() => _strokes = []), child: Text(l10n.savedSignatureClear)),
                  ),
                ],
              ),
              _SignatureTab.upload => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    onTap: _pickImage,
                    padding: EdgeInsets.zero,
                    child: Container(
                      height: 220,
                      alignment: Alignment.center,
                      child: _uploadedBytes == null
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.cloud_upload_outlined, size: 36, color: AppColors.textSecondary),
                                const SizedBox(height: AppSpacing.xs),
                                Text(l10n.savedSignatureUploadPlaceholder, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: AppRadii.mdRadius,
                              child: Image.memory(_uploadedBytes!, height: 220, width: double.infinity, fit: BoxFit.contain),
                            ),
                    ),
                  ),
                  if (_uploadedBytes != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(onPressed: () => setState(() => _uploadedBytes = null), child: Text(l10n.savedSignatureClear)),
                    ),
                  ],
                ],
              ),
              _SignatureTab.type => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(controller: _typedController, label: l10n.savedSignatureTypedHint, onChanged: (_) => setState(() {})),
                  const SizedBox(height: AppSpacing.md),
                  if (_typedController.text.trim().isNotEmpty)
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: Text(
                          _typedController.text,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                ],
              ),
            },
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: l10n.commonSave, onPressed: _canSave ? _save : null),
          ],
        ),
      ),
    );
  }
}

class _SavedSignaturePreview extends StatelessWidget {
  const _SavedSignaturePreview({required this.saved});

  final SavedSignatureState saved;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 100,
      child: switch (saved.type!) {
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
    );
  }
}
