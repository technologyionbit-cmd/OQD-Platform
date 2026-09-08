import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/team/data/datasources/team_mock_data_source.dart';
import 'package:aqd_ionbit/features/team/data/datasources/team_remote_data_source.dart';

final teamRemoteDataSourceProvider = Provider<TeamRemoteDataSource>((ref) => TeamMockDataSource());
