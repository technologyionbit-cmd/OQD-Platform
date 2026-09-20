import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/gov_documents/domain/entities/gov_procedure.dart';

abstract interface class GovDocumentsRepository {
  Future<Result<List<GovProcedure>>> getGovProcedures({required String locale});

  Future<Result<GovProcedureProgress>> getProgress(GovProcedureType type);

  Future<Result<GovProcedureProgress>> toggleDocument(GovProcedureType type, String documentId);

  Future<Result<GovProcedureProgress>> start(GovProcedureType type);
}
