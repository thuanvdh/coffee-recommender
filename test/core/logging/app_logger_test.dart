import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/core/logging/app_logger.dart';

void main() {
  final originalDebugPrint = debugPrint;
  final logs = <String>[];

  setUp(() {
    logs.clear();
    debugPrint = (String? message, {int? wrapWidth}) {
      logs.add(message ?? '');
    };
  });

  tearDown(() {
    debugPrint = originalDebugPrint;
  });

  test('debug prints message', () {
    const logger = AppLogger();

    logger.debug('message');

    expect(logs, contains('message'));
  });

  test('debug prints message with error and stack trace', () {
    const logger = AppLogger();
    final error = StateError('failed');
    final stackTrace = StackTrace.current;

    logger.debug('message', error, stackTrace);

    expect(logs, contains('message: Bad state: failed'));
    expect(logs, contains(stackTrace.toString()));
  });
}
