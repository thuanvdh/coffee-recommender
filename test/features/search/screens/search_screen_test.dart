import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/domain/models/ranked_shop.dart';
import 'package:coffee_recommender/features/search/domain/models/search_filter.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_recommender/features/search/presentation/screens/search_screen.dart';
import 'package:coffee_recommender/features/search/presentation/screens/shop_detail_screen.dart';
import 'package:coffee_recommender/features/search/presentation/providers/search_notifier.dart';
import 'package:coffee_recommender/features/search/presentation/widgets/shop_card.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../helpers/test_helpers.dart';

class RecordingSearchNotifier extends SearchNotifier {
  RecordingSearchNotifier({SearchState? initialState})
      : super(DioClient(Dio())) {
    state = initialState ?? SearchState(shops: const [], isLoading: false);
  }

  final searchedIntents = <SearchIntent>[];
  var didClearFilters = false;

  @override
  Future<void> fetchShops() async {}

  @override
  void clearFilters() {
    didClearFilters = true;
    state = SearchState.initial();
  }

  void emitProviderRebuild({required String query}) {
    state = state.copyWith(
      searchQuery: query,
      isLoading: !state.isLoading,
    );
  }

  @override
  Future<void> search(SearchIntent intent, {SearchFilter? filter}) async {
    searchedIntents.add(intent);
    state = state.copyWith(
      status: SearchStateStatus.empty,
      intent: intent,
      searchQuery: intent.query,
      rankedShops: const [],
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

  testWidgets('SearchScreen preserves focused edits during provider rebuild',
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
    await tester.pump();

    await tester.tap(find.byType(SearchBar));
    await tester.enterText(find.byType(EditableText), 'latte draft');
    await tester.pump();

    notifier.emitProviderRebuild(query: 'espresso');
    await tester.pump();

    final editableText = tester.widget<EditableText>(find.byType(EditableText));
    expect(editableText.controller.text, 'latte draft');
  });

  testWidgets('SearchScreen shows typed empty state with clear action',
      (WidgetTester tester) async {
    final notifier = RecordingSearchNotifier(
      initialState: SearchState(
        status: SearchStateStatus.empty,
        rankedShops: const [],
        shops: const [],
        isLoading: false,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchNotifierProvider.overrideWith((ref) => notifier),
        ],
        child: const MaterialApp(
          home: SearchScreen(),
        ),
      ),
    );

    expect(find.text('Không tìm thấy quán nào'), findsOneWidget);

    await tester.tap(find.text('Xóa bộ lọc'));
    await tester.pump();

    expect(notifier.didClearFilters, isTrue);
  });

  testWidgets('SearchScreen renders match reasons on ranked shop cards',
      (WidgetTester tester) async {
    final notifier = RecordingSearchNotifier(
      initialState: SearchState(
        status: SearchStateStatus.success,
        rankedShops: [
          RankedShop(
            shop: _shop,
            score: 20,
            matchReasons: ['Có máy lạnh', 'WiFi mạnh', 'Gửi xe'],
          ),
        ],
        shops: [_shop],
        isLoading: false,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchNotifierProvider.overrideWith((ref) => notifier),
        ],
        child: const MaterialApp(
          home: SearchScreen(),
        ),
      ),
    );

    expect(find.text('Goc Yen Binh'), findsOneWidget);
    expect(find.text('Có máy lạnh'), findsOneWidget);
    expect(find.text('WiFi mạnh'), findsOneWidget);
    expect(find.text('Gửi xe'), findsNothing);
  });

  testWidgets('SearchScreen shop card passes initial shop to detail route',
      (WidgetTester tester) async {
    final notifier = RecordingSearchNotifier(
      initialState: SearchState(
        status: SearchStateStatus.success,
        rankedShops: [
          RankedShop(
            shop: _shop,
            score: 20,
            matchReasons: ['Có máy lạnh'],
          ),
        ],
        shops: [_shop],
        isLoading: false,
      ),
    );
    Object? capturedExtra;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/shop/:slug',
          builder: (context, state) {
            capturedExtra = state.extra;
            return const SizedBox.shrink();
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchNotifierProvider.overrideWith((ref) => notifier),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -360));
    await tester.pump();
    await tester.tap(find.byType(ShopCard));
    await tester.pump();

    final extra = capturedExtra;
    expect(extra, isA<ShopDetailRouteExtra>());
    final detailExtra = extra! as ShopDetailRouteExtra;
    expect(detailExtra.initialShop, _shop);
    expect(detailExtra.matchReasons, ['Có máy lạnh']);
  });

  testWidgets('SearchScreen ranked list is always scrollable for refresh',
      (WidgetTester tester) async {
    final notifier = RecordingSearchNotifier(
      initialState: SearchState(
        status: SearchStateStatus.success,
        rankedShops: [
          RankedShop(
            shop: _shop,
            score: 20,
            matchReasons: ['Có máy lạnh'],
          ),
        ],
        shops: [_shop],
        isLoading: false,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchNotifierProvider.overrideWith((ref) => notifier),
        ],
        child: const MaterialApp(
          home: SearchScreen(),
        ),
      ),
    );

    final listViews = tester.widgetList<ListView>(find.byType(ListView));
    expect(
      listViews.any(
        (listView) => listView.physics is AlwaysScrollableScrollPhysics,
      ),
      isTrue,
    );
  });

  testWidgets('SearchScreen filter sheet toggles open-now filter',
      (WidgetTester tester) async {
    final notifier = RecordingSearchNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchNotifierProvider.overrideWith((ref) => notifier),
        ],
        child: const MaterialApp(
          home: SearchScreen(),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    expect(find.text('Đang mở'), findsOneWidget);

    await tester.tap(find.text('Đang mở'));
    await tester.pump();

    expect(notifier.debugState.openNow, isTrue);
  });

  testWidgets('SearchScreen shows stale indicator with ranked shops',
      (WidgetTester tester) async {
    final notifier = RecordingSearchNotifier(
      initialState: SearchState(
        status: SearchStateStatus.stale,
        rankedShops: [
          RankedShop(
            shop: _shop,
            score: 10,
            matchReasons: ['Có máy lạnh'],
          ),
        ],
        shops: [_shop],
        error: 'Không thể tải kết quả mới',
        isLoading: false,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchNotifierProvider.overrideWith((ref) => notifier),
        ],
        child: const MaterialApp(
          home: SearchScreen(),
        ),
      ),
    );

    expect(find.text('Không thể tải kết quả mới'), findsOneWidget);
    expect(find.text('Goc Yen Binh'), findsOneWidget);
  });
}

final _shop = CoffeeShop.fromJson(const {
  'id': 1,
  'name': 'Goc Yen Binh',
  'slug': 'goc-yen-binh',
  'address': '12 Nguyen Van Linh',
  'status': 'open',
  'purposes': ['Làm việc'],
  'amenities': ['Máy lạnh'],
  'spaces': ['Yên tĩnh'],
  'created_at': '2026-05-22T00:00:00Z',
  'updated_at': '2026-05-22T00:00:00Z',
});
