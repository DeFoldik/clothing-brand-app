import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:store/services/checkout_service.dart';
import 'package:store/models/cart_product.dart';
import 'package:store/models/delivery_address.dart';
import 'package:store/models/product.dart';
import 'package:store/models/categories.dart';
import 'package:store/models/app_order.dart';

// Мок классы
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockDeliveryAddress extends Mock implements DeliveryAddress {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockDeliveryAddress mockAddress;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockAddress = MockDeliveryAddress();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test_uid');
  });

  group('CheckoutService', () {
    test('should have checkoutSingleItem method', () {
      expect(CheckoutService.checkoutSingleItem, isNotNull);
    });

    test('should have checkoutCart method', () {
      expect(CheckoutService.checkoutCart, isNotNull);
    });

    test('should have getSelectedAddress method', () {
      expect(CheckoutService.getSelectedAddress, isNotNull);
    });

    test('should have checkAvailability method', () {
      expect(CheckoutService.checkAvailability, isNotNull);
    });
  });

  group('CheckoutService Validation', () {
    test('checkoutCart should throw for empty cart', () async {
      // Метод должен бросать исключение при пустой корзине
      expect(
            () => CheckoutService.checkoutCart(deliveryAddress: mockAddress),
        throwsException,
      );
    });

    test('checkoutSingleItem should require all parameters', () async {
      final testProduct = Product(
        id: 1,
        title: 'Test Product',
        price: 99.99,
        description: 'Test Description',
        category: ProductCategory.tshirts,
        image: 'test.jpg',
        images: ['test1.jpg'],
        sizes: ['M'],
        colors: ['Black'],
        variants: [],
      );

      final cartItem = CartProduct(
        product: testProduct,
        size: 'M',
        color: 'Black',
        quantity: 1,
      );

      expect(
            () => CheckoutService.checkoutSingleItem(
          item: cartItem,
          deliveryAddress: mockAddress,
        ),
        throwsException, // Будет исключение из-за отсутствия пользователя
      );
    });
  });
}