// models/product.dart
import 'categories.dart';
import 'product_variant.dart';

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final ProductCategory category;
  final String image;
  final List<String> images; // 🎯 Обязательное поле
  final double? discountPrice;
  final bool isNew;
  final bool isPopular;
  final List<String> sizes;
  final List<String> colors;
  final List<ProductVariant> variants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.images, // 🎯 Теперь обязательное
    this.discountPrice,
    this.isNew = false,
    this.isPopular = false,
    required this.sizes,
    required this.colors,
    required this.variants,
    this.createdAt,
    this.updatedAt,
  });

  // Для обратной совместимости с FakeStore API
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: json['price']?.toDouble() ?? 0.0,
      description: json['description'],
      category: ProductCategory.fromFirestore(json['category'] ?? ''),
      image: json['image'],
      images: [json['image']], // 🎯 Создаем images из основного изображения
      sizes: [],
      colors: [],
      variants: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category.toFirestore(),
      'image': image,
      'images': images, // 🎯 Сохраняем images
      'discountPrice': discountPrice,
      'isNew': isNew,
      'isPopular': isPopular,
      'sizes': sizes,
      'colors': colors,
      'variants': variants.map((v) => v.toMap()).toList(),
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  // Получить остаток для конкретной комбинации
  int getStockForVariant(String size, String color) {
    final variant = variants.firstWhere(
          (v) => v.size == size && v.color == color,
      orElse: () => ProductVariant(size: size, color: color, stock: 0),
    );
    return variant.stock;
  }

  // Проверить доступность комбинации
  bool isVariantAvailable(String size, String color) {
    return getStockForVariant(size, color) > 0;
  }

  // Получить доступные цвета для размера
  List<String> getAvailableColorsForSize(String size) {
    final availableVariants = variants.where((v) => v.size == size && v.stock > 0);
    return availableVariants.map((v) => v.color).toSet().toList();
  }

  // Получить доступные размеры для цвета
  List<String> getAvailableSizesForColor(String color) {
    final availableVariants = variants.where((v) => v.color == color && v.stock > 0);
    return availableVariants.map((v) => v.size).toSet().toList();
  }

  // Общий остаток товара
  int get totalStock {
    return variants.fold(0, (sum, variant) => sum + variant.stock);
  }

  // Получить основное изображение (для обратной совместимости)
  String get mainImage => images.isNotEmpty ? images.first : image;

  factory Product.fromFirestore(Map<String, dynamic> data, String documentId) {
    final variantsData = data['variants'] as List<dynamic>? ?? [];

    // Безопасное получение images
    final imagesData = data['images'] as List<dynamic>?;
    List<String> productImages;

    if (imagesData != null && imagesData.isNotEmpty) {
      productImages = imagesData.map((img) => img.toString()).toList();
    } else {
      final mainImage = data['image'] ?? '';
      productImages = [mainImage];
    }

    // Пробуем получить ID из данных, если нет - используем documentId
    int productId;
    try {
      // Сначала пробуем получить ID из поля данных
      if (data['id'] != null) {
        productId = (data['id'] is int) ? data['id'] : int.parse(data['id'].toString());
      } else {
        // Если нет поля id, используем documentId
        productId = int.parse(documentId);
      }
    } catch (e) {
      print('⚠️ Ошибка парсинга ID: $e, documentId: $documentId');
      productId = documentId.hashCode;
    }

    final categoryString = data['category'] ?? '';
    final category = ProductCategory.fromFirestore(categoryString);

    final sizesData = data['sizes'] as List<dynamic>? ?? [];
    final colorsData = data['colors'] as List<dynamic>? ?? [];

    return Product(
      id: productId,
      title: data['title'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      category: category,
      image: data['image'] ?? '',
      images: productImages,
      discountPrice: data['discountPrice']?.toDouble(),
      isNew: data['isNew'] ?? false,
      isPopular: data['isPopular'] ?? false,
      sizes: sizesData.map((item) => item.toString()).toList(),
      colors: colorsData.map((item) => item.toString()).toList(),
      variants: variantsData.map((v) => ProductVariant.fromMap(v as Map<String, dynamic>)).toList(),
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }
}