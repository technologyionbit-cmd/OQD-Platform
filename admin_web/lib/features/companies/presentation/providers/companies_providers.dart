import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/core/models/paged_result.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/features/companies/domain/company.dart';

/// `/admin/companies`. Throws a `Failure` on error.
class CompaniesRepository {
  CompaniesRepository(this._dio);

  final Dio _dio;

  Future<PagedResult<Company>> list(CompaniesQuery query) => _guard(() async {
        final response = await _dio.get<Map<String, dynamic>>('/admin/companies', queryParameters: query.toParams());
        return PagedResult.fromJson(response.data!, Company.fromJson);
      });

  Future<void> verify(String id) => _guard(() => _dio.post<void>('/admin/companies/$id/verify'));

  Future<void> reject(String id, {required String reason}) => _guard(() => _dio.post<void>('/admin/companies/$id/reject', data: {'reason': reason}));

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw mapToFailure(error);
    }
  }
}

final companiesRepositoryProvider = Provider<CompaniesRepository>((ref) => CompaniesRepository(ref.watch(apiClientProvider).dio));

class CompaniesQueryController extends Notifier<CompaniesQuery> {
  @override
  CompaniesQuery build() => const CompaniesQuery();

  void _filter(CompaniesQuery next) => state = next.copyWith(page: 1);

  void setSearch(String value) => _filter(state.copyWith(search: value));
  void setVerification(String? value) => _filter(state.copyWith(verification: () => value));
  void setLimit(int value) => _filter(state.copyWith(limit: value));
  void sortBy(String key, {required bool ascending}) => _filter(state.copyWith(sort: key, ascending: ascending));
  void clearFilters() => _filter(CompaniesQuery(limit: state.limit, sort: state.sort, ascending: state.ascending));
  void setPage(int page) => state = state.copyWith(page: page);
}

final companiesQueryProvider = NotifierProvider<CompaniesQueryController, CompaniesQuery>(CompaniesQueryController.new);

final companiesPageProvider = FutureProvider.autoDispose<PagedResult<Company>>(
  (ref) => ref.watch(companiesRepositoryProvider).list(ref.watch(companiesQueryProvider)),
);
