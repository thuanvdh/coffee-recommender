import 'package:coffee_recommender/core/logging/app_logger.dart';
import 'package:dio/dio.dart';

class WeatherRepository {
  WeatherRepository({
    Dio? dio,
    AppLogger logger = const AppLogger(),
  })  : _dio = dio ?? Dio(),
        _logger = logger;

  final Dio _dio;
  final AppLogger _logger;

  Future<Map<String, dynamic>> fetchCurrentWeather() async {
    try {
      final response = await _dio.get<dynamic>(
        'https://api.open-meteo.com/v1/forecast?latitude=16.0544&longitude=108.2022&current_weather=true',
        options: Options(receiveTimeout: const Duration(seconds: 3)),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw const FormatException('Invalid weather response');
        }
        final current = data['current_weather'];
        if (current is! Map<String, dynamic>) {
          throw const FormatException('Invalid current weather response');
        }
        return {
          'temp': (current['temperature'] as num).toDouble(),
          'code': (current['weathercode'] as num).toInt(),
        };
      }
    } catch (error, stack) {
      _logger.debug('Weather fetch failed', error, stack);
    }
    return const {'temp': 28.5, 'code': 1};
  }
}
