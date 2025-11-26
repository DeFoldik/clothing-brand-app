// services/favorite_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_favorite_service.dart';
import 'shared_prefs_favorite_service.dart';
import 'firestore_service.dart';
import '../models/product.dart';

class FavoriteService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  //  Определяем, какой сервис использовать
  static bool get _useFirebase => _auth.currentUser != null;

  //  Получить список ID избранных товаров
  static Future<List<int>> getFavoriteIds() async {
    if (_useFirebase) {
      return await FirebaseFavoriteService.getFavoriteIds();
    } else {
      return await SharedPrefsFavoriteService.getFavoriteIds();
    }
  }

  static Future<List<Product>> getFavoriteProducts() async {
    try {
      final favoriteIds = await getFavoriteIds();

      if (favoriteIds.isEmpty) return [];

      // ИСПОЛЬЗУЕМ FIREBASE ДЛЯ ПОЛУЧЕНИЯ ТОВАРОВ
      return await FirestoreService.getProductsByIds(favoriteIds);
    } catch (e) {
      print('❌ Ошибка получения избранных товаров: $e');
      return [];
    }
  }

  //  Добавить товар в избранное
  static Future<void> addToFavorites(int productId) async {
    if (_useFirebase) {
      await FirebaseFavoriteService.addToFavorites(productId);
    } else {
      await SharedPrefsFavoriteService.addToFavorites(productId);
    }
  }

  //  Удалить товар из избранного
  static Future<void> removeFromFavorites(int productId) async {
    if (_useFirebase) {
      await FirebaseFavoriteService.removeFromFavorites(productId);
    } else {
      await SharedPrefsFavoriteService.removeFromFavorites(productId);
    }
  }

  //  Проверить, находится ли товар в избранном
  static Future<bool> isFavorite(int productId) async {
    if (_useFirebase) {
      return await FirebaseFavoriteService.isFavorite(productId);
    } else {
      return await SharedPrefsFavoriteService.isFavorite(productId);
    }
  }

  //  Переключить состояние избранного
  static Future<void> toggleFavorite(int productId) async {
    if (_useFirebase) {
      await FirebaseFavoriteService.toggleFavorite(productId);
    } else {
      await SharedPrefsFavoriteService.toggleFavorite(productId);
    }
  }

  //  Получить Stream для实时 обновлений (только для Firebase)
  static Stream<List<int>> get favoritesStream {
    if (_useFirebase) {
      return FirebaseFavoriteService.favoritesStream;
    } else {
      // Для локального хранилища возвращаем пустой stream
      return Stream.value([]);
    }
  }

  //  Очистить все избранное
  static Future<void> clearFavorites() async {
    if (_useFirebase) {
      await FirebaseFavoriteService.clearFavorites();
    } else {
      await SharedPrefsFavoriteService.clearFavorites();
    }
  }

  //  Миграция лайков при входе пользователя
  static Future<void> migrateFavoritesOnLogin(String userId) async {
    try {
      print('🔄 Миграция лайков при входе пользователя...');

      // Получаем локальные лайки
      final localFavorites = await SharedPrefsFavoriteService.getFavoriteIds();
      print('📦 Локальные лайки для миграции: $localFavorites');

      if (localFavorites.isEmpty) {
        print('ℹ️ Нет локальных лайков для миграции');
        return;
      }

      // Добавляем каждый лайк в Firebase
      for (final productId in localFavorites) {
        await FirebaseFavoriteService.addToFavorites(productId);
      }

      // Очищаем локальные лайки после успешной миграции
      await SharedPrefsFavoriteService.clearFavorites();

      print('✅ Миграция лайков завершена успешно');
    } catch (e) {
      print('❌ Ошибка миграции лайков: $e');
    }
  }
}