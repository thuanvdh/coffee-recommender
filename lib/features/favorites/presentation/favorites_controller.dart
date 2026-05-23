import 'package:coffee_recommender/features/favorites/data/favorites_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesController extends StateNotifier<List<String>> {
  FavoritesController(this._repository) : super(const []) {
    initialized = loadFavorites();
  }

  final FavoritesRepository _repository;
  late final Future<void> initialized;

  Future<void> loadFavorites() async {
    try {
      state = await _repository.loadFavoriteSlugs();
    } catch (_) {
      // Keep favorites non-blocking if local storage is temporarily unavailable.
    }
  }

  Future<void> toggleFavorite(String slug) async {
    try {
      final currentList = List<String>.from(state);
      if (currentList.contains(slug)) {
        currentList.remove(slug);
      } else {
        currentList.add(slug);
      }

      state = currentList;
      await _repository.saveFavoriteSlugs(currentList);
    } catch (_) {
      // Match the previous provider behavior by swallowing storage failures.
    }
  }

  bool isFavorite(String slug) {
    return state.contains(slug);
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesController, List<String>>((ref) {
  return FavoritesController(ref.watch(favoritesRepositoryProvider));
});
