// services/firebase_cart_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_product.dart';
import '../models/product.dart';
import '../models/categories.dart';

class FirebaseCartService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference get _cartCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection('cart');
  }

  // Генерация ID для элемента корзины
  static String _generateCartItemId(CartProduct item) {
    return '${item.product.id}-${item.size}-${item.color}';
  }

  // Получить корзину из Firebase
  static Future<List<CartProduct>> getCartItems() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _cartCollection.get();
      final cartItems = <CartProduct>[];

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final cartProduct = CartProduct.fromJson(data);
          cartItems.add(cartProduct);
        } catch (e) {
          print('❌ Ошибка парсинга элемента корзины: $e');
        }
      }

      return cartItems;
    } catch (e) {
      print('❌ Ошибка получения корзины из Firebase: $e');
      return [];
    }
  }

  // Добавить товар в корзину Firebase
  static Future<void> addToCart(CartProduct item) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final itemId = _generateCartItemId(item);
      await _cartCollection.doc(itemId).set(item.toJson());

      print('✅ Товар добавлен в корзину Firebase: ${item.product.title}');
    } catch (e) {
      print('❌ Ошибка добавления в корзину Firebase: $e');
      throw e;
    }
  }

  // Обновить количество товара в корзине Firebase
  static Future<void> updateQuantity(int productId, String size, String color, int quantity) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final tempProduct = Product(
        id: productId,
        title: '',
        price: 0,
        description: '',
        category: ProductCategory.all,
        image: '',
        images: [],
        sizes: [],
        colors: [],
        variants: [],
      );

      final tempCartItem = CartProduct(
        product: tempProduct,
        size: size,
        color: color,
        quantity: quantity,
      );

      final itemId = _generateCartItemId(tempCartItem);
      await _cartCollection.doc(itemId).update({'quantity': quantity});

      print('✅ Количество обновлено в Firebase: $quantity');
    } catch (e) {
      print('❌ Ошибка обновления количества в Firebase: $e');
      throw e;
    }
  }

  // Удалить товар из корзины Firebase
  static Future<void> removeFromCart(int productId, String size, String color) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final tempProduct = Product(
        id: productId,
        title: '',
        price: 0,
        description: '',
        category: ProductCategory.all,
        image: '',
        images: [],
        sizes: [],
        colors: [],
        variants: [],
      );

      final tempCartItem = CartProduct(
        product: tempProduct,
        size: size,
        color: color,
        quantity: 1,
      );

      final itemId = _generateCartItemId(tempCartItem);
      await _cartCollection.doc(itemId).delete();

      print('✅ Товар удален из корзины Firebase');
    } catch (e) {
      print('❌ Ошибка удаления из корзины Firebase: $e');
      throw e;
    }
  }

  // Очистить корзину в Firebase
  static Future<void> clearCart() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final snapshot = await _cartCollection.get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Корзина очищена в Firebase');
    } catch (e) {
      print('❌ Ошибка очистки корзины в Firebase: $e');
      throw e;
    }
  }

  // Stream для обновлений корзины
  static Stream<List<CartProduct>> get cartStream {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _cartCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CartProduct.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}