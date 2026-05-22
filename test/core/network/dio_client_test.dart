import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/core/config/app_config.dart';
import 'package:coffee_recommender/core/network/dio_client.dart';

void main() {
  test('DioClient applies config base URL and timeouts', () {
    final dio = Dio();
    final client = DioClient(
      dio,
      config: const AppConfig(
          apiBaseUrl: 'https://api.example.com/api', environment: 'test'),
    );

    expect(client.baseUrl, 'https://api.example.com/api/');
    expect(client.dio.options.baseUrl, 'https://api.example.com/api/');
    expect(client.dio.options.connectTimeout, const Duration(seconds: 10));
    expect(client.dio.options.receiveTimeout, const Duration(seconds: 10));
    expect(client.dio.options.headers['Accept'], 'application/json');
  });
}
