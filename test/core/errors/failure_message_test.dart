import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/failure_message.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations_ar.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations_en.dart';

void main() {
  final ar = AppLocalizationsAr();
  final en = AppLocalizationsEn();

  test('rate limiting states the wait in whole minutes, rounded up', () {
    expect(const RateLimitedFailure(retryAfter: Duration(seconds: 30)).localizedMessage(en), 'Too many attempts, try again in 1 minute');
    expect(const RateLimitedFailure(retryAfter: Duration(seconds: 61)).localizedMessage(en), 'Too many attempts, try again in 2 minutes');
    expect(const RateLimitedFailure(retryAfter: Duration(minutes: 15)).localizedMessage(en), 'Too many attempts, try again in 15 minutes');
  });

  test('uses correct Arabic plural forms', () {
    expect(const RateLimitedFailure(retryAfter: Duration(minutes: 1)).localizedMessage(ar), contains('بعد دقيقة'));
    expect(const RateLimitedFailure(retryAfter: Duration(minutes: 2)).localizedMessage(ar), contains('بعد دقيقتين'));
    expect(const RateLimitedFailure(retryAfter: Duration(minutes: 5)).localizedMessage(ar), contains('بعد 5 دقائق'));
    expect(const RateLimitedFailure(retryAfter: Duration(minutes: 15)).localizedMessage(ar), contains('بعد 15 دقيقة'));
  });

  test('rate limiting without a known wait has a generic message', () {
    expect(const RateLimitedFailure().localizedMessage(en), en.errorTooManyAttempts);
  });

  test('an inactive account is explained, whatever the status class', () {
    expect(const ForbiddenFailure(code: ApiErrorCodes.accountInactive).localizedMessage(en), en.errorAccountInactive);
  });

  test('never shows the raw backend message', () {
    const failure = ForbiddenFailure(message: 'Internal English text', code: 'SOMETHING_ELSE');
    expect(failure.localizedMessage(ar), ar.errorGeneric);
  });
}
