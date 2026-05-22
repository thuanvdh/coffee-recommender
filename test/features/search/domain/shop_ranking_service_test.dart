import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';
import 'package:coffee_recommender/features/search/domain/services/shop_ranking_service.dart';

void main() {
  CoffeeShop shop({
    required String slug,
    required List<String> purposes,
    required List<String> amenities,
    required List<String> spaces,
    double? distanceKm,
  }) {
    return CoffeeShop(
      id: slug.hashCode,
      name: slug,
      slug: slug,
      status: 'open',
      purposes: purposes,
      amenities: amenities,
      spaces: spaces,
      distanceKm: distanceKm,
      createdAt: '2026-05-22T00:00:00Z',
      updatedAt: '2026-05-22T00:00:00Z',
    );
  }

  test('ranks matching shops higher and explains why', () {
    final shops = [
      shop(slug: 'plain', purposes: [], amenities: [], spaces: []),
      shop(
        slug: 'work-cafe',
        purposes: ['Làm việc'],
        amenities: ['Máy lạnh'],
        spaces: ['Yên tĩnh'],
        distanceKm: 1.2,
      ),
    ];
    const intent = SearchIntent(
      purposeTags: ['Làm việc'],
      amenityTags: ['Máy lạnh'],
      spaceTags: ['Yên tĩnh'],
      nearMe: true,
    );

    final ranked = ShopRankingService().rank(shops: shops, intent: intent);

    expect(ranked.first.shop.slug, 'work-cafe');
    expect(ranked.first.matchReasons, contains('Phù hợp để làm việc'));
    expect(ranked.first.matchReasons, contains('Có máy lạnh'));
    expect(ranked.first.matchReasons, contains('Không gian yên tĩnh'));
  });
}
