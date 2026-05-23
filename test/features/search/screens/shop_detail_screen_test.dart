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
    status: 'open',
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
    expect(find.byIcon(LucideIcons.phone), findsOneWidget);
    expect(find.byIcon(LucideIcons.navigation), findsOneWidget);
    expect(find.byIcon(LucideIcons.clock), findsOneWidget);
    expect(find.byIcon(LucideIcons.dollar_sign), findsOneWidget);
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
}

class _FakeShopDetailRepository extends ShopDetailRepository {
  _FakeShopDetailRepository(this.shop) : super(DioClient(Dio()));

  final CoffeeShop shop;

  @override
  Future<Result<CoffeeShop>> fetchBySlug(String slug) async {
    return Result.success(shop);
  }
}
