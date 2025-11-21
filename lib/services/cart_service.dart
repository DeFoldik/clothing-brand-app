// services/cart_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_cart_service.dart';
import '../models/cart_product.dart';

class CartService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Проверка авторизации
  static bool get isUserLoggedIn => _auth.currentUser != null;

  // Получить корзину
  static Future<List<CartProduct>> getCartItems() async {
    if (!isUserLoggedIn) {
      throw Exception('User not authenticated');
    }
    return await FirebaseCartService.getCartItems();
  }

  // Добавить товар в корзину
  static Future<void> addToCart(CartProduct item) async {
    if (!isUserLoggedIn) {
      throw Exception('User not authenticated');
    }
    await FirebaseCartService.addToCart(item);
  }

  // Обновить количество
  static Future<void> updateQuantity(int productId, String size, String color, int quantity) async {
    if (!isUserLoggedIn) {
      throw Exception('User not authenticated');
    }
    await FirebaseCartService.updateQuantity(productId, size, color, quantity);
  }

  // Удалить товар
  static Future<void> removeFromCart(int productId, String size, String color) async {
    if (!isUserLoggedIn) {
      throw Exception('User not authenticated');
    }
    await FirebaseCartService.removeFromCart(productId, size, color);
  }

  // Очистить корзину
  static Future<void> clearCart() async {
    if (!isUserLoggedIn) {
      throw Exception('User not authenticated');
    }
    await FirebaseCartService.clearCart();
  }

  // Получить Stream корзины
  static Stream<List<CartProduct>> get cartStream {
    if (!isUserLoggedIn) {
      return Stream.value([]);
    }
    return FirebaseCartService.cartStream;
  }

  // Получить общую стоимость
  static Future<double> getTotalPrice() async {
    if (!isUserLoggedIn) {
      return 0.0;
    }
    final cart = await getCartItems();
    double total = 0.0;
    for (final item in cart) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  // Получить общее количество товаров
  static Future<int> getTotalItems() async {
    if (!isUserLoggedIn) {
      return 0;
    }
    final cart = await getCartItems();
    int total = 0;
    for (final item in cart) {
      total += item.quantity;
    }
    return total;
  }

  // Получить доступные размеры для товара
  static Future<List<String>> getAvailableSizes(int productId) async {
    // Заглушка - в реальном приложении брать из Firebase
    await Future.delayed(const Duration(milliseconds: 100));

    final allSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

    // Пример логики: если товар дорогой, ограничиваем размеры
    if (productId % 3 == 0) return ['S', 'M', 'L'];

    return allSizes;
  }

  // Получить доступные цвета для товара
  static Future<List<String>> getAvailableColors(int productId) async {
    // Заглушка - в реальном приложении брать из Firebase
    await Future.delayed(const Duration(milliseconds: 100));

    final allColors = ['Черный', 'Белый', 'Серый', 'Синий', 'Красный', 'Зеленый'];

    // Пример логики: для разных категорий разные цвета
    if (productId % 2 == 0) return ['Черный', 'Белый', 'Серый'];

    return allColors;
  }

  // Проверить доступность варианта
  static Future<bool> checkAvailability(int productId, String size, String color) async {
    // В реальном приложении проверять в Firebase
    await Future.delayed(const Duration(milliseconds: 50));

    // Заглушка - всегда в наличии
    // Можно добавить логику, например:
    // if (size == 'XS' && color == 'Красный') return false;

    return true;
  }

}