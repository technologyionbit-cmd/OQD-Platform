import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/locale_controller.dart';
import 'package:aqd_ionbit/features/gov_documents/data/repositories/gov_documents_repository_impl.dart';
import 'package:aqd_ionbit/features/gov_documents/domain/entities/gov_procedure.dart';
import 'package:aqd_ionbit/features/gov_documents/domain/repositories/gov_documents_repository.dart';

/// The government-documents catalog, fetched from the backend
/// (docs/backend/01-domain-model.md §10) and re-fetched whenever the
/// active locale changes so `durationLabel`/document titles/step text
/// come back in the right language.
class GovProceduresController extends AsyncNotifier<List<GovProcedure>> {
  @override
  Future<List<GovProcedure>> build() async {
    final repository = ref.watch(govDocumentsRepositoryProvider);
    final locale = ref.watch(localeControllerProvider).languageCode;
    final result = await repository.getGovProcedures(locale: locale);
    return result.fold((failure) => throw failure, (procedures) => procedures);
  }

  Future<void> refresh() async {
    final repository = ref.read(govDocumentsRepositoryProvider);
    final locale = ref.read(localeControllerProvider).languageCode;
    final result = await repository.getGovProcedures(locale: locale);
    state = result.fold((failure) => AsyncError(failure, StackTrace.current), (procedures) => AsyncData(procedures));
  }
}

final govProceduresProvider = AsyncNotifierProvider<GovProceduresController, List<GovProcedure>>(GovProceduresController.new);

/// Per-procedure progress, backed by the real per-user backend record
/// (`UserGovProcedureProgress`) instead of resetting on every app restart.
/// Fetches all 4 known procedure types' progress up front — small, fixed
/// catalog, so N parallel single-procedure requests is simpler than a
/// dedicated bulk endpoint.
class GovProceduresProgressController extends AsyncNotifier<Map<GovProcedureType, GovProcedureProgress>> {
  late final GovDocumentsRepository _repository;

  @override
  Future<Map<GovProcedureType, GovProcedureProgress>> build() async {
    _repository = ref.watch(govDocumentsRepositoryProvider);
    final entries = await Future.wait(
      GovProcedureType.values.map((type) async {
        final result = await _repository.getProgress(type);
        return MapEntry(type, result.fold((_) => const GovProcedureProgress(), (progress) => progress));
      }),
    );
    return Map.fromEntries(entries);
  }

  Future<void> toggleDocument(GovProcedureType type, String documentId) async {
    final snapshot = state.value;
    if (snapshot == null) return;
    final before = snapshot[type] ?? const GovProcedureProgress();
    final checked = Set<String>.of(before.checkedDocumentIds);
    if (!checked.remove(documentId)) checked.add(documentId);

    // Optimistic update so the checkbox responds instantly.
    state = AsyncData({...snapshot, type: before.copyWith(checkedDocumentIds: checked)});

    final result = await _repository.toggleDocument(type, documentId);
    result.fold(
      (failure) {
        final current = state.value ?? snapshot;
        state = AsyncData({...current, type: before});
      },
      (progress) {
        final current = state.value ?? snapshot;
        state = AsyncData({...current, type: progress});
      },
    );
  }

  Future<void> start(GovProcedureType type) async {
    final snapshot = state.value;
    if (snapshot == null) return;
    final before = snapshot[type] ?? const GovProcedureProgress();

    state = AsyncData({...snapshot, type: before.copyWith(started: true)});

    final result = await _repository.start(type);
    result.fold(
      (failure) {
        final current = state.value ?? snapshot;
        state = AsyncData({...current, type: before});
      },
      (progress) {
        final current = state.value ?? snapshot;
        state = AsyncData({...current, type: progress});
      },
    );
  }
}

final govProceduresProgressControllerProvider =
    AsyncNotifierProvider<GovProceduresProgressController, Map<GovProcedureType, GovProcedureProgress>>(
      GovProceduresProgressController.new,
    );
