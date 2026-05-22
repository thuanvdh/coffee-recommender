import 'package:dio/dio.dart';
import 'package:coffee_recommender/core/config/app_config.dart';

class DioClient {
  final Dio _dio;
  final AppConfig config;

  DioClient(
    this._dio, {
    this.config = const AppConfig.development(),
  }) {
    _dio.options.baseUrl = config.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers['Accept'] = 'application/json';
  }

  String get baseUrl => config.apiBaseUrl;
  Dio get dio => _dio;
}
