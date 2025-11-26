import 'package:cloud_firestore/cloud_firestore.dart';
import 'delivery_address.dart';
import 'order_status.dart';
import 'cart_product.dart';

class AppOrder {
  final String id;
  final String userId;
  final List<CartProduct> items;
  final double totalPrice;
  final DateTime createdAt;
  final OrderStatus status;
  final DeliveryAddress deliveryAddress;
  final String? trackingNumber;
  final String? notes;
  final DateTime? updatedAt; //  Добавим поле для обновлений

  AppOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.createdAt,
    required this.status,
    required this.deliveryAddress,
    this.trackingNumber,
    this.notes,
    this.updatedAt,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  factory AppOrder.fromFirestore(Map<String, dynamic> data, String id) {
    final itemsData = data['items'] as List<dynamic>? ?? [];
    final addressData = data['deliveryAddress'] as Map<String, dynamic>? ?? {};

    return AppOrder(
      id: id,
      userId: data['userId'] ?? '',
      items: itemsData.map((item) => CartProduct.fromJson(item)).toList(),
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      status: OrderStatus.fromFirestore(data['status'] ?? 'pending'),
      deliveryAddress: DeliveryAddress.fromFirestore(addressData, 'temp'),
      trackingNumber: data['trackingNumber'],
      notes: data['notes'],
      updatedAt: data['updatedAt']?.toDate(), //
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'createdAt': FieldValue.serverTimestamp(),
      'status': status.toFirestore(),
      'deliveryAddress': deliveryAddress.toFirestore(),
      if (trackingNumber != null) 'trackingNumber': trackingNumber,
      if (notes != null) 'notes': notes,
      'updatedAt': FieldValue.serverTimestamp(), // 
    };
  }
}