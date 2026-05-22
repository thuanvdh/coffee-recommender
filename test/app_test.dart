import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_recommender/app.dart';
import 'helpers/test_helpers.dart';

void main() {
  testWidgets('App starts and displays home message', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestOverrides(),
        child: const CoffeeApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
