// services/cart_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';

class CartService {
  static const String _cartKey = 'user_cart';

  // 🎯 Модель товара в корзине
  static Map<String, dynamic> _cartProductToJson(CartProduct item) {
    return {
      'product': item.product.toJson(),
      'size': item.size,
      'color': item.color,
      'quantity': item.quantity,
    };
  }

  static CartProduct _cartProductFromJson(Map<String, dynamic> json) {
    return CartProduct(
      product: Product.fromJson(json['product']),
      size: json['size'],
      color: json['color'],
      quantity: json['quantity'] ?? 1,
    );
  }

  // 🎯 Получить корзину
  static Future<List<CartProduct>> getCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson != null) {
        final List<dynamic> cartList = json.decode(cartJson);
        return cartList.map((item) => _cartProductFromJson(item)).toList();
      }
    } catch (e) {
      print('Error getting cart: $e');
    }
    return [];
  }

  // 🎯 Добавить товар в корзину
  static Future<void> addToCart(CartProduct item) async {
    try {
      final cart = await getCartItems();

      final existingIndex = cart.indexWhere((cartItem) =>
      cartItem.product.id == item.product.id &&
          cartItem.size == item.size &&
          cartItem.color == item.color
      );

      if (existingIndex != -1) {
        cart[existingIndex].quantity += item.quantity;
      } else {
        cart.add(item);
      }

      await _saveCart(cart);
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  // 🎯 Обновить количество товара
  static Future<void> updateQuantity(int productId, String size, String color, int quantity) async {
    try {
      final cart = await getCartItems();
      final index = cart.indexWhere((item) =>
      item.product.id == productId &&
          item.size == size &&
          item.color == color
      );

      if (index != -1) {
        cart[index].quantity = quantity.clamp(1, 10);
        await _saveCart(cart);
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  // 🎯 Удалить товар из корзины
  static Future<void> removeFromCart(int productId, String size, String color) async {
    try {
      final cart = await getCartItems();
      cart.removeWhere((item) =>
      item.product.id == productId &&
          item.size == size &&
          item.color == color
      );
      await _saveCart(cart);
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  static Future<List<String>> getAvailableSizes(int productId) async {
    // Заглушка - в реальном приложении брать из Firebase
    // Здесь можно сделать запрос к вашему бэкенду
    await Future.delayed(const Duration(milliseconds: 100));

    // Для демонстрации возвращаем все размеры, но можно добавить логику
    // Например, для некоторых товаров ограничить размеры
    final allSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

    // Пример логики: если товар дорогой, ограничиваем размеры
    // if (productId % 3 == 0) return ['S', 'M', 'L'];

    return allSizes;
  }

  // 🎯 Получить доступные цвета для товара
  static Future<List<String>> getAvailableColors(int productId) async {
    // Заглушка - в реальном приложении брать из Firebase
    await Future.delayed(const Duration(milliseconds: 100));

    final allColors = ['Черный', 'Белый', 'Серый', 'Синий', 'Красный', 'Зеленый'];

    // Пример логики: для разных категорий разные цвета
    // if (productId % 2 == 0) return ['Черный', 'Белый', 'Серый'];

    return allColors;
  }

  static Future<bool> checkAvailability(int productId, String size, String color) async {
    // В реальном приложении проверять в Firebase
    await Future.delayed(const Duration(milliseconds: 50));

    // Заглушка - всегда в наличии
    // Можно добавить логику, например:
    // if (size == 'XS' && color == 'Красный') return false;

    return true;
  }

  // 🎯 Очистить корзину
  static Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  // 🎯 Сохранить корзину
  static Future<void> _saveCart(List<CartProduct> cart) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(cart.map((item) => _cartProductToJson(item)).toList());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // 🎯 Получить общую стоимость (ИСПРАВЛЕННАЯ ВЕРСИЯ)
  static Future<double> getTotalPrice() async {
    try {
      final cart = await getCartItems();
      double total = 0.0;
      for (final item in cart) {
        total += item.product.price * item.quantity;
      }
      return total;
    } catch (e) {
      print('Error calculating total price: $e');
      return 0.0;
    }
  }

  // 🎯 Получить общее количество товаров (ИСПРАВЛЕННАЯ ВЕРСИЯ)
  static Future<int> getTotalItems() async {
    try {
      final cart = await getCartItems();
      int total = 0;
      for (final item in cart) {
        total += item.quantity;
      }
      return total;
    } catch (e) {
      print('Error calculating total items: $e');
      return 0;
    }
  }
}

// 🎯 Модель товара в корзине (обертка над Product)
class CartProduct {
  final Product product;
  final String size;
  final String color;
  int quantity;

  CartProduct({
    required this.product,
    required this.size,
    required this.color,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}