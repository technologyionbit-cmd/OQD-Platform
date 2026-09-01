import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/contracts/data/datasources/contracts_mock_data_source.dart';
import 'package:aqd_ionbit/features/contracts/data/datasources/contracts_remote_data_source.dart';

/// The ONE place that decides which [ContractsRemoteDataSource]
/// implementation the app runs against — mirrors
/// `auth_data_source_provider.dart`. Swapping in a real backend later
/// means changing only this file.
final contractsRemoteDataSourceProvider = Provider<ContractsRemoteDataSource>((ref) => ContractsMockDataSource());
