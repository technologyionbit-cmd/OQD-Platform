import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/config/app_config.dart';

void main() {
  test('defaults to the deployed API unless API_BASE_URL is defined', () {
    final config = AppConfig.resolve();

    expect(config.apiBaseUrl, 'https://oqdjo.com/v1');
  });
}
