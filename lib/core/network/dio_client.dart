import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;
  final String baseUrl = 'http://localhost:8000/api/';

  DioClient(this._dio) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Dio get dio => _dio;
}
