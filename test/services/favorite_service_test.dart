import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store/services/shared_prefs_favorite_service.dart';

void main() {
  group('SharedPrefsFavoriteService', () {
    setUp(() async {
      // Настройка SharedPreferences для тестов
      SharedPreferences.setMockInitialValues({});
      // Очищаем избранное перед каждым тестом
      await SharedPrefsFavoriteService.clearFavorites();
    });

    test('should add product to favorites', () async {
      await SharedPrefsFavoriteService.addToFavorites(1);
      final favorites = await SharedPrefsFavoriteService.getFavoriteIds();

      expect(favorites, contains(1));
    });

    test('should remove product from favorites', () async {
      await SharedPrefsFavoriteService.addToFavorites(1);
      await SharedPrefsFavoriteService.addToFavorites(2);

      await SharedPrefsFavoriteService.removeFromFavorites(1);
      final favorites = await SharedPrefsFavoriteService.getFavoriteIds();

      expect(favorites, contains(2));
      expect(favorites, isNot(contains(1)));
    });

    test('should check if product is favorite', () async {
      await SharedPrefsFavoriteService.addToFavorites(5);

      expect(await SharedPrefsFavoriteService.isFavorite(5), true);
      expect(await SharedPrefsFavoriteService.isFavorite(10), false);
    });

    test('should toggle favorite status', () async {
      // First toggle - add to favorites
      await SharedPrefsFavoriteService.toggleFavorite(3);
      expect(await SharedPrefsFavoriteService.isFavorite(3), true);

      // Second toggle - remove from favorites
      await SharedPrefsFavoriteService.toggleFavorite(3);
      expect(await SharedPrefsFavoriteService.isFavorite(3), false);
    });

    test('should clear all favorites', () async {
      await SharedPrefsFavoriteService.addToFavorites(1);
      await SharedPrefsFavoriteService.addToFavorites(2);
      await SharedPrefsFavoriteService.addToFavorites(3);

      await SharedPrefsFavoriteService.clearFavorites();
      final favorites = await SharedPrefsFavoriteService.getFavoriteIds();

      expect(favorites, isEmpty);
    });

    test('should handle multiple products correctly', () async {
      await SharedPrefsFavoriteService.addToFavorites(10);
      await SharedPrefsFavoriteService.addToFavorites(20);
      await SharedPrefsFavoriteService.addToFavorites(30);

      final favorites = await SharedPrefsFavoriteService.getFavoriteIds();

      expect(favorites, hasLength(3));
      expect(favorites, containsAll([10, 20, 30]));
    });

    test('should not add duplicate favorites', () async {
      await SharedPrefsFavoriteService.addToFavorites(7);
      await SharedPrefsFavoriteService.addToFavorites(7); // Дубликат

      final favorites = await SharedPrefsFavoriteService.getFavoriteIds();

      expect(favorites, hasLength(1));
      expect(favorites, contains(7));
    });
  });
}