import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_order.dart';
import '../models/delivery_address.dart';
import '../models/cart_product.dart';
import 'firestore_service.dart';
import '../models/order_status.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference get _ordersCollection {
    return _firestore.collection('orders');
  }

  // Создать новый заказ
  static Future<AppOrder> createOrder({
    required List<CartProduct> items,
    required DeliveryAddress deliveryAddress,
    required double totalPrice,
    String? notes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {

      final calculatedTotalPrice = items.fold(0.0, (sum, item) {
        final itemPrice = item.unitPrice; // Используем цену со скидкой
        return sum + (itemPrice * item.quantity);
      });

      // 1. Проверяем доступность товаров и обновляем остатки
      for (final item in items) {
        final isAvailable = await FirestoreService.updateVariantStock(
          productId: item.product.id.toString(),
          size: item.size,
          color: item.color,
          quantity: item.quantity,
        );

        if (!isAvailable) {
          throw Exception('Товар "${item.product.title}" размера ${item.size} цвета ${item.color} недоступен в нужном количестве');
        }
      }

      // 2. Создаем заказ
      final orderRef = _ordersCollection.doc();
      final order = AppOrder(
        id: orderRef.id,
        userId: user.uid,
        items: items,
          totalPrice: calculatedTotalPrice,
        createdAt: DateTime.now(),
        status: OrderStatus.pending,
        deliveryAddress: deliveryAddress,
        notes: notes,
      );

      await orderRef.set(order.toFirestore());

      return order;
    } catch (e) {
      print('❌ Ошибка создания заказа: $e');
      rethrow;
    }
  }

  // Получить историю заказов пользователя
  static Stream<List<AppOrder>> getUserOrders() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    try {
      return _ordersCollection
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            return AppOrder.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          } catch (e) {
            print('❌ Ошибка парсинга заказа ${doc.id}: $e');
            // Возвращаем пустой заказ в случае ошибки
            return AppOrder(
              id: doc.id,
              userId: user.uid,
              items: [],
              totalPrice: 0.0,
              createdAt: DateTime.now(),
              status: OrderStatus.pending,
              deliveryAddress: DeliveryAddress(
                id: 'temp',
                title: 'Адрес не найден',
                fullName: '',
                phone: '',
                street: '',
                city: '',
                postalCode: '',
                createdAt: DateTime.now(),
              ),
            );
          }
        }).toList();
      });
    } catch (e) {
      print('❌ Ошибка получения заказов: $e');
      return Stream.value([]);
    }
  }

  // Получить конкретный заказ
  static Future<AppOrder?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return AppOrder.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ Ошибка получения заказа: $e');
      return null;
    }
  }

  // Обновить статус заказа (для админов)
  static Future<void> updateOrderStatus(String orderId, OrderStatus status, {String? trackingNumber}) async {
    final updateData = {
      'status': status.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (trackingNumber != null) {
      updateData['trackingNumber'] = trackingNumber;
    }

    await _ordersCollection.doc(orderId).update(updateData);
  }

  // Получить заказы для отладки
  static Future<void> debugOrders() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('❌ Пользователь не авторизован');
      return;
    }

    try {
      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: user.uid)
          .get();

      print('🔍 Найдено заказов: ${snapshot.docs.length}');
      for (final doc in snapshot.docs) {
        print('📦 Заказ ${doc.id}: ${doc.data()}');
      }
    } catch (e) {
      print('❌ Ошибка отладки заказов: $e');
    }
  }
}