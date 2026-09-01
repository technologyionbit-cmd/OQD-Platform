import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field_type.dart';

part 'contract_field.freezed.dart';

/// One field in a [ContractTemplate]. [label]/[hint]/[options] are template
/// *content* — same category as a template's title, meant to come from a
/// backend that already localizes it per request, not from the app's own
/// ARB files (see [ContractTemplate] doc).
@freezed
abstract class ContractField with _$ContractField {
  const factory ContractField({
    required String id,
    required String label,
    required ContractFieldType type,
    required bool isRequired,
    @Default(<String>[]) List<String> options,
    String? hint,
  }) = _ContractField;
}
