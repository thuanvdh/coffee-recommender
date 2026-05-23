import 'package:coffee_recommender/features/favorites/data/favorites_repository.dart';
import 'package:coffee_recommender/features/favorites/presentation/favorites_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads empty favorites', () async {
    final controller = FavoritesController(const FavoritesRepository());
    addTearDown(controller.dispose);

    await controller.initialized;

    expect(controller.state, isEmpty);
  });

  test('loads existing stored slugs with preserved key', () async {
    SharedPreferences.setMockInitialValues({
      favoriteShopSlugsKey: ['slow-bar', 'filter-house'],
    });
    final controller = FavoritesController(const FavoritesRepository());
    addTearDown(controller.dispose);

    await controller.initialized;

    expect(controller.state, ['slow-bar', 'filter-house']);
  });

  test('toggles slug on', () async {
    final controller = FavoritesController(const FavoritesRepository());
    addTearDown(controller.dispose);

    await controller.initialized;
    await controller.toggleFavorite('slow-bar');

    final prefs = await SharedPreferences.getInstance();
    expect(controller.state, ['slow-bar']);
    expect(controller.isFavorite('slow-bar'), isTrue);
    expect(prefs.getStringList(favoriteShopSlugsKey), ['slow-bar']);
  });

  test('toggles slug off', () async {
    SharedPreferences.setMockInitialValues({
      favoriteShopSlugsKey: ['slow-bar'],
    });
    final controller = FavoritesController(const FavoritesRepository());
    addTearDown(controller.dispose);

    await controller.initialized;
    await controller.toggleFavorite('slow-bar');

    final prefs = await SharedPreferences.getInstance();
    expect(controller.state, isEmpty);
    expect(controller.isFavorite('slow-bar'), isFalse);
    expect(prefs.getStringList(favoriteShopSlugsKey), isEmpty);
  });
}
