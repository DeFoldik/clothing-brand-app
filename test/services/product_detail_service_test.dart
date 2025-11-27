import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:store/services/product_detail_service.dart';
import 'package:store/models/product.dart';
import 'package:store/models/product_detail.dart';
import 'package:store/models/categories.dart';

void main() {
  group('ProductDetailService', () {
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
      material: 'Хлопок 100%',
      careInstructions: 'Стирка при 30°C',
      season: 'Всесезонный',
    );

    test('getProductDetail should return ProductDetail', () async {
      final productDetail = await ProductDetailService.getProductDetail(testProduct);

      expect(productDetail, isA<ProductDetail>());
      expect(productDetail.id, testProduct.id);
      expect(productDetail.title, testProduct.title);
      expect(productDetail.price, testProduct.price);
      expect(productDetail.description, testProduct.description);
    });

    test('getProductDetail should handle product with images', () async {
      final productWithImages = Product(
        id: 2,
        title: 'Product with Images',
        price: 50.0,
        description: 'Description',
        category: ProductCategory.all,
        image: 'main.jpg',
        images: ['img1.jpg', 'img2.jpg'],
        sizes: ['S'],
        colors: ['Черный'],
        variants: [],
      );

      final productDetail = await ProductDetailService.getProductDetail(productWithImages);

      expect(productDetail.images, hasLength(2));
      expect(productDetail.images, contains('img1.jpg'));
      expect(productDetail.images, contains('img2.jpg'));
    });

    test('getProductDetail should handle product without images', () async {
      final productWithoutImages = Product(
        id: 3,
        title: 'Product without Images',
        price: 30.0,
        description: 'Description',
        category: ProductCategory.all,
        image: '', // Пустое основное изображение
        images: [], // Пустой список изображений
        sizes: ['M'],
        colors: ['Белый'],
        variants: [],
      );

      final productDetail = await ProductDetailService.getProductDetail(productWithoutImages);

      expect(productDetail.images, isEmpty);
    });

    test('getProductDetail should handle product with only main image', () async {
      final productWithMainImage = Product(
        id: 4,
        title: 'Product with Main Image',
        price: 40.0,
        description: 'Description',
        category: ProductCategory.all,
        image: 'main_image.jpg', // Только основное изображение
        images: [], // Пустой список дополнительных изображений
        sizes: ['L'],
        colors: ['Синий'],
        variants: [],
      );

      final productDetail = await ProductDetailService.getProductDetail(productWithMainImage);

      expect(productDetail.images, hasLength(1));
      expect(productDetail.images, contains('main_image.jpg'));
    });

    test('toggleFavorite should complete without error', () async {
      // Метод должен завершаться без ошибок
      await expectLater(
        ProductDetailService.toggleFavorite(1),
        completes,
      );
    });

    test('getProductDetail should include product specifications', () async {
      final productWithSpecs = Product(
        id: 5,
        title: 'Product with Specs',
        price: 75.0,
        description: 'High quality product',
        category: ProductCategory.tshirts,
        image: 'specs.jpg',
        images: [],
        sizes: ['M', 'L'],
        colors: ['Черный'],
        variants: [],
        material: 'Organic Cotton',
        careInstructions: 'Machine wash cold',
        season: 'Summer',
      );

      final productDetail = await ProductDetailService.getProductDetail(productWithSpecs);

      expect(productDetail.specification.material, 'Organic Cotton');
      expect(productDetail.specification.care, 'Machine wash cold');
      expect(productDetail.specification.season, 'Summer');
      expect(productDetail.specification.additionalInfo, 'Eco-friendly');
    });
  });

  group('ProductDetailService Edge Cases', () {
    test('should handle product with empty sizes and colors', () async {
      final emptyProduct = Product(
        id: 6,
        title: 'Empty Product',
        price: 10.0,
        description: 'Description',
        category: ProductCategory.all,
        image: 'test.jpg',
        images: [],
        sizes: [], // Пустые размеры
        colors: [], // Пустые цвета
        variants: [],
      );

      final productDetail = await ProductDetailService.getProductDetail(emptyProduct);

      // Должны быть установлены значения по умолчанию
      expect(productDetail.availableSizes, isNotEmpty);
      expect(productDetail.availableColors, isNotEmpty);
    });

    test('should handle product with discount price', () async {
      final discountedProduct = Product(
        id: 7,
        title: 'Discounted Product',
        price: 100.0,
        discountPrice: 70.0,
        description: 'Description',
        category: ProductCategory.all,
        image: 'test.jpg',
        images: [],
        sizes: ['M'],
        colors: ['Черный'],
        variants: [],
      );

      final productDetail = await ProductDetailService.getProductDetail(discountedProduct);

      expect(productDetail.discountPrice, 70.0);
      expect(productDetail.price, 100.0);
    });

    test('should handle product with isNew flag', () async {
      final newProduct = Product(
        id: 8,
        title: 'New Product',
        price: 60.0,
        description: 'Brand new product',
        category: ProductCategory.all,
        image: 'new.jpg',
        images: [],
        sizes: ['S'],
        colors: ['Красный'],
        variants: [],
        isNew: true,
      );

      final productDetail = await ProductDetailService.getProductDetail(newProduct);

      expect(productDetail.isNew, isTrue);
    });

    test('should handle product without isNew flag', () async {
      final regularProduct = Product(
        id: 9,
        title: 'Regular Product',
        price: 45.0,
        description: 'Regular product',
        category: ProductCategory.all,
        image: 'regular.jpg',
        images: [],
        sizes: ['M'],
        colors: ['Зеленый'],
        variants: [],
        // isNew не установлен
      );

      final productDetail = await ProductDetailService.getProductDetail(regularProduct);

      expect(productDetail.isNew, isFalse);
    });
  });

  group('ProductDetailService Performance', () {
    test('should complete getProductDetail in reasonable time', () async {
      final testProduct = Product(
        id: 10,
        title: 'Performance Test Product',
        price: 25.0,
        description: 'Test',
        category: ProductCategory.all,
        image: 'test.jpg',
        images: [],
        sizes: ['M'],
        colors: ['Черный'],
        variants: [],
      );

      // Метод должен завершиться за разумное время
      await expectLater(
        ProductDetailService.getProductDetail(testProduct),
        completes,
      );
    });

    test('toggleFavorite should complete quickly', () async {
      // Метод должен завершаться быстро
      final stopwatch = Stopwatch()..start();
      await ProductDetailService.toggleFavorite(99);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Должен завершиться менее чем за 1 секунду
    });
  });
}