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
  final List<String> images;
  final double? discountPrice;
  final bool isNew;
  final bool isPopular;
  final List<String> sizes;
  final List<String> colors;
  final List<ProductVariant> variants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  //  ДОБАВЛЯЕМ НОВЫЕ ПОЛЯ
  final String? material;
  final String? careInstructions;
  final String? season;
  final Map<String, String>? additionalSpecs;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.images,
    this.discountPrice,
    this.isNew = false,
    this.isPopular = false,
    required this.sizes,
    required this.colors,
    required this.variants,
    this.createdAt,
    this.updatedAt,
    //  Инициализируем новые поля
    this.material,
    this.careInstructions,
    this.season,
    this.additionalSpecs,
  });

  // Обновим метод fromFirestore
  factory Product.fromFirestore(Map<String, dynamic> data, String documentId) {
    final variantsData = data['variants'] as List<dynamic>? ?? [];
    final imagesData = data['images'] as List<dynamic>?;

    List<String> productImages;
    if (imagesData != null && imagesData.isNotEmpty) {
      productImages = imagesData.map((img) => img.toString()).toList();
    } else {
      final mainImage = data['image'] ?? '';
      productImages = [mainImage];
    }

    //  Получаем новые поля
    final additionalSpecsData = data['additionalSpecs'] as Map<String, dynamic>?;

    int productId;
    try {
      if (data['id'] != null) {
        productId = (data['id'] is int) ? data['id'] : int.parse(data['id'].toString());
      } else {
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
      //  Загружаем новые поля
      material: data['material'],
      careInstructions: data['careInstructions'],
      season: data['season'],
      additionalSpecs: additionalSpecsData != null
          ? Map<String, String>.from(additionalSpecsData)
          : null,
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  // Обновим метод toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category.toFirestore(),
      'image': image,
      'images': images,
      'discountPrice': discountPrice,
      'isNew': isNew,
      'isPopular': isPopular,
      'sizes': sizes,
      'colors': colors,
      'variants': variants.map((v) => v.toMap()).toList(),
      //  Добавляем новые поля
      'material': material,
      'careInstructions': careInstructions,
      'season': season,
      'additionalSpecs': additionalSpecs,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  // ... остальные методы остаются без изменений
  double get discountPercent {
    if (discountPrice == null) return 0;
    return ((price - discountPrice!) / price * 100).roundToDouble();
  }

  bool get hasDiscount => discountPrice != null;

  int getStockForVariant(String size, String color) {
    final variant = variants.firstWhere(
          (v) => v.size == size && v.color == color,
      orElse: () => ProductVariant(size: size, color: color, stock: 0),
    );
    return variant.stock;
  }

  bool isVariantAvailable(String size, String color) {
    return getStockForVariant(size, color) > 0;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // Безопасное получение category
    ProductCategory category;
    try {
      category = ProductCategory.fromFirestore(json['category'] ?? '');
    } catch (e) {
      print('⚠️ Ошибка парсинга категории: $e');
      category = ProductCategory.all;
    }

    // Безопасное получение images
    List<String> images;
    if (json['images'] != null && json['images'] is List) {
      images = List<String>.from(json['images']);
    } else {
      // Если images нет, используем основное изображение
      images = [json['image'] ?? ''];
    }

    // Безопасное получение sizes и colors
    List<String> sizes = [];
    if (json['sizes'] != null && json['sizes'] is List) {
      sizes = List<String>.from(json['sizes']);
    }

    List<String> colors = [];
    if (json['colors'] != null && json['colors'] is List) {
      colors = List<String>.from(json['colors']);
    }

    // Безопасное получение variants
    List<ProductVariant> variants = [];
    if (json['variants'] != null && json['variants'] is List) {
      variants = (json['variants'] as List).map((v) {
        try {
          return ProductVariant.fromMap(v as Map<String, dynamic>);
        } catch (e) {
          print('⚠️ Ошибка парсинга варианта: $e');
          return ProductVariant(size: 'M', color: 'Черный', stock: 0);
        }
      }).toList();
    }

    return Product(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      category: category,
      image: json['image'] ?? '',
      images: images,
      discountPrice: json['discountPrice']?.toDouble(),
      isNew: json['isNew'] ?? false,
      isPopular: json['isPopular'] ?? false,
      sizes: sizes,
      colors: colors,
      variants: variants,
      //  Новые поля
      material: json['material'],
      careInstructions: json['careInstructions'],
      season: json['season'],
      additionalSpecs: json['additionalSpecs'] != null
          ? Map<String, String>.from(json['additionalSpecs'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : null,
    );
  }

  List<String> getAvailableColorsForSize(String size) {
    final availableVariants = variants.where((v) => v.size == size && v.stock > 0);
    return availableVariants.map((v) => v.color).toSet().toList();
  }

  List<String> getAvailableSizesForColor(String color) {
    final availableVariants = variants.where((v) => v.color == color && v.stock > 0);
    return availableVariants.map((v) => v.size).toSet().toList();
  }

  int get totalStock {
    return variants.fold(0, (sum, variant) => sum + variant.stock);
  }

  String get mainImage => images.isNotEmpty ? images.first : image;
}