import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/contracts/domain/entities/contract_category.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field.dart';

part 'contract_template.freezed.dart';

/// [title] is template *content*, not app chrome — in a real backend this
/// comes back already localized for the request's `Accept-Language`, so it
/// isn't an ARB string. The mock data source stands in for that by
/// building a different template list per [Locale] (see
/// `ContractsMockDataSource`), not by routing template text through l10n.
@freezed
abstract class ContractTemplate with _$ContractTemplate {
  const factory ContractTemplate({
    required String id,
    required ContractCategory category,
    required String title,
    required List<ContractField> fields,
  }) = _ContractTemplate;
}
