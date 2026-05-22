import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/core/network/api_error_mapper.dart';
import 'package:coffee_recommender/core/result/app_failure.dart';

void main() {
  RequestOptions requestOptions() => RequestOptions(path: '/shops');

  DioException dioError(
    DioExceptionType type, {
    int? statusCode,
  }) {
    final options = requestOptions();
    return DioException(
      requestOptions: options,
      response: statusCode == null
          ? null
          : Response(statusCode: statusCode, requestOptions: options),
      type: type,
    );
  }

  test('maps connection timeout to timeout failure', () {
    final error = dioError(DioExceptionType.connectionTimeout);

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.timeout);
  });

  test('maps send timeout to timeout failure', () {
    final error = dioError(DioExceptionType.sendTimeout);

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.timeout);
  });

  test('maps receive timeout to timeout failure', () {
    final error = dioError(DioExceptionType.receiveTimeout);

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.timeout);
  });

  test('maps connection error to network failure', () {
    final error = dioError(DioExceptionType.connectionError);

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.network);
  });

  test('maps 401 to unauthorized failure', () {
    final error = dioError(DioExceptionType.badResponse, statusCode: 401);

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.unauthorized);
  });

  test('maps 403 to unauthorized failure', () {
    final error = dioError(DioExceptionType.badResponse, statusCode: 403);

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.unauthorized);
  });

  test('maps non-server bad response to invalid data failure', () {
    final error = dioError(DioExceptionType.badResponse, statusCode: 422);

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.invalidData);
  });

  test('maps 500 to server failure with status code', () {
    final error = dioError(DioExceptionType.badResponse, statusCode: 500);

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.server);
    expect(failure.statusCode, 500);
  });

  test('maps cancellation with response to unknown failure', () {
    final error = dioError(DioExceptionType.cancel, statusCode: 500);

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.unknown);
  });

  test('maps unknown with response to unknown failure', () {
    final error = dioError(DioExceptionType.unknown, statusCode: 500);

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.unknown);
  });

  test('maps bad certificate with response to unknown failure', () {
    final error = dioError(DioExceptionType.badCertificate, statusCode: 500);

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.unknown);
  });
}
