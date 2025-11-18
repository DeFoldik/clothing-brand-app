// services/favorite_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _favoritesKey = 'user_favorites';

  static Future<List<int>> getFavoriteIds() async {
    try {
      print('🔍 Получаем лайки из SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);

      print('📁 Данные из SharedPreferences: $favoritesJson');

      if (favoritesJson != null) {
        final List<dynamic> favoritesList = json.decode(favoritesJson);
        final result = favoritesList.map((id) => id as int).toList();
        print('✅ Лайки получены: $result');
        return result;
      } else {
        print('ℹ️ Лайков нет, возвращаем пустой список');
        return [];
      }
    } catch (e) {
      print('❌ Ошибка получения лайков: $e');
      return [];
    }
  }

  static Future<void> addToFavorites(int productId) async {
    try {
      print('➕ Добавляем товар $productId в избранное...');
      final favorites = await getFavoriteIds();

      if (!favorites.contains(productId)) {
        favorites.add(productId);
        await _saveFavorites(favorites);
        print('✅ Товар $productId успешно добавлен в избранное');
      } else {
        print('ℹ️ Товар $productId уже в избранном');
      }
    } catch (e) {
      print('❌ Ошибка добавления в избранное: $e');
    }
  }

  static Future<void> removeFromFavorites(int productId) async {
    try {
      print('➖ Удаляем товар $productId из избранного...');
      final favorites = await getFavoriteIds();
      final wasRemoved = favorites.remove(productId);

      if (wasRemoved) {
        await _saveFavorites(favorites);
        print('✅ Товар $productId успешно удален из избранного');
      } else {
        print('ℹ️ Товар $productId не был в избранном');
      }
    } catch (e) {
      print('❌ Ошибка удаления из избранного: $e');
    }
  }

  static Future<bool> isFavorite(int productId) async {
    final favorites = await getFavoriteIds();
    final result = favorites.contains(productId);
    print('${result ? '❤️' : '🤍'} Товар $productId ${result ? 'в' : 'не в'} избранном');
    return result;
  }

  static Future<void> _saveFavorites(List<int> favorites) async {
    try {
      print('💾 Сохраняем лайки: $favorites');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_favoritesKey, json.encode(favorites));
      print('✅ Лайки успешно сохранены');
    } catch (e) {
      print('❌ Ошибка сохранения лайков: $e');
    }
  }

  static Future<void> clearFavorites() async {
    try {
      print('🗑️ Очищаем все лайки...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      print('✅ Все лайки очищены');
    } catch (e) {
      print('❌ Ошибка очистки лайков: $e');
    }
  }
}