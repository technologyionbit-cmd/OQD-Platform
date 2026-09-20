import 'package:aqd_ionbit/features/gov_documents/domain/entities/gov_procedure.dart';

/// Wire-level contract for the gov-documents feature. Mirrors
/// `LawyersRemoteDataSource` — throws a `Failure` on any failure path,
/// never a raw exception.
abstract interface class GovDocumentsRemoteDataSource {
  Future<List<GovProcedure>> getGovProcedures({required String locale});

  Future<GovProcedureProgress> getProgress(GovProcedureType type);

  Future<GovProcedureProgress> updateProgress(GovProcedureType type, {String? toggleDocumentId, bool? start});
}
