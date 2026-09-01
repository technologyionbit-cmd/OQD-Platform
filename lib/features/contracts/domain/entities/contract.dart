import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/contracts/domain/entities/contract_category.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_status.dart';

part 'contract.freezed.dart';

@freezed
abstract class Contract with _$Contract {
  const factory Contract({
    required String id,
    required String title,
    required ContractCategory category,
    required ContractStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<String> parties,
    required Map<String, String> fieldValues,
    required String templateId,
    required String generatedContent,
  }) = _Contract;
}
