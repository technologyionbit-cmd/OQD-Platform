import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/theme/app_colors.dart';

class _Weather {
  const _Weather(this.temp, this.code, this.isDay);
  final int temp;
  final int code;
  final bool isDay;
}

/// Current weather for Amman from Open-Meteo (free, no key, no user data
/// sent — fixed coordinates). Uses its own bare Dio so the app's auth
/// interceptors and base URL are not involved. Any failure resolves to
/// null and the badge simply hides.
final _weatherProvider = FutureProvider.autoDispose<_Weather?>((ref) async {
  try {
    final res = await Dio(BaseOptions(connectTimeout: const Duration(seconds: 5), receiveTimeout: const Duration(seconds: 5))).get<Map<String, dynamic>>(
      'https://api.open-meteo.com/v1/forecast',
      queryParameters: {'latitude': 31.95, 'longitude': 35.93, 'current': 'temperature_2m,weather_code,is_day'},
    );
    final c = res.data?['current'] as Map<String, dynamic>?;
    if (c == null) return null;
    return _Weather((c['temperature_2m'] as num).round(), (c['weather_code'] as num).toInt(), c['is_day'] == 1);
  } catch (_) {
    return null;
  }
});

/// "20° ☀" chip shown on the auth landing screen, like Sanad's.
class WeatherBadge extends ConsumerWidget {
  const WeatherBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(_weatherProvider).asData?.value;
    if (w == null) return const SizedBox.shrink();
    final (icon, color) = switch (w.code) {
      0 || 1 => w.isDay ? (Icons.wb_sunny_rounded, const Color(0xFFF5B301)) : (Icons.nightlight_round, AppColors.steelBlue),
      2 || 3 => (Icons.cloud_rounded, AppColors.textDisabled),
      45 || 48 => (Icons.foggy, AppColors.textDisabled),
      >= 51 && <= 67 || >= 80 && <= 82 => (Icons.water_drop_rounded, AppColors.primary),
      >= 71 && <= 77 || 85 || 86 => (Icons.ac_unit_rounded, AppColors.primary),
      >= 95 => (Icons.thunderstorm_rounded, AppColors.secondary),
      _ => (Icons.cloud_rounded, AppColors.textDisabled),
    };
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${w.temp}°', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(width: 6),
          Icon(icon, color: color, size: 28),
        ],
      ),
    );
  }
}
