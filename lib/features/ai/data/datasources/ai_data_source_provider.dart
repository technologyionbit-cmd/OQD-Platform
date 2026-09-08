import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/ai/data/datasources/ai_mock_data_source.dart';
import 'package:aqd_ionbit/features/ai/data/datasources/ai_remote_data_source.dart';

/// The ONE place that decides which [AiRemoteDataSource] implementation
/// the app runs against. Swapping in a real AI provider later means
/// changing only this file — per the current phase's scope rule, that
/// swap is explicitly out of scope for now.
final aiRemoteDataSourceProvider = Provider<AiRemoteDataSource>((ref) => AiMockDataSource());
