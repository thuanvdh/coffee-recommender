import 'package:dio/dio.dart';
import 'package:coffee_recommender/core/result/app_failure.dart';

class ApiErrorMapper {
  static AppFailure map(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        return _fromStatusCode(statusCode);
      }

      return switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          const AppFailure.timeout(),
        DioExceptionType.connectionError => const AppFailure.network(),
        DioExceptionType.badResponse =>
          _fromStatusCode(error.response?.statusCode),
        DioExceptionType.cancel ||
        DioExceptionType.badCertificate ||
        DioExceptionType.unknown =>
          const AppFailure.unknown(),
      };
    }
    return const AppFailure.unknown();
  }

  static AppFailure _fromStatusCode(int? statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return const AppFailure.unauthorized();
    }
    if (statusCode != null && statusCode >= 500) {
      return AppFailure.server(statusCode);
    }
    return const AppFailure.invalidData();
  }
}
