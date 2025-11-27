import 'package:flutter_test/flutter_test.dart';
import 'package:store/models/product.dart';
import 'package:store/models/categories.dart';
import 'package:store/models/product_variant.dart';

void main() {
  group('Product Model', () {
    test('should create product with correct properties', () {
      final product = Product(
        id: 1,
        title: 'Test Product',
        price: 29.99,
        description: 'Test Description',
        category: ProductCategory.tshirts,
        image: 'test.jpg',
        images: ['test1.jpg', 'test2.jpg'],
        sizes: ['M', 'L'],
        colors: ['Черный', 'Белый'],
        variants: [],
      );

      expect(product.title, 'Test Product');
      expect(product.price, 29.99);
      expect(product.category, ProductCategory.tshirts);
      expect(product.sizes, contains('M'));
      expect(product.images, hasLength(2));
    });

    test('should calculate discount percentage correctly', () {
      final product = Product(
        id: 1,
        title: 'Test',
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

      expect(product.discountPercent, 30.0);
      expect(product.hasDiscount, true);
    });

    test('should return 0 discount when no discount price', () {
      final product = Product(
        id: 1,
        title: 'Test',
        price: 100.0,
        description: 'Test',
        category: ProductCategory.all,
        image: '',
        images: [],
        sizes: [],
        colors: [],
        variants: [],
      );

      expect(product.discountPercent, 0.0);
      expect(product.hasDiscount, false);
    });

    test('should parse from firestore correctly', () {
      final firestoreData = {
        'title': 'Firestore Product',
        'price': 39.99,
        'description': 'Description from Firestore',
        'category': 'hoodies',
        'image': 'image.jpg',
        'images': ['img1.jpg', 'img2.jpg'],
        'discountPrice': 29.99,
        'isNew': true,
        'isPopular': false,
        'sizes': ['S', 'M', 'L'],
        'colors': ['Черный', 'Синий'],
        'variants': [],
      };

      final product = Product.fromFirestore(firestoreData, '123');

      expect(product.title, 'Firestore Product');
      expect(product.category, ProductCategory.hoodies);
      expect(product.isNew, true);
      expect(product.discountPrice, 29.99);
      expect(product.sizes, contains('M'));
    });

    // УДАЛИЛИ тест toFirestore - его нет в вашем коде
    // test('should convert to firestore correctly', () { ... });

    test('should check variant availability correctly', () {
      final variants = [
        {'size': 'M', 'color': 'Черный', 'stock': 5},
        {'size': 'L', 'color': 'Белый', 'stock': 0},
      ];

      final product = Product(
        id: 1,
        title: 'Test',
        price: 100.0,
        description: 'Test',
        category: ProductCategory.all,
        image: '',
        images: [],
        sizes: ['M', 'L'],
        colors: ['Черный', 'Белый'],
        variants: variants.map((v) => ProductVariant.fromMap(v)).toList(),
      );

      expect(product.isVariantAvailable('M', 'Черный'), true);
      expect(product.isVariantAvailable('L', 'Белый'), false);
      expect(product.isVariantAvailable('XL', 'Красный'), false);
    });

    // Добавляем тесты для методов, которые ЕСТЬ в вашем Product
    test('should return main image correctly', () {
      final product = Product(
        id: 1,
        title: 'Test',
        price: 100.0,
        description: 'Test',
        category: ProductCategory.all,
        image: 'main.jpg',
        images: ['first.jpg', 'second.jpg'],
        sizes: [],
        colors: [],
        variants: [],
      );

      expect(product.mainImage, 'first.jpg'); // Берет первую из images
    });

    test('should return image as main image when no images list', () {
      final product = Product(
        id: 1,
        title: 'Test',
        price: 100.0,
        description: 'Test',
        category: ProductCategory.all,
        image: 'main.jpg',
        images: [], // Пустой список
        sizes: [],
        colors: [],
        variants: [],
      );

      expect(product.mainImage, 'main.jpg'); // Берет из image
    });

    test('should calculate total stock correctly', () {
      final variants = [
        {'size': 'M', 'color': 'Черный', 'stock': 5},
        {'size': 'L', 'color': 'Белый', 'stock': 3},
      ];

      final product = Product(
        id: 1,
        title: 'Test',
        price: 100.0,
        description: 'Test',
        category: ProductCategory.all,
        image: '',
        images: [],
        sizes: ['M', 'L'],
        colors: ['Черный', 'Белый'],
        variants: variants.map((v) => ProductVariant.fromMap(v)).toList(),
      );

      expect(product.totalStock, 8); // 5 + 3
    });
  });
}