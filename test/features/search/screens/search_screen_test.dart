import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_recommender/features/search/presentation/screens/search_screen.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  testWidgets('SearchScreen renders SearchBar and Filter chips button', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestOverrides(),
        child: const MaterialApp(
          home: SearchScreen(),
        ),
      ),
    );

    // Verify search bar is present
    expect(find.byType(SearchBar), findsOneWidget);

    // Verify filter action button exists
    expect(find.byIcon(Icons.filter_list), findsOneWidget);
  });
}
