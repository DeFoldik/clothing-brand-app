import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:store/widgets/product_card.dart';
import 'package:store/models/product.dart';
import 'package:store/models/categories.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  group('ProductCard Widget', () {
    final testProduct = Product(
      id: 1,
      title: 'Test Product',
      price: 99.99,
      description: 'Test Description',
      category: ProductCategory.tshirts,
      image: 'test.jpg',
      images: ['test1.jpg', 'test2.jpg'],
      sizes: ['M', 'L'],
      colors: ['Черный', 'Белый'],
      variants: [],
    );

    testWidgets('should display product title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: testProduct,
              onFavoriteChanged: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Product'), findsOneWidget);
    });

    testWidgets('should display product price', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: testProduct,
              onFavoriteChanged: () {},
            ),
          ),
        ),
      );

      expect(find.text('\$99.99'), findsOneWidget);
    });

    testWidgets('should display discount when available', (WidgetTester tester) async {
      final discountedProduct = Product(
        id: 2,
        title: 'Discounted Product',
        price: 100.0,
        discountPrice: 70.0,
        description: 'Test',
        category: ProductCategory.all,
        image: '',
        images: [],
        sizes: [],
        colors: [],
        variants: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: discountedProduct,
              onFavoriteChanged: () {},
            ),
          ),
        ),
      );

      expect(find.text('\$70.00'), findsOneWidget);
      expect(find.text('\$100.00'), findsOneWidget);
    });
  });
}