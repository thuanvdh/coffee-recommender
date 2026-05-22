import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/core/router/app_router.dart';

import '../../helpers/test_helpers.dart';

void main() {
  test('AppRouter contains base routes', () {
    final router = appRouter;
    expect(router.configuration.routes.isNotEmpty, true);
  });

  testWidgets('AppRouter passes SearchIntent extra into SearchScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestOverrides(),
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );

    appRouter.go('/search', extra: SearchIntent(query: 'espresso'));
    await tester.pumpAndSettle();

    expect(find.text('espresso'), findsOneWidget);
  });
}
