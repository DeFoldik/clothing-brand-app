import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_product.dart';
import '../models/delivery_address.dart';
import '../models/app_order.dart';
import '../models/order_status.dart';
import '../screens/cart_screen.dart';
import '../screens/add_address_screen.dart';
import '../screens/order_history_screen.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/address_service.dart';

class CheckoutService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Оформить заказ для одного товара
  static Future<AppOrder> checkoutSingleItem({
    required CartProduct item,
    required DeliveryAddress deliveryAddress,
    String? notes,
  }) async {
    return await _createOrder(
      items: [item],
      deliveryAddress: deliveryAddress,
      notes: notes,
    );
  }

  // Оформить заказ для всей корзины
  static Future<AppOrder> checkoutCart({
    required DeliveryAddress deliveryAddress,
    String? notes,
  }) async {
    final cartItems = await CartService.getCartItems();

    if (cartItems.isEmpty) {
      throw Exception('Корзина пуста');
    }

    return await _createOrder(
      items: cartItems,
      deliveryAddress: deliveryAddress,
      notes: notes,
    );
  }

  // Создать заказ
  static Future<AppOrder> _createOrder({
    required List<CartProduct> items,
    required DeliveryAddress deliveryAddress,
    String? notes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // 1. Рассчитать общую стоимость
      final totalPrice = items.fold(0.0, (sum, item) => sum + item.totalPrice);

      // 2. Создать заказ через OrderService
      final order = await OrderService.createOrder(
        items: items,
        deliveryAddress: deliveryAddress,
        totalPrice: totalPrice,
        notes: notes,
      );

      // 3. Очистить корзину (только если заказ создан успешно)
      if (items.length > 1) { // Если это вся корзина, а не один товар
        await CartService.clearCart();
      } else {
        // Если один товар - удаляем только его из корзины
        final singleItem = items.first;
        await CartService.removeFromCart(
          singleItem.product.id,
          singleItem.size,
          singleItem.color,
        );
      }

      print('✅ Заказ создан: ${order.id}');
      return order;

    } catch (e) {
      print('❌ Ошибка оформления заказа: $e');
      throw Exception('Не удалось оформить заказ: $e');
    }
  }

  // Получить доступные адреса доставки
  static Future<DeliveryAddress?> getSelectedAddress() async {
    try {
      // Сначала пробуем получить адрес по умолчанию
      final defaultAddress = await AddressService.getDefaultAddress();
      if (defaultAddress != null) return defaultAddress;

      // Если нет адреса по умолчанию, берем первый из списка
      final addresses = await AddressService.getAddressesStream().first;
      if (addresses.isNotEmpty) return addresses.first;

      return null;
    } catch (e) {
      print('❌ Ошибка получения адреса: $e');
      return null;
    }
  }

  // Проверить доступность товаров
  static Future<Map<String, dynamic>> checkAvailability(List<CartProduct> items) async {
    final unavailableItems = <CartProduct>[];
    double availableTotal = 0.0;

    for (final item in items) {
      try {
        // TODO: Реализовать проверку доступности через FirestoreService
        // final isAvailable = await FirestoreService.checkProductAvailability(...);
        // if (!isAvailable) {
        //   unavailableItems.add(item);
        // } else {
        availableTotal += item.totalPrice;
        // }
      } catch (e) {
        unavailableItems.add(item);
      }
    }

    return {
      'isAvailable': unavailableItems.isEmpty,
      'unavailableItems': unavailableItems,
      'availableTotal': availableTotal,
    };
  }
}