import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Basic arithmetic test', () {
    expect(1 + 1, 2);
    expect(2 * 2, 4);
  });

  test('List operations test', () {
    final products = ['T-Shirt', 'Hoodie', 'Jeans'];
    expect(products.length, 3);
    expect(products.contains('T-Shirt'), true);
  });

  test('Map operations test', () {
    final product = {
      'name': 'Test Product',
      'price': 99.99,
      'category': 'T-Shirts'
    };
    expect(product['name'], 'Test Product');
    expect(product['price'], 99.99);
  });
}