import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:flutter/foundation.dart';

class RankedShop {
  RankedShop({
    required this.shop,
    required this.score,
    required List<String> matchReasons,
  }) : matchReasons = List.unmodifiable(matchReasons);

  final CoffeeShop shop;
  final int score;
  final List<String> matchReasons;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RankedShop &&
            other.shop == shop &&
            other.score == score &&
            listEquals(other.matchReasons, matchReasons);
  }

  @override
  int get hashCode => Object.hash(
        shop,
        score,
        Object.hashAll(matchReasons),
      );
}
