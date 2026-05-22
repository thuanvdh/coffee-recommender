import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/core/network/api_error_mapper.dart';
import 'package:coffee_recommender/core/result/app_failure.dart';

void main() {
  RequestOptions requestOptions() => RequestOptions(path: '/shops');

  test('maps connection timeout to timeout failure', () {
    final error = DioException(
      requestOptions: requestOptions(),
      type: DioExceptionType.connectionTimeout,
    );

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.timeout);
  });

  test('maps 401 to unauthorized failure', () {
    final error = DioException(
      requestOptions: requestOptions(),
      response: Response(statusCode: 401, requestOptions: requestOptions()),
    );

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.unauthorized);
  });

  test('maps 500 to server failure with status code', () {
    final error = DioException(
      requestOptions: requestOptions(),
      response: Response(statusCode: 500, requestOptions: requestOptions()),
    );

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.server);
    expect(failure.statusCode, 500);
  });

  test('maps cancellation with response to unknown failure', () {
    final error = DioException(
      requestOptions: requestOptions(),
      response: Response(statusCode: 500, requestOptions: requestOptions()),
      type: DioExceptionType.cancel,
    );

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.unknown);
  });
}
