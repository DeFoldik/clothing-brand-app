import 'package:flutter_test/flutter_test.dart';
import 'package:store/models/cart_product.dart';
import 'package:store/models/product.dart';
import 'package:store/models/categories.dart';

void main() {
  group('CartProduct Model', () {
    final mockProduct = Product(
      id: 1,
      title: 'Test Product',
      price: 100.0,
      discountPrice: 80.0,
      description: 'Test',
      category: ProductCategory.all,
      image: 'test.jpg',
      images: ['test1.jpg'],
      sizes: ['M', 'L'],
      colors: ['Черный', 'Белый'],
      variants: [],
    );

    test('should create cart product with correct properties', () {
      final cartProduct = CartProduct(
        product: mockProduct,
        size: 'M',
        color: 'Черный',
        quantity: 2,
      );

      expect(cartProduct.product.id, 1);
      expect(cartProduct.size, 'M');
      expect(cartProduct.color, 'Черный');
      expect(cartProduct.quantity, 2);
    });

    test('should calculate total price correctly with discount', () {
      final cartProduct = CartProduct(
        product: mockProduct,
        size: 'M',
        color: 'Черный',
        quantity: 3,
      );

      // discountPrice 80.0 * quantity 3 = 240.0
      expect(cartProduct.totalPrice, 240.0);
      expect(cartProduct.unitPrice, 80.0);
      expect(cartProduct.hasDiscount, true);
    });

    test('should calculate total price without discount', () {
      final productWithoutDiscount = Product(
        id: 2,
        title: 'No Discount',
        price: 50.0,
        description: 'Test',
        category: ProductCategory.all,
        image: '',
        images: [],
        sizes: ['M'],
        colors: ['Черный'],
        variants: [],
      );

      final cartProduct = CartProduct(
        product: productWithoutDiscount,
        size: 'M',
        color: 'Черный',
        quantity: 2,
      );

      expect(cartProduct.totalPrice, 100.0);
      expect(cartProduct.unitPrice, 50.0);
      expect(cartProduct.hasDiscount, false);
    });

    test('should serialize to json correctly', () {
      final cartProduct = CartProduct(
        product: mockProduct,
        size: 'L',
        color: 'Белый',
        quantity: 1,
      );

      final json = cartProduct.toJson();

      expect(json['size'], 'L');
      expect(json['color'], 'Белый');
      expect(json['quantity'], 1);
      expect(json['product']['id'], 1);
      expect(json['product']['title'], 'Test Product');
      expect(json['product']['price'], 100.0);
      expect(json['product']['discountPrice'], 80.0);
    });

    test('should parse from json correctly', () {
      final json = {
        'product': {
          'id': 1,
          'title': 'JSON Product',
          'price': 100.0,
          'discountPrice': 80.0,
          'description': 'Test',
          'category': 'all',
          'image': 'test.jpg',
          'images': ['test1.jpg'],
          'isNew': false,
          'isPopular': false,
          'sizes': ['M'],
          'colors': ['Черный'],
        },
        'size': 'M',
        'color': 'Черный',
        'quantity': 2,
      };

      final cartProduct = CartProduct.fromJson(json);

      expect(cartProduct.product.title, 'JSON Product');
      expect(cartProduct.size, 'M');
      expect(cartProduct.color, 'Черный');
      expect(cartProduct.quantity, 2);
      expect(cartProduct.hasDiscount, true);
    });

    test('should check equality based on product, size and color only', () {
      final cartProduct1 = CartProduct(
        product: mockProduct,
        size: 'M',
        color: 'Черный',
        quantity: 1,
      );

      final cartProduct2 = CartProduct(
        product: mockProduct,
        size: 'M',
        color: 'Черный',
        quantity: 5, // Different quantity
      );

      final cartProduct3 = CartProduct(
        product: mockProduct,
        size: 'L', // Different size
        color: 'Черный',
        quantity: 1,
      );

      expect(cartProduct1 == cartProduct2, true); // Same product, size, color
      expect(cartProduct1 == cartProduct3, false); // Different size
    });

    test('should have correct hashCode', () {
      final cartProduct1 = CartProduct(
        product: mockProduct,
        size: 'M',
        color: 'Черный',
        quantity: 1,
      );

      final cartProduct2 = CartProduct(
        product: mockProduct,
        size: 'M',
        color: 'Черный',
        quantity: 2,
      );

      expect(cartProduct1.hashCode, cartProduct2.hashCode);
    });
  });
}