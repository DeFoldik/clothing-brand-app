// services/product_detail_service.dart
import '../models/product_detail.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import 'package:flutter/material.dart';

class ProductDetailService {

  static Future<ProductDetail> getProductDetail(Product product) async {
    try {
      print('🔄 Загрузка деталей товара из Firebase: ${product.id}');

      // 1. Пробуем получить актуальные данные из Firebase
      final firestoreProduct = await FirestoreService.getProductById(product.id.toString());

      if (firestoreProduct != null) {
        print('✅ Товар найден в Firebase, используем актуальные данные');
        print(' Материал из Firebase: ${firestoreProduct.material}');
        return _createProductDetailFromFirebase(firestoreProduct);
      } else {
        print('⚠️ Товар не найден в Firebase, используем базовые данные');
        return _createBasicProductDetail(product);
      }
    } catch (e) {
      print('❌ Ошибка загрузки деталей товара: $e');
      return _createBasicProductDetail(product);
    }
  }

  static ProductDetail _createProductDetailFromFirebase(Product product) {
    // Используем реальные данные из Firebase
    return ProductDetail(
      id: product.id,
      title: product.title,
      price: product.price,
      discountPrice: product.discountPrice,
      description: product.description,
      category: product.category,
      images: _getValidImages(product),
      availableSizes: product.sizes.map((size) => ProductSize(
        size: size,
        inStock: product.isVariantAvailable(size, _getDefaultColor(product)),
      )).toList(),
      availableColors: product.colors.map((color) => ProductColor(
        name: color,
        color: _getColorFromName(color),
        imageUrl: product.images.isNotEmpty ? product.images.first : product.image,
        inStock: product.isVariantAvailable(_getDefaultSize(product), color),
      )).toList(),
      specification: ProductSpecification(
        material: product.material,
        care: product.careInstructions,
        season: product.season,
        additionalInfo: product.additionalSpecs,
      ),
      //  Передаем прямые поля для совместимости
      material: product.material,
      careInstructions: product.careInstructions,
      season: product.season,
      additionalSpecs: product.additionalSpecs,
      rating: 4.5,
      reviewCount: 128,
      isNew: product.isNew,
    );
  }

  static ProductDetail _createBasicProductDetail(Product product) {
    // Fallback на базовые данные
    return ProductDetail(
      id: product.id,
      title: product.title,
      price: product.price,
      discountPrice: product.discountPrice,
      description: product.description,
      category: product.category,
      images: _getValidImages(product),
      availableSizes: ['S', 'M', 'L', 'XL'].map((size) => ProductSize(
        size: size,
        inStock: true,
      )).toList(),
      availableColors: [
        ProductColor(
          name: 'Черный',
          color: Colors.black,
          imageUrl: product.images.isNotEmpty ? product.images.first : product.image,
          inStock: true,
        ),
        ProductColor(
          name: 'Белый',
          color: Colors.white,
          imageUrl: product.images.isNotEmpty ? product.images.first : product.image,
          inStock: true,
        ),
      ],
      specification: ProductSpecification(
        material: product.material,
        care: product.careInstructions,
        season: product.season,
        additionalInfo: product.additionalSpecs,
      ),
      //  Передаем прямые поля
      material: product.material,
      careInstructions: product.careInstructions,
      season: product.season,
      additionalSpecs: product.additionalSpecs,
      rating: 4.0,
      reviewCount: 0,
      isNew: false,
    );
  }

  // Получаем валидные изображения из продукта
  static List<String> _getValidImages(Product product) {
    // Приоритет: images > image
    if (product.images.isNotEmpty) {
      return product.images;
    }

    // Если нет images, используем основное изображение
    if (product.image.isNotEmpty) {
      return [product.image];
    }

    // Если вообще нет изображений - пустой массив (UI сам обработает)
    return [];
  }

  static String _getDefaultSize(Product product) {
    return product.sizes.isNotEmpty ? product.sizes.first : 'M';
  }

  static String _getDefaultColor(Product product) {
    return product.colors.isNotEmpty ? product.colors.first : 'Черный';
  }

  static Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'Черный': return Colors.black;
      case 'Белый': return Colors.white;
      case 'Серый': return Colors.grey;
      case 'Синий': return Colors.blueAccent;
      case 'Красный': return Colors.red;
      case 'Зеленый': return Colors.green;
      case 'Желтый': return Colors.yellow;
      case 'Розовый': return Colors.pink;
      case 'Оранжевый': return Colors.orange;
      case 'Фиолетовый': return Colors.purple;
      case 'Коричневый': return Colors.brown;
      default: return Colors.black;
    }
  }

  static Future<void> toggleFavorite(int productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}