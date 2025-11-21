// models/category_enum.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ProductCategory {
  all('Все', 'all', 'assets/icons/categories/all.svg'),
  hoodies('Худи и толстовки', 'hoodies', 'assets/icons/sweatshirt.svg'),
  tshirts('Футболки', 'tshirts', 'assets/icons/t-shirt.svg'),
  jackets('Верхняя одежда', 'jackets', 'assets/icons/down-jacket.svg'),
  pants('Штаны', 'pants', 'assets/icons/trousers.svg'),
  shorts('Шорты', 'shorts', 'assets/icons/knickers.svg'),
  longsleeves('Лонгсливы', 'longsleeves', 'assets/icons/longsleeve.svg'),
  headwear('Головные уборы', 'headwear', 'assets/icons/beanie.svg');

  final String displayName;
  final String firestoreValue;
  final String iconPath;

  const ProductCategory(this.displayName, this.firestoreValue, this.iconPath);

  static ProductCategory fromFirestore(String value) {
    return ProductCategory.values.firstWhere(
          (category) => category.firestoreValue == value,
      orElse: () => ProductCategory.all,
    );
  }

  String toFirestore() => firestoreValue;

  @override
  String toString() => displayName;

  bool get isAll => this == ProductCategory.all;

  static List<ProductCategory> get availableCategories {
    return ProductCategory.values.where((cat) => !cat.isAll).toList();
  }
}