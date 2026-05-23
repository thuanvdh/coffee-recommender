import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/shop_detail/data/repositories/shop_detail_repository.dart';
import 'package:coffee_recommender/features/shop_detail/presentation/controllers/shop_detail_controller.dart';
import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/core/result/result.dart';
import 'package:dio/dio.dart';
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

  testWidgets('AppRouter passes shop match reasons extra into ShopDetailScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...getTestOverrides(),
          shopDetailRepositoryProvider.overrideWith(
            (ref) => _FakeShopDetailRepository(_shop),
          ),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );

    appRouter.go('/shop/goc-yen-binh', extra: const ['Có máy lạnh']);
    await tester.pump();
    await tester.pump();

    expect(find.text('Goc Yen Binh'), findsOneWidget);
    expect(find.text('Vì sao phù hợp'), findsOneWidget);
    expect(find.text('Có máy lạnh'), findsOneWidget);
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

const _shop = CoffeeShop(
  id: 1,
  name: 'Goc Yen Binh',
  slug: 'goc-yen-binh',
  address: '45 Le Loi, Hai Chau, Da Nang',
  district: 'Hai Chau',
  status: 'open',
  createdAt: '2026-05-22T08:00:00Z',
  updatedAt: '2026-05-22T08:00:00Z',
);
