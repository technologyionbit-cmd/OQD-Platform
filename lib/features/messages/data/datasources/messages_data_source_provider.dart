import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/messages/data/datasources/messages_mock_data_source.dart';
import 'package:aqd_ionbit/features/messages/data/datasources/messages_remote_data_source.dart';

/// The ONE place that decides which [MessagesRemoteDataSource]
/// implementation the app runs against. Swapping in a real backend later
/// means changing only this file.
final messagesRemoteDataSourceProvider = Provider<MessagesRemoteDataSource>((ref) => MessagesMockDataSource());
