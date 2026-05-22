import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/features/search/domain/models/search_filter.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_recommender/features/search/presentation/screens/search_screen.dart';
import 'package:coffee_recommender/features/search/presentation/providers/search_notifier.dart';
import 'package:dio/dio.dart';
import '../../../helpers/test_helpers.dart';

class RecordingSearchNotifier extends SearchNotifier {
  RecordingSearchNotifier() : super(DioClient(Dio())) {
    state = SearchState(shops: const [], isLoading: false);
  }

  final searchedIntents = <SearchIntent>[];

  @override
  Future<void> fetchShops() async {}

  @override
  Future<void> search(SearchIntent intent, {SearchFilter? filter}) async {
    searchedIntents.add(intent);
    state = state.copyWith(
      intent: intent,
      searchQuery: intent.query,
      shops: const [],
      isLoading: false,
    );
  }
}

void main() {
  testWidgets('SearchScreen renders SearchBar and Filter chips button',
      (WidgetTester tester) async {
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

  testWidgets('SearchScreen shows initial query in SearchBar field',
      (WidgetTester tester) async {
    final notifier = RecordingSearchNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchNotifierProvider.overrideWith((ref) => notifier),
        ],
        child: MaterialApp(
          home: SearchScreen(
            initialIntent: SearchIntent(query: 'espresso'),
          ),
        ),
      ),
    );

    expect(find.text('espresso'), findsOneWidget);
  });

  testWidgets('SearchScreen searches when initial intent changes',
      (WidgetTester tester) async {
    final notifier = RecordingSearchNotifier();
    final overrides = [
      searchNotifierProvider.overrideWith((ref) => notifier),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          home: SearchScreen(
            initialIntent: SearchIntent(query: 'first'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(notifier.searchedIntents, hasLength(1));
    expect(notifier.searchedIntents.single.query, 'first');

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          home: SearchScreen(
            initialIntent: SearchIntent(query: 'second'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(notifier.searchedIntents, hasLength(2));
    expect(notifier.searchedIntents.last.query, 'second');
    expect(find.text('second'), findsOneWidget);
  });
}
