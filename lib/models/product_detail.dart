// models/product_detail.dart
import 'package:flutter/material.dart';
import 'product.dart';

class ProductDetail {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
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

  ProductDetail({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.images,
    required this.availableSizes,
    required this.availableColors,
    required this.specification,
    this.discountPrice,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isNew = false,
    this.isFavorite = false,
    this.sizeChartImage,
  });

  double get discountPercent {
    if (discountPrice == null) return 0;
    return ((price - discountPrice!) / price * 100).roundToDouble();
  }

  bool get hasDiscount => discountPrice != null;

  factory ProductDetail.fromProduct(Product product) {
    return ProductDetail(
      id: product.id,
      title: product.title,
      price: product.price,
      description: product.description,
      category: product.category,
      images: [product.image],
      availableSizes: [],
      availableColors: [],
      specification: ProductSpecification(),
      sizeChartImage: 'https://via.placeholder.com/400x600/FFFFFF/000000?text=Size+Chart',
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
}