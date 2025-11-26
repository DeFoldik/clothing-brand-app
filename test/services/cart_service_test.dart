import 'package:flutter_test/flutter_test.dart';
import 'package:store/models/product.dart';
import 'package:store/models/cart_product.dart';
import 'package:store/models/categories.dart';

void main() {
  group('CartProduct Basic Tests', () {
    test('CartProduct creation and price calculation', () {
      // Arrange
      final product = Product(
        id: 1,
        title: 'Test Product',
        price: 25.0,
        description: 'Test',
        category: ProductCategory.tshirts,
        image: 'test.jpg',
        images: ['test.jpg'],
        sizes: ['M'],
        colors: ['Red'],
        variants: [],
      );

      // Act
      final cartProduct = CartProduct(
        product: product,
        size: 'M',
        color: 'Red',
        quantity: 2,
      );

      // Assert
      expect(cartProduct.product.id, 1);
      expect(cartProduct.size, 'M');
      expect(cartProduct.color, 'Red');
      expect(cartProduct.quantity, 2);
      expect(cartProduct.totalPrice, 50.0); // 25.0 * 2
    });

    test('CartProduct equality based on product, size and color', () {
      // Arrange
      final product = Product(
        id: 1,
        title: 'Test',
        price: 10.0,
        description: 'Test',
        category: ProductCategory.tshirts,
        image: 'test.jpg',
        images: ['test.jpg'],
        sizes: ['S', 'M'],
        colors: ['Blue'],
        variants: [],
      );

      final cartProduct1 = CartProduct(
        product: product,
        size: 'M',
        color: 'Blue',
        quantity: 1,
      );

      final cartProduct2 = CartProduct(
        product: product,
        size: 'M',
        color: 'Blue',
        quantity: 3, // Different quantity
      );

      final cartProduct3 = CartProduct(
        product: product,
        size: 'S', // Different size
        color: 'Blue',
        quantity: 1,
      );

      // Assert
      expect(cartProduct1 == cartProduct2, true); // Same product, size, color
      expect(cartProduct1 == cartProduct3, false); // Different size
    });
  });
}