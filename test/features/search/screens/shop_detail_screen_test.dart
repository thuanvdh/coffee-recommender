import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:coffee_recommender/features/search/presentation/screens/shop_detail_screen.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';

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

  testWidgets('ShopDetailScreen renders shop basic details and action buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override detail provider to yield our mock shop immediately
          shopDetailProvider('goc-yen-binh').overrideWith((ref) => mockShop),
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
}
