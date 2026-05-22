import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/domain/models/ranked_shop.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';
import 'package:coffee_recommender/features/search/domain/services/shop_ranking_service.dart';

void main() {
  CoffeeShop shop({
    required String slug,
    required List<String> purposes,
    required List<String> amenities,
    required List<String> spaces,
    double? distanceKm,
    String status = 'open',
  }) {
    return CoffeeShop(
      id: slug.hashCode,
      name: slug,
      slug: slug,
      status: status,
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
    final intent = SearchIntent(
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

  test('keeps original order when shops have equal scores', () {
    final shops = [
      shop(slug: 'first', purposes: ['Làm việc'], amenities: [], spaces: []),
      shop(slug: 'second', purposes: ['Làm việc'], amenities: [], spaces: []),
    ];

    final ranked = ShopRankingService().rank(
      shops: shops,
      intent: SearchIntent(purposeTags: ['Làm việc']),
    );

    expect(ranked.map((item) => item.shop.slug), ['first', 'second']);
  });

  test('scores open shops for openNow without rewarding closed shops', () {
    final shops = [
      shop(
        slug: 'closed',
        purposes: [],
        amenities: [],
        spaces: [],
        status: 'closed',
      ),
      shop(
        slug: 'open',
        purposes: [],
        amenities: [],
        spaces: [],
        status: 'open',
      ),
    ];

    final ranked = ShopRankingService().rank(
      shops: shops,
      intent: SearchIntent(openNow: true),
    );

    expect(ranked.first.shop.slug, 'open');
    expect(ranked.first.score, 10);
    expect(ranked.first.matchReasons, contains('Đang mở cửa'));
    expect(ranked.last.score, 0);
  });

  test('matches tags case-insensitively after trimming', () {
    final shops = [
      shop(
        slug: 'match',
        purposes: ['làm việc'],
        amenities: ['máy lạnh'],
        spaces: ['yên tĩnh'],
      ),
    ];

    final ranked = ShopRankingService().rank(
      shops: shops,
      intent: SearchIntent(
        purposeTags: ['  LÀM VIỆC  '],
        amenityTags: [' MÁY LẠNH '],
        spaceTags: [' YÊN TĨNH '],
      ),
    );

    expect(ranked.single.score, 70);
    expect(ranked.single.matchReasons, [
      'Phù hợp để làm việc',
      'Có máy lạnh',
      'Không gian yên tĩnh',
    ]);
  });

  test('scores nearby shops higher than farther shops', () {
    final shops = [
      shop(
        slug: 'farther',
        purposes: [],
        amenities: [],
        spaces: [],
        distanceKm: 3.5,
      ),
      shop(
        slug: 'nearby',
        purposes: [],
        amenities: [],
        spaces: [],
        distanceKm: 1.5,
      ),
    ];

    final ranked = ShopRankingService().rank(
      shops: shops,
      intent: SearchIntent(nearMe: true),
    );

    expect(ranked.first.shop.slug, 'nearby');
    expect(ranked.first.score, 15);
    expect(ranked.last.score, 5);
    expect(ranked.first.matchReasons, contains('Cách bạn 1.5 km'));
  });

  test('ranked shop protects match reasons and supports value equality', () {
    final reasons = ['Có máy lạnh'];
    final coffeeShop = shop(
      slug: 'value',
      purposes: [],
      amenities: ['Máy lạnh'],
      spaces: [],
    );
    final rankedShop = RankedShop(
      shop: coffeeShop,
      score: 20,
      matchReasons: reasons,
    );

    reasons.add('Đang mở cửa');

    expect(rankedShop.matchReasons, ['Có máy lạnh']);
    expect(
      () => rankedShop.matchReasons.add('Không gian yên tĩnh'),
      throwsUnsupportedError,
    );
    expect(
      rankedShop,
      RankedShop(
        shop: coffeeShop,
        score: 20,
        matchReasons: ['Có máy lạnh'],
      ),
    );
  });
}
