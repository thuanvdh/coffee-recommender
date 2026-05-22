import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger();

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint(error == null ? message : '$message: $error');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }
}
