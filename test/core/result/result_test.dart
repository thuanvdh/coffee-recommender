import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/core/result/app_failure.dart';
import 'package:coffee_recommender/core/result/result.dart';

void main() {
  test('success maps value', () {
    final result = const Result<int>.success(2).map((value) => value * 3);

    expect(result.isSuccess, true);
    expect(result.valueOrNull, 6);
  });

  test('failure keeps typed failure', () {
    const failure = AppFailure.timeout();
    const result = Result<int>.failure(failure);

    expect(result.isFailure, true);
    expect(result.failureOrNull, failure);
    expect(failure.userMessage, 'Ket noi qua cham. Hay thu lai.');
  });
}
