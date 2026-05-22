import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/domain/models/ranked_shop.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';

class ShopRankingService {
  List<RankedShop> rank({
    required List<CoffeeShop> shops,
    required SearchIntent intent,
  }) {
    final indexed = shops.indexed.map((entry) {
      final (index, shop) = entry;
      return _IndexedRankedShop(
        index: index,
        rankedShop: _rankShop(shop: shop, intent: intent),
      );
    }).toList();

    indexed.sort((left, right) {
      final scoreComparison = right.rankedShop.score.compareTo(
        left.rankedShop.score,
      );
      if (scoreComparison != 0) {
        return scoreComparison;
      }
      return left.index.compareTo(right.index);
    });

    return [
      for (final item in indexed) item.rankedShop,
    ];
  }

  RankedShop _rankShop({
    required CoffeeShop shop,
    required SearchIntent intent,
  }) {
    var score = 0;
    final reasons = <String>[];

    if (_matchesAny(shop.purposes, intent.purposeTags)) {
      score += 30;
      reasons.add(_purposeReason(intent.purposeTags));
    }

    if (_matchesAny(shop.amenities, intent.amenityTags)) {
      score += 20;
      reasons.add(_amenityReason(intent.amenityTags));
    }

    if (_matchesAny(shop.spaces, intent.spaceTags)) {
      score += 20;
      reasons.add(_spaceReason(intent.spaceTags));
    }

    if (intent.nearMe && shop.distanceKm != null) {
      if (shop.distanceKm! <= 2) {
        score += 15;
      } else {
        score += 5;
      }
      reasons.add(_distanceReason(shop.distanceKm!));
    }

    if (intent.openNow && shop.status.toLowerCase() == 'open') {
      score += 10;
      reasons.add('Đang mở cửa');
    }

    return RankedShop(
      shop: shop,
      score: score,
      matchReasons: reasons,
    );
  }

  bool _matchesAny(List<String> shopValues, List<String> intentValues) {
    final normalizedShopValues = shopValues.map(_normalize).toSet();
    return intentValues.any((value) => normalizedShopValues.contains(
          _normalize(value),
        ));
  }

  String _purposeReason(List<String> tags) {
    if (_contains(tags, 'Làm việc')) {
      return 'Phù hợp để làm việc';
    }
    return 'Phù hợp với mục đích tìm kiếm';
  }

  String _amenityReason(List<String> tags) {
    if (_contains(tags, 'Máy lạnh')) {
      return 'Có máy lạnh';
    }
    return 'Có tiện ích phù hợp';
  }

  String _spaceReason(List<String> tags) {
    if (_contains(tags, 'Yên tĩnh')) {
      return 'Không gian yên tĩnh';
    }
    return 'Không gian phù hợp';
  }

  String _distanceReason(double distanceKm) {
    return 'Cách bạn ${distanceKm.toStringAsFixed(1)} km';
  }

  bool _contains(List<String> values, String target) {
    return values.any((value) => _normalize(value) == _normalize(target));
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}

class _IndexedRankedShop {
  const _IndexedRankedShop({
    required this.index,
    required this.rankedShop,
  });

  final int index;
  final RankedShop rankedShop;
}
