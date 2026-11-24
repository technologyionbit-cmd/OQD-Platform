import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/config/app_config.dart';
import 'package:aqd_admin/core/network/api_client.dart';
import 'package:aqd_admin/core/network/session_store.dart';

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.resolve());

final sessionStoreProvider = Provider<SessionStore>((ref) => SessionStore());

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(config: ref.watch(appConfigProvider), session: ref.watch(sessionStoreProvider)),
);
