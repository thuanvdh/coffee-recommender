import 'package:coffee_recommender/core/logging/app_logger.dart';
import 'package:coffee_recommender/features/home/data/repositories/weather_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class SilentLogger extends AppLogger {
  const SilentLogger();

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {}
}

void main() {
  late MockDio dio;
  late WeatherRepository repository;

  setUp(() {
    dio = MockDio();
    repository = WeatherRepository(dio: dio, logger: const SilentLogger());
  });

  group('WeatherRepository', () {
    test('fetchCurrentWeather returns temp and code from Open-Meteo response',
        () async {
      when(
        () => dio.get<dynamic>(
          any(),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          data: {
            'current_weather': {
              'temperature': 31.2,
              'weathercode': 3,
            },
          },
          requestOptions: RequestOptions(path: 'weather'),
          statusCode: 200,
        ),
      );

      final weather = await repository.fetchCurrentWeather();

      expect(weather, {'temp': 31.2, 'code': 3});
    });

    test('fetchCurrentWeather returns fallback when request fails', () async {
      when(
        () => dio.get<dynamic>(
          any(),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException.connectionError(
          requestOptions: RequestOptions(path: 'weather'),
          reason: 'offline',
        ),
      );

      final weather = await repository.fetchCurrentWeather();

      expect(weather, {'temp': 28.5, 'code': 1});
    });
  });
}
