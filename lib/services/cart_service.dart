// services/cart_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String _cartKey = 'user_cart';

  // 🎯 Модель товара в корзине
  static Map<String, dynamic> cartItemToJson(CartItem item) {
    return {
      'productId': item.productId,
      'title': item.title,
      'price': item.price,
      'image': item.image,
      'size': item.size,
      'color': item.color,
      'quantity': item.quantity,
      'maxQuantity': item.maxQuantity,
    };
  }

  static CartItem cartItemFromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      title: json['title'],
      price: json['price']?.toDouble() ?? 0.0,
      image: json['image'],
      size: json['size'],
      color: json['color'],
      quantity: json['quantity'] ?? 1,
      maxQuantity: json['maxQuantity'] ?? 10,
    );
  }

  // 🎯 Получить корзину
  static Future<List<CartItem>> getCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson != null) {
        final List<dynamic> cartList = json.decode(cartJson);
        return cartList.map((item) => cartItemFromJson(item)).toList();
      }
    } catch (e) {
      print('Error getting cart: $e');
    }
    return [];
  }

  // 🎯 Добавить товар в корзину
  static Future<void> addToCart(CartItem item) async {
    try {
      final cart = await getCartItems();

      // Проверяем, есть ли уже такой товар с таким размером и цветом
      final existingIndex = cart.indexWhere((cartItem) =>
      cartItem.productId == item.productId &&
          cartItem.size == item.size &&
          cartItem.color == item.color
      );

      if (existingIndex != -1) {
        // Увеличиваем количество если товар уже есть
        cart[existingIndex].quantity += item.quantity;
        if (cart[existingIndex].quantity > cart[existingIndex].maxQuantity) {
          cart[existingIndex].quantity = cart[existingIndex].maxQuantity;
        }
      } else {
        // Добавляем новый товар
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
      item.productId == productId &&
          item.size == size &&
          item.color == color
      );

      if (index != -1) {
        cart[index].quantity = quantity.clamp(1, cart[index].maxQuantity);
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
      item.productId == productId &&
          item.size == size &&
          item.color == color
      );
      await _saveCart(cart);
    } catch (e) {
      print('Error removing from cart: $e');
    }
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
  static Future<void> _saveCart(List<CartItem> cart) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(cart.map((item) => cartItemToJson(item)).toList());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // 🎯 Получить общую стоимость
  static Future<double> getTotalPrice() async {
    final cart = await getCartItems();
    return cart.fold(0.0, (total, item) => total + (item.price * item.quantity));
  }

  // 🎯 Получить общее количество товаров
  static Future<int> getTotalItems() async {
    final cart = await getCartItems();
    return cart.fold(0, (total, item) => total + item.quantity);
  }
}

// 🎯 Модель товара в корзине
class CartItem {
  final int productId;
  final String title;
  final double price;
  final String image;
  final String size;
  final String color;
  int quantity;
  final int maxQuantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.size,
    required this.color,
    this.quantity = 1,
    this.maxQuantity = 10,
  });

  double get totalPrice => price * quantity;
}