import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('favorite_shop_slugs') ?? [];
      state = list;
    } catch (_) {
      // Handle potential initialization issues gracefully
    }
  }

  Future<void> toggleFavorite(String slug) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = List<String>.from(state);
      if (currentList.contains(slug)) {
        currentList.remove(slug);
      } else {
        currentList.add(slug);
      }
      state = currentList;
      await prefs.setStringList('favorite_shop_slugs', currentList);
    } catch (_) {
      // Gracefully catch any filesystem/storage exceptions
    }
  }

  bool isFavorite(String slug) {
    return state.contains(slug);
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  return FavoritesNotifier();
});
