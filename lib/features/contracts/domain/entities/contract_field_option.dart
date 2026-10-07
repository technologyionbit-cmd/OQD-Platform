import 'package:freezed_annotation/freezed_annotation.dart';

part 'contract_field_option.freezed.dart';

/// One choice of a dropdown [ContractField]. [value] is what a contract
/// stores and stays the same in every language; [label] is template
/// content in the requested language.
@freezed
abstract class ContractFieldOption with _$ContractFieldOption {
  const factory ContractFieldOption({required String value, required String label}) = _ContractFieldOption;
}
