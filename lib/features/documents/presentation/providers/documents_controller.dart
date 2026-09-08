import 'dart:async';

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/localization/locale_controller.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/documents/data/repositories/documents_repository_impl.dart';
import 'package:aqd_ionbit/features/documents/domain/entities/document.dart';
import 'package:aqd_ionbit/features/documents/domain/repositories/documents_repository.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';
import 'package:aqd_ionbit/features/notifications/presentation/providers/notifications_controller.dart';

class DocumentsController extends AsyncNotifier<List<Document>> {
  late final DocumentsRepository _repository;

  @override
  FutureOr<List<Document>> build() async {
    _repository = ref.watch(documentsRepositoryProvider);
    final result = await _repository.getDocuments();
    return result.fold((failure) => throw failure, (documents) => documents);
  }

  Future<void> refresh() async {
    final result = await _repository.getDocuments();
    state = result.fold((failure) => AsyncError(failure, StackTrace.current), (documents) => AsyncData(documents));
  }

  /// Called from the contracts feature once a contract is generated — see
  /// `ContractDraftController.generate`.
  Future<void> addFromGeneratedContract({required String contractId, required String title}) async {
    final result = await _repository.addGeneratedContractDocument(contractId: contractId, title: title);
    if (result.isSuccess) await refresh();
  }

  Future<Result<Document>> upload(String title) async {
    final result = await _repository.uploadDocument(title: title);
    if (result.isSuccess) {
      await refresh();
      Locale locale;
      try {
        locale = ref.read(localeControllerProvider);
      } catch (_) {
        locale = const Locale('ar');
      }
      final l10n = await AppLocalizations.delegate.load(locale);
      await ref
          .read(notificationsControllerProvider.notifier)
          .create(
            type: NotificationType.documentUploaded,
            title: l10n.notificationDocumentUploadedTitle,
            body: l10n.notificationDocumentUploadedBody(title),
            // Self-notification — whoever is signed in did the uploading,
            // regardless of role (this feature is shared across all three).
            recipientUserId: ref.read(authControllerProvider).value?.id,
          );
    }
    return result;
  }

  Future<Result<Document>> rename({required String id, required String newTitle}) async {
    final result = await _repository.renameDocument(id: id, newTitle: newTitle);
    if (result.isSuccess) await refresh();
    return result;
  }

  Future<Result<void>> delete(String id) async {
    final result = await _repository.deleteDocument(id);
    if (result.isSuccess) await refresh();
    return result;
  }
}

final documentsControllerProvider = AsyncNotifierProvider<DocumentsController, List<Document>>(DocumentsController.new);
