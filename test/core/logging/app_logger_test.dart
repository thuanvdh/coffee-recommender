import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/core/logging/app_logger.dart';

void main() {
  test('debug can be called without throwing', () {
    const logger = AppLogger();

    expect(() => logger.debug('message'), returnsNormally);
  });

  test('debug can be called with error and stack trace without throwing', () {
    const logger = AppLogger();
    final error = StateError('failed');
    final stackTrace = StackTrace.current;

    expect(() => logger.debug('message', error, stackTrace), returnsNormally);
  });
}
