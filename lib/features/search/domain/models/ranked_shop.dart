import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';

class RankedShop {
  const RankedShop({
    required this.shop,
    required this.score,
    required this.matchReasons,
  });

  final CoffeeShop shop;
  final int score;
  final List<String> matchReasons;
}
