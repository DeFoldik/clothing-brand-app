// test/services/cart_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:store/services/cart_service.dart';

void main() {
  group('CartService Static Methods', () {
    test('should check user login status', () async {
    }, skip: 'Requires Firebase initialization');

    test('should get available sizes (mock)', () async {
      final sizes = await CartService.getAvailableSizes(1);
      expect(sizes, isA<List<String>>());
    }, skip: 'Requires Firebase initialization');

    test('should get available colors (mock)', () async {
      final colors = await CartService.getAvailableColors(1);
      expect(colors, isA<List<String>>());
    }, skip: 'Requires Firebase initialization');

    test('should check availability (mock)', () async {
      final isAvailable = await CartService.checkAvailability(1, 'M', 'Черный');
      expect(isAvailable, isA<bool>());
    }, skip: 'Requires Firebase initialization');
  });
}