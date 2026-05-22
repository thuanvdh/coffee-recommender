import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/core/router/app_router.dart';

void main() {
  test('AppRouter contains base routes', () {
    final router = appRouter;
    expect(router.configuration.routes.isNotEmpty, true);
  });
}
