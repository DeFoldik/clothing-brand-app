import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store/services/shared_prefs_favorite_service.dart';

void main() {
  // Инициализируем SharedPreferences для тестов
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPrefsFavoriteService', () {
    test('getFavoriteIds should return empty list initially', () async {
      final favorites = await SharedPrefsFavoriteService.getFavoriteIds();
      expect(favorites, isEmpty);
    });

    test('addToFavorites should add product to favorites', () async {
      await SharedPrefsFavoriteService.addToFavorites(1);
      final favorites = await SharedPrefsFavoriteService.getFavoriteIds();
      expect(favorites, contains(1));
    });

    test('removeFromFavorites should remove product from favorites', () async {
      // Добавляем товар
      await SharedPrefsFavoriteService.addToFavorites(1);
      await SharedPrefsFavoriteService.addToFavorites(2);

      // Удаляем один товар
      await SharedPrefsFavoriteService.removeFromFavorites(1);

      final favorites = await SharedPrefsFavoriteService.getFavoriteIds();
      expect(favorites, contains(2));
      expect(favorites, isNot(contains(1)));
    });

    test('isFavorite should return correct status', () async {
      await SharedPrefsFavoriteService.addToFavorites(5);

      expect(await SharedPrefsFavoriteService.isFavorite(5), isTrue);
      expect(await SharedPrefsFavoriteService.isFavorite(10), isFalse);
    });

    test('toggleFavorite should add and remove favorites', () async {
      // Первый вызов - добавляем
      await SharedPrefsFavoriteService.toggleFavorite(3);
      expect(await SharedPrefsFavoriteService.isFavorite(3), isTrue);

      // Второй вызов - удаляем
      await SharedPrefsFavoriteService.toggleFavorite(3);
      expect(await SharedPrefsFavoriteService.isFavorite(3), isFalse);
    });

    test('clearFavorites should remove all favorites', () async {
      // Добавляем несколько товаров
      await SharedPrefsFavoriteService.addToFavorites(1);
      await SharedPrefsFavoriteService.addToFavorites(2);
      await SharedPrefsFavoriteService.addToFavorites(3);

      // Очищаем
      await SharedPrefsFavoriteService.clearFavorites();

      final favorites = await SharedPrefsFavoriteService.getFavoriteIds();
      expect(favorites, isEmpty);
    });

    test('should not add duplicate favorites', () async {
      await SharedPrefsFavoriteService.addToFavorites(7);
      await SharedPrefsFavoriteService.addToFavorites(7); // Дубликат

      final favorites = await SharedPrefsFavoriteService.getFavoriteIds();
      expect(favorites, hasLength(1));
      expect(favorites, contains(7));
    });

    test('should handle multiple products correctly', () async {
      await SharedPrefsFavoriteService.addToFavorites(10);
      await SharedPrefsFavoriteService.addToFavorites(20);
      await SharedPrefsFavoriteService.addToFavorites(30);

      final favorites = await SharedPrefsFavoriteService.getFavoriteIds();
      expect(favorites, hasLength(3));
      expect(favorites, containsAll([10, 20, 30]));
    });
  });
}