// services/firebase_favorite_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // Добавляем для Stream

class FirebaseFavoriteService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🎯 Получить коллекцию избранного для текущего пользователя
  static CollectionReference get _favoritesCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection('favorites');
  }

  // 🎯 Получить список ID избранных товаров
  static Future<List<int>> getFavoriteIds() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      print('🔍 Получаем лайки из Firebase для пользователя: ${user.uid}');

      final snapshot = await _favoritesCollection.get();
      final favorites = snapshot.docs.map((doc) => int.parse(doc.id)).toList();

      print('✅ Лайки получены из Firebase: $favorites');
      return favorites;
    } catch (e) {
      print('❌ Ошибка получения лайков из Firebase: $e');
      return [];
    }
  }

  // 🎯 Добавить товар в избранное
  static Future<void> addToFavorites(int productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('➕ Добавляем товар $productId в избранное Firebase...');

      await _favoritesCollection.doc(productId.toString()).set({
        'productId': productId,
        'addedAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });

      print('✅ Товар $productId успешно добавлен в избранное Firebase');
    } catch (e) {
      print('❌ Ошибка добавления в избранное Firebase: $e');
      throw e;
    }
  }

  // 🎯 Удалить товар из избранного
  static Future<void> removeFromFavorites(int productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('➖ Удаляем товар $productId из избранного Firebase...');

      await _favoritesCollection.doc(productId.toString()).delete();

      print('✅ Товар $productId успешно удален из избранного Firebase');
    } catch (e) {
      print('❌ Ошибка удаления из избранного Firebase: $e');
      throw e;
    }
  }

  // 🎯 Проверить, находится ли товар в избранном
  static Future<bool> isFavorite(int productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _favoritesCollection.doc(productId.toString()).get();
      final result = doc.exists;

      print('${result ? '❤️' : '🤍'} Товар $productId ${result ? 'в' : 'не в'} избранном Firebase');
      return result;
    } catch (e) {
      print('❌ Ошибка проверки избранного в Firebase: $e');
      return false;
    }
  }

  // 🎯 Переключить состояние избранного
  static Future<void> toggleFavorite(int productId) async {
    try {
      final isCurrentlyFavorite = await isFavorite(productId);

      if (isCurrentlyFavorite) {
        await removeFromFavorites(productId);
      } else {
        await addToFavorites(productId);
      }
    } catch (e) {
      print('❌ Ошибка переключения избранного в Firebase: $e');
      throw e;
    }
  }

  // 🎯 Получить Stream для实时 обновлений избранного
  static Stream<List<int>> get favoritesStream {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => int.parse(doc.id)).toList();
    });
  }

  // 🎯 Очистить все избранное
  static Future<void> clearFavorites() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('🗑️ Очищаем все лайки в Firebase...');

      final snapshot = await _favoritesCollection.get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Все лайки очищены в Firebase');
    } catch (e) {
      print('❌ Ошибка очистки лайков в Firebase: $e');
      throw e;
    }
  }
}