import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/documents/data/datasources/documents_mock_data_source.dart';
import 'package:aqd_ionbit/features/documents/data/datasources/documents_remote_data_source.dart';

/// The ONE place that decides which [DocumentsRemoteDataSource]
/// implementation the app runs against.
final documentsRemoteDataSourceProvider = Provider<DocumentsRemoteDataSource>((ref) => DocumentsMockDataSource());
