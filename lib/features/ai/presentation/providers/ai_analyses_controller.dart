import 'dart:async';

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/localization/locale_controller.dart';
import 'package:aqd_ionbit/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/contract_analysis.dart';
import 'package:aqd_ionbit/features/ai/domain/repositories/ai_repository.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';
import 'package:aqd_ionbit/features/notifications/presentation/providers/notifications_controller.dart';

class AiAnalysesController extends AsyncNotifier<List<ContractAnalysis>> {
  late final AiRepository _repository;

  @override
  FutureOr<List<ContractAnalysis>> build() async {
    _repository = ref.watch(aiRepositoryProvider);
    final result = await _repository.getAnalyses();
    return result.fold((failure) => throw failure, (analyses) => analyses);
  }

  Future<void> refresh() async {
    final result = await _repository.getAnalyses();
    state = result.fold((failure) => AsyncError(failure, StackTrace.current), (analyses) => AsyncData(analyses));
  }

  Future<Result<ContractAnalysis>> analyzeDocument({required String documentTitle, String? sourceDocumentId}) async {
    final result = await _repository.analyzeDocument(documentTitle: documentTitle, sourceDocumentId: sourceDocumentId);
    if (result.isSuccess) {
      await refresh();
      final analysis = result.valueOrNull!;
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
            type: NotificationType.aiAnalysisCompleted,
            title: l10n.notificationAiAnalysisTitle,
            body: l10n.notificationAiAnalysisBody(documentTitle),
            relatedId: analysis.id,
            // Self-notification — the client who requested the analysis.
            recipientUserId: ref.read(authControllerProvider).value?.id,
          );
    }
    return result;
  }
}

final aiAnalysesControllerProvider = AsyncNotifierProvider<AiAnalysesController, List<ContractAnalysis>>(AiAnalysesController.new);

final aiAnalysisByIdProvider = Provider.autoDispose.family<ContractAnalysis?, String>(
  (ref, id) => ref.watch(aiAnalysesControllerProvider).value?.where((a) => a.id == id).firstOrNull,
);
