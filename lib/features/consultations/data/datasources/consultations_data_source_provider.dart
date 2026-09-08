import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_mock_data_source.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_remote_data_source.dart';

/// The ONE place that decides which [ConsultationsRemoteDataSource]
/// implementation the app runs against. Swapping in a real backend later
/// means changing only this file.
final consultationsRemoteDataSourceProvider = Provider<ConsultationsRemoteDataSource>((ref) => ConsultationsMockDataSource());
