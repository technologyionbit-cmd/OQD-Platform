import 'package:dio/dio.dart';

import 'package:aqd_admin/core/errors/failure.dart';

/// Runs a request and turns any Dio error into a `Failure`, so screens
/// never see raw HTTP errors.
Future<T> apiCall<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (error) {
    throw mapToFailure(error);
  }
}

/// `{ data: ... }` envelope: the inner map.
Map<String, dynamic> dataOf(Response<Map<String, dynamic>> response) => response.data!['data'] as Map<String, dynamic>;
