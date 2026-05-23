import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const favoriteShopSlugsKey = 'favorite_shop_slugs';

class FavoritesRepository {
  const FavoritesRepository();

  Future<List<String>> loadFavoriteSlugs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(favoriteShopSlugsKey) ?? const [];
  }

  Future<void> saveFavoriteSlugs(List<String> slugs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(favoriteShopSlugsKey, slugs);
  }
}

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return const FavoritesRepository();
});
