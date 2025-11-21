// models/order_status.dart
import 'package:flutter/material.dart';

enum OrderStatus {
  pending('Ожидает подтверждения', 'pending', Colors.orange),
  confirmed('Подтвержден', 'confirmed', Colors.blue),
  processing('Подготовка к отправке', 'processing', Colors.purple),
  shipped('Отправлен', 'shipped', Colors.teal),
  inTransit('В пути', 'inTransit', Colors.indigo),
  delivered('Доставлен', 'delivered', Colors.green),
  cancelled('Отменен', 'cancelled', Colors.red);

  final String displayName;
  final String firestoreValue;
  final Color color;

  const OrderStatus(this.displayName, this.firestoreValue, this.color);

  static OrderStatus fromFirestore(String value) {
    return OrderStatus.values.firstWhere(
          (status) => status.firestoreValue == value,
      orElse: () => OrderStatus.pending,
    );
  }

  String toFirestore() => firestoreValue;
}