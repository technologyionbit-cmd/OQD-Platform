import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/features/dashboard/domain/dashboard_summary.dart';

final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((ref) async {
  try {
    final response = await ref.watch(apiClientProvider).dio.get<Map<String, dynamic>>('/admin/dashboard/summary');
    return DashboardSummary.fromJson(response.data!['data'] as Map<String, dynamic>);
  } on DioException catch (error) {
    throw mapToFailure(error);
  }
});
