// services/product_detail_service.dart
import '../models/product_detail.dart';
import '../models/product.dart';
import 'package:flutter/material.dart';

class ProductDetailService {
  static Future<ProductDetail> getProductDetail(Product product) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
    final colors = [
      ProductColor(
        name: 'Черный',
        color: Colors.black,
        imageUrl: 'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=500',
        inStock: true,
      ),
      ProductColor(
        name: 'Белый',
        color: Colors.white,
        imageUrl: 'https://images.unsplash.com/photo-1564584217132-2271feaeb3ce?w=500',
        inStock: true,
      ),
      ProductColor(
        name: 'Серый',
        color: Colors.grey,
        imageUrl: 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=500',
        inStock: false,
      ),
    ];

    // 🎯 Используем images из product или создаем демо
    List<String> productImages;
    if (product.images.isNotEmpty) {
      productImages = product.images;
    } else {
      // Fallback: основное изображение + дополнительные
      productImages = [
        product.image,
        'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d?w=500',
        'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=500',
        'https://images.unsplash.com/photo-1554412933-514a83d2f3c8?w=500',
      ];
    }

    return ProductDetail(
      id: product.id,
      title: product.title,
      price: product.price,
      discountPrice: product.price > 50 ? product.price * 0.7 : null,
      description: product.description,
      category: product.category,
      images: productImages, // 🎯 Передаем images
      availableSizes: sizes.map((size) => ProductSize(
        size: size,
        inStock: [true, false][DateTime.now().millisecond % 2],
      )).toList(),
      availableColors: colors,
      specification: ProductSpecification(
        material: 'Хлопок 80%, Полиэстер 20%',
        care: 'Стирка при 30°C, не отбеливать',
        season: 'Круглогодичный',
        additionalInfo: {
          'Посадка': 'Regular Fit',
          'Длина': 'Стандартная',
          'Узор': 'Однотонный',
        },
      ),
      rating: 4.5,
      reviewCount: 128,
      isNew: product.id % 3 == 0,
    );
  }

  static Future<void> toggleFavorite(int productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}