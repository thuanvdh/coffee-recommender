import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/app.dart';

void main() {
  testWidgets('App starts and displays home message', (WidgetTester tester) async {
    await tester.pumpWidget(const CoffeeApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
