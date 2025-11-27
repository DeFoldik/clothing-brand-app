import 'package:flutter_test/flutter_test.dart';
import 'package:store/models/order_status.dart';
import 'package:flutter/material.dart';

void main() {
  group('OrderStatus', () {
    test('should parse from firestore correctly', () {
      expect(OrderStatus.fromFirestore('pending'), OrderStatus.pending);
      expect(OrderStatus.fromFirestore('confirmed'), OrderStatus.confirmed);
      expect(OrderStatus.fromFirestore('shipped'), OrderStatus.shipped);
      expect(OrderStatus.fromFirestore('delivered'), OrderStatus.delivered);
      expect(OrderStatus.fromFirestore('cancelled'), OrderStatus.cancelled);
      expect(OrderStatus.fromFirestore('unknown'), OrderStatus.pending); // fallback
    });

    test('should convert to firestore correctly', () {
      expect(OrderStatus.pending.toFirestore(), 'pending');
      expect(OrderStatus.confirmed.toFirestore(), 'confirmed');
      expect(OrderStatus.delivered.toFirestore(), 'delivered');
      expect(OrderStatus.cancelled.toFirestore(), 'cancelled');
    });

    test('should have correct display names', () {
      expect(OrderStatus.pending.displayName, 'Ожидает подтверждения');
      expect(OrderStatus.delivered.displayName, 'Доставлен');
      expect(OrderStatus.cancelled.displayName, 'Отменен');
    });

    test('should have correct colors', () {
      expect(OrderStatus.pending.color, Colors.orange);
      expect(OrderStatus.delivered.color, Colors.green);
      expect(OrderStatus.cancelled.color, Colors.red);
    });
  });
}