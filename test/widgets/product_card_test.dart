import 'package:flutter_test/flutter_test.dart';
import 'package:store/models/product.dart';
import 'package:store/models/categories.dart';
import 'package:store/models/product_variant.dart';

void main() {
  group('Product Model Basic Tests', () {
    test('Product creation and basic properties', () {
      // Arrange & Act
      final product = Product(
        id: 1,
        title: 'Test T-Shirt',
        price: 29.99,
        description: 'A comfortable cotton t-shirt',
        category: ProductCategory.tshirts,
        image: 'test.jpg',
        images: ['test.jpg'],
        sizes: ['S', 'M', 'L'],
        colors: ['Black', 'White'],
        variants: [
          ProductVariant(size: 'M', color: 'Black', stock: 10),
        ],
      );

      // Assert
      expect(product.id, 1);
      expect(product.title, 'Test T-Shirt');
      expect(product.price, 29.99);
      expect(product.sizes, contains('M'));
      expect(product.colors, contains('Black'));
    });

    test('Product variant stock check', () {
      // Arrange
      final product = Product(
        id: 2,
        title: 'Test Hoodie',
        price: 49.99,
        description: 'Warm hoodie',
        category: ProductCategory.hoodies,
        image: 'hoodie.jpg',
        images: ['hoodie.jpg'],
        sizes: ['M'],
        colors: ['Blue'],
        variants: [
          ProductVariant(size: 'M', color: 'Blue', stock: 5),
          ProductVariant(size: 'L', color: 'Blue', stock: 0),
        ],
      );

      // Act & Assert
      expect(product.getStockForVariant('M', 'Blue'), 5);
      expect(product.getStockForVariant('L', 'Blue'), 0);
      expect(product.getStockForVariant('XL', 'Red'), 0); // Non-existent
    });
  });
}