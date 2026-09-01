import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/locale_controller.dart';
import 'package:aqd_ionbit/features/contracts/data/repositories/contracts_repository_impl.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_template.dart';

/// Re-fetches whenever the app locale changes — with a real backend this
/// would be a fresh request carrying the new `Accept-Language`; the mock
/// simulates that by keying its content off the same [Locale].
final contractTemplatesProvider = FutureProvider<List<ContractTemplate>>((ref) async {
  final locale = ref.watch(localeControllerProvider);
  final repository = ref.watch(contractsRepositoryProvider);
  final result = await repository.getTemplates(locale: locale);
  return result.fold((failure) => throw failure, (templates) => templates);
});
