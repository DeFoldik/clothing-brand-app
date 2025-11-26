// models/product_detail.dart
import 'package:flutter/material.dart';
import 'product.dart';
import 'categories.dart';
import 'product_variant.dart';

class ProductDetail {
  final int id;
  final String title;
  final double price;
  final String description;
  final ProductCategory category;
  final List<String> images;
  final List<ProductSize> availableSizes;
  final List<ProductColor> availableColors;
  final ProductSpecification specification;
  final double? discountPrice;
  final double rating;
  final int reviewCount;
  final bool isNew;
  final bool isFavorite;
  final String? sizeChartImage;

  final String? material;
  final String? careInstructions;
  final String? season;
  final Map<String, String>? additionalSpecs;

  ProductDetail({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.images, // Обязательный параметр
    required this.availableSizes,
    required this.availableColors,
    required this.specification,
    this.discountPrice,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isNew = false,
    this.isFavorite = false,
    this.sizeChartImage,
    this.material,
    this.careInstructions,
    this.season,
    this.additionalSpecs,
  });

  double get discountPercent {
    if (discountPrice == null) return 0;
    return ((price - discountPrice!) / price * 100).roundToDouble();
  }

  bool get hasDiscount => discountPrice != null;

  // Для обратной совместимости - получаем строковое представление
  String get categoryString => category.toString();

  factory ProductDetail.fromProduct(Product product) {
    return ProductDetail(
      id: product.id,
      title: product.title,
      price: product.price,
      description: product.description,
      category: product.category,
      images: product.images, //  Используем images из Product
      availableSizes: [],
      availableColors: [],
      specification: ProductSpecification(),
      material: product.material,
      careInstructions: product.careInstructions,
      season: product.season,
      additionalSpecs: product.additionalSpecs,
      sizeChartImage: 'https://via.placeholder.com/400x600/FFFFFF/000000?text=Size+Chart',
    );
  }

  // Конструктор для создания ProductDetail с дополнительными данными
  factory ProductDetail.fromProductWithDetails({
    required Product product,
    required List<ProductSize> sizes,
    required List<ProductColor> colors,
    required ProductSpecification spec,
    double? discount,
    double rating = 0.0,
    int reviewCount = 0,
    bool isNew = false,
    String? sizeChart,
  }) {
    return ProductDetail(
      id: product.id,
      title: product.title,
      price: product.price,
      description: product.description,
      category: product.category,
      images: product.images,
      availableSizes: sizes,
      availableColors: colors,
      specification: spec,
      discountPrice: discount,
      rating: rating,
      reviewCount: reviewCount,
      isNew: isNew,
      material: product.material,
      careInstructions: product.careInstructions,
      season: product.season,
      additionalSpecs: product.additionalSpecs,
      sizeChartImage: sizeChart,
    );
  }
}

class ProductSize {
  final String size;
  final bool inStock;
  final String? sku;

  ProductSize({
    required this.size,
    required this.inStock,
    this.sku,
  });

  // Конструктор из Map
  factory ProductSize.fromMap(Map<String, dynamic> map) {
    return ProductSize(
      size: map['size'] ?? '',
      inStock: map['inStock'] ?? false,
      sku: map['sku'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'size': size,
      'inStock': inStock,
      if (sku != null) 'sku': sku,
    };
  }
}

class ProductColor {
  final String name;
  final Color color;
  final String imageUrl;
  final bool inStock;

  ProductColor({
    required this.name,
    required this.color,
    required this.imageUrl,
    required this.inStock,
  });

  // Конструктор из Map
  factory ProductColor.fromMap(Map<String, dynamic> map) {
    return ProductColor(
      name: map['name'] ?? '',
      color: _parseColor(map['color']),
      imageUrl: map['imageUrl'] ?? '',
      inStock: map['inStock'] ?? false,
    );
  }

  static Color _parseColor(dynamic colorData) {
    if (colorData is Color) return colorData;
    if (colorData is String) {
      switch (colorData.toLowerCase()) {
        case 'черный': return Colors.black;
        case 'белый': return Colors.white;
        case 'серый': return Colors.grey;
        case 'синий': return Colors.blue;
        case 'красный': return Colors.red;
        case 'зеленый': return Colors.green;
        case 'желтый': return Colors.yellow;
        case 'розовый': return Colors.pink;
        case 'оранжевый': return Colors.orange;
        case 'фиолетовый': return Colors.purple;
        case 'коричневый': return Colors.brown;
        default: return Colors.black;
      }
    }
    return Colors.black;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': _colorToString(color),
      'imageUrl': imageUrl,
      'inStock': inStock,
    };
  }

  String _colorToString(Color color) {
    if (color == Colors.black) return 'Черный';
    if (color == Colors.white) return 'Белый';
    if (color == Colors.grey) return 'Серый';
    if (color == Colors.blue) return 'Синий';
    if (color == Colors.red) return 'Красный';
    if (color == Colors.green) return 'Зеленый';
    if (color == Colors.yellow) return 'Желтый';
    if (color == Colors.pink) return 'Розовый';
    if (color == Colors.orange) return 'Оранжевый';
    if (color == Colors.purple) return 'Фиолетовый';
    if (color == Colors.brown) return 'Коричневый';
    return 'Черный';
  }
}

class ProductSpecification {
  final String? material;
  final String? care;
  final String? season;
  final Map<String, String>? additionalInfo;

  ProductSpecification({
    this.material,
    this.care,
    this.season,
    this.additionalInfo,
  });

  // Конструктор из Map
  factory ProductSpecification.fromMap(Map<String, dynamic> map) {
    return ProductSpecification(
      material: map['material'],
      care: map['care'],
      season: map['season'],
      additionalInfo: map['additionalInfo'] != null
          ? Map<String, String>.from(map['additionalInfo'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (material != null) 'material': material,
      if (care != null) 'care': care,
      if (season != null) 'season': season,
      if (additionalInfo != null) 'additionalInfo': additionalInfo,
    };
  }

  // Проверка на пустую спецификацию
  bool get isEmpty {
    return material == null &&
        care == null &&
        season == null &&
        (additionalInfo == null || additionalInfo!.isEmpty);
  }
}