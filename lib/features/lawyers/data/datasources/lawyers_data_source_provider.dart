import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_mock_data_source.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_remote_data_source.dart';

/// The ONE place that decides which [LawyersRemoteDataSource]
/// implementation the app runs against. Swapping in a real backend later
/// means changing only this file.
final lawyersRemoteDataSourceProvider = Provider<LawyersRemoteDataSource>((ref) => LawyersMockDataSource());
