import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/core/config/app_config.dart';

void main() {
  test('development config uses local API by default', () {
    const config = AppConfig.development();

    expect(config.environment, 'development');
    expect(config.apiBaseUrl, 'http://localhost:8000/api/');
  });

  test('custom config normalizes trailing slash', () {
    const config = AppConfig(
      apiBaseUrl: 'https://api.example.com/api',
      environment: 'test',
    );

    expect(config.apiBaseUrl, 'https://api.example.com/api/');
  });
}
