class AppConfig {
  final String _apiBaseUrl;
  final String environment;

  const AppConfig({
    required String apiBaseUrl,
    required this.environment,
  }) : _apiBaseUrl = apiBaseUrl;

  const AppConfig.development()
      : _apiBaseUrl = 'http://localhost:8000/api/',
        environment = 'development';

  String get apiBaseUrl =>
      _apiBaseUrl.endsWith('/') ? _apiBaseUrl : '$_apiBaseUrl/';

  factory AppConfig.fromEnvironment() {
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8000/api/',
    );
    const environment = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );
    return const AppConfig(apiBaseUrl: apiBaseUrl, environment: environment);
  }
}
