import 'dart:async';

import 'package:coffee_recommender/core/result/app_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:coffee_recommender/features/search/presentation/screens/shop_detail_screen.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/shop_detail/data/repositories/shop_detail_repository.dart';
import 'package:coffee_recommender/features/shop_detail/presentation/controllers/shop_detail_controller.dart';
import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/core/result/result.dart';
import 'package:dio/dio.dart';

void main() {
  const mockShop = CoffeeShop(
    id: 1,
    name: 'Góc Yên Bình',
    slug: 'goc-yen-binh',
    address: '45 Lê Lợi, Hải Châu, Đà Nẵng',
    district: 'Hải Châu',
    phone: '02361234567',
    status: 'open',
    latitude: 16.0678,
    longitude: 108.2208,
    purposes: ['Làm việc', 'Đọc sách'],
    spaces: ['Máy lạnh'],
    amenities: ['WiFi mạnh'],
    createdAt: '2026-05-22T08:00:00Z',
    updatedAt: '2026-05-22T08:00:00Z',
  );

  testWidgets('ShopDetailScreen renders shop basic details and action buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shopDetailRepositoryProvider.overrideWith(
            (ref) => _FakeShopDetailRepository(mockShop),
          ),
        ],
        child: const MaterialApp(
          home: ShopDetailScreen(slug: 'goc-yen-binh'),
        ),
      ),
    );

    // Let the FutureProvider complete and trigger rebuild
    await tester.pump();

    // Verify title & address
    expect(find.text('Góc Yên Bình'), findsOneWidget);
    expect(find.text('45 Lê Lợi, Hải Châu, Đà Nẵng'), findsOneWidget);

    // Verify Info Cards are present
    expect(find.byIcon(LucideIcons.phone), findsAtLeastNWidgets(1));
    expect(find.byIcon(LucideIcons.navigation), findsAtLeastNWidgets(1));
    expect(find.byIcon(LucideIcons.map), findsAtLeastNWidgets(1));
    expect(find.byIcon(LucideIcons.clock), findsOneWidget);
    expect(find.byIcon(LucideIcons.dollar_sign), findsOneWidget);
  });

  testWidgets('ShopDetailScreen renders initial shop when refresh fails',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shopDetailRepositoryProvider.overrideWith(
            (ref) => _FailingShopDetailRepository(),
          ),
        ],
        child: const MaterialApp(
          home: ShopDetailScreen(
            slug: 'goc-yen-binh',
            initialShop: mockShop,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Góc Yên Bình'), findsOneWidget);
    expect(find.byKey(const Key('shopDetailStaleBanner')), findsOneWidget);
  });

  testWidgets('ShopDetailScreen action controls are persistent and distinct',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shopDetailRepositoryProvider.overrideWith(
            (ref) => _FakeShopDetailRepository(mockShop),
          ),
        ],
        child: const MaterialApp(
          home: ShopDetailScreen(slug: 'goc-yen-binh'),
        ),
      ),
    );

    await tester.pump();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.bottomNavigationBar, isNotNull);
    expect(find.byKey(const Key('shopDetailActionBar')), findsOneWidget);
    expect(find.byKey(const Key('shopDetailFavoriteAction')), findsOneWidget);
    expect(find.byKey(const Key('shopDetailShareAction')), findsOneWidget);
    expect(find.byKey(const Key('shopDetailDirectionsAction')), findsOneWidget);
    expect(find.byKey(const Key('shopDetailMapAction')), findsOneWidget);
    expect(find.byKey(const Key('shopDetailCallAction')), findsOneWidget);
    final actionBar = find.byKey(const Key('shopDetailActionBar'));
    expect(
      find.descendant(of: actionBar, matching: find.text('Chỉ đường')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: actionBar, matching: find.text('Bản đồ')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('shopDetailFavoriteAction')));
    await tester.pump();
    expect(find.text('Đã thêm vào danh sách yêu thích'), findsOneWidget);
  });

  testWidgets('ShopDetailScreen renders match reasons',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shopDetailRepositoryProvider.overrideWith(
            (ref) => _FakeShopDetailRepository(mockShop),
          ),
        ],
        child: const MaterialApp(
          home: ShopDetailScreen(
            slug: 'goc-yen-binh',
            matchReasons: ['Có máy lạnh', 'Yên tĩnh'],
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Vì sao phù hợp'), findsOneWidget);
    expect(find.text('Có máy lạnh'), findsOneWidget);
    expect(find.text('Yên tĩnh'), findsOneWidget);
  });

  testWidgets('ShopDetailScreen shows stale banner and retries',
      (WidgetTester tester) async {
    final retryCompleter = Completer<Result<CoffeeShop>>();
    final repository = _SequencedShopDetailRepository([
      () async => const Result.success(mockShop),
      () async => const Result.failure(AppFailure.network()),
      () => retryCompleter.future,
    ]);
    final container = ProviderContainer(
      overrides: [
        shopDetailRepositoryProvider.overrideWith((ref) => repository),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: ShopDetailScreen(slug: 'goc-yen-binh'),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Góc Yên Bình'), findsOneWidget);

    await container
        .read(shopDetailControllerProvider(
          const ShopDetailControllerArgs(slug: 'goc-yen-binh'),
        ).notifier)
        .retry('goc-yen-binh');
    await tester.pump();

    expect(find.byKey(const Key('shopDetailStaleBanner')), findsOneWidget);
    expect(
      find.text('Khong co ket noi mang. Kiem tra internet va thu lai.'),
      findsOneWidget,
    );
    expect(find.text('Góc Yên Bình'), findsOneWidget);

    await tester.tap(find.byKey(const Key('shopDetailStaleRetryButton')));
    await tester.pump();

    expect(repository.fetchCount, 3);
    expect(find.byKey(const Key('shopDetailRefreshIndicator')), findsOneWidget);
    expect(find.text('Góc Yên Bình'), findsOneWidget);

    retryCompleter.complete(const Result.success(mockShop));
    await tester.pump();

    expect(find.byKey(const Key('shopDetailStaleBanner')), findsNothing);
    expect(find.byKey(const Key('shopDetailRefreshIndicator')), findsNothing);
  });
}

class _FakeShopDetailRepository extends ShopDetailRepository {
  _FakeShopDetailRepository(this.shop) : super(DioClient(Dio()));

  final CoffeeShop shop;

  @override
  Future<Result<CoffeeShop>> fetchBySlug(String slug) async {
    return Result.success(shop);
  }
}

class _FailingShopDetailRepository extends ShopDetailRepository {
  _FailingShopDetailRepository() : super(DioClient(Dio()));

  @override
  Future<Result<CoffeeShop>> fetchBySlug(String slug) async {
    return const Result.failure(AppFailure.network());
  }
}

typedef _ShopDetailResponse = Future<Result<CoffeeShop>> Function();

class _SequencedShopDetailRepository extends ShopDetailRepository {
  _SequencedShopDetailRepository(this._responses) : super(DioClient(Dio()));

  final List<_ShopDetailResponse> _responses;
  int fetchCount = 0;

  @override
  Future<Result<CoffeeShop>> fetchBySlug(String slug) {
    final index = fetchCount++;
    return _responses[index]();
  }
}
