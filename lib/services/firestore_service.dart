// services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/categories.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🎯 ПОЛУЧЕНИЕ ТОВАРОВ ПО КАТЕГОРИИ
  static Stream<List<Product>> getProductsByCategory(ProductCategory category) {
    try {
      Query query = _firestore
          .collection('products')
          .where('isActive', isEqualTo: true);

      if (!category.isAll) {
        query = query.where('category', isEqualTo: category.toFirestore());
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      print('❌ Ошибка получения товаров по категории: $e');
      return Stream.value([]);
    }
  }

  // 🎯 ПОЛУЧЕНИЕ ВСЕХ КАТЕГОРИЙ (из enum)
  static List<ProductCategory> getCategories() {
    return ProductCategory.availableCategories;
  }


  // 🎯 ПОИСК ТОВАРОВ С ФИЛЬТРАЦИЕЙ ПО КАТЕГОРИИ
  static Stream<List<Product>> searchProducts(String query, {ProductCategory category = ProductCategory.all}) {
    try {
      Query firestoreQuery = _firestore
          .collection('products')
          .where('isActive', isEqualTo: true);

      if (!category.isAll) {
        firestoreQuery = firestoreQuery.where('category', isEqualTo: category.toFirestore());
      }

      return firestoreQuery.snapshots().map((snapshot) {
        final allProducts = snapshot.docs.map((doc) {
          return Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        return allProducts.where((product) {
          return product.title.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    } catch (e) {
      print('❌ Ошибка поиска товаров: $e');
      return Stream.value([]);
    }
  }

  // 🎯 ПОПУЛЯРНЫЕ ТОВАРЫ
  static Stream<List<Product>> getPopularProducts() {
    try {
      return _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .where('isPopular', isEqualTo: true)
          .limit(4)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      print('❌ Ошибка получения популярных товаров: $e');
      return Stream.value([]);
    }
  }

  // 🎯 НОВИНКИ
  static Stream<List<Product>> getNewProducts() {
    try {
      return _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .where('isNew', isEqualTo: true)
          .limit(4)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      print('❌ Ошибка получения новинок: $e');
      return Stream.value([]);
    }
  }

  // 🎯 ТОВАРЫ СО СКИДКОЙ
  static Stream<List<Product>> getDiscountedProducts() {
    try {
      return _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .where('discountPrice', isGreaterThan: 0)
          .limit(4)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      print('❌ Ошибка получения товаров со скидкой: $e');
      return Stream.value([]);
    }
  }

  // 🎯 ВСЕ ТОВАРЫ
  static Stream<List<Product>> getProductsStream() {
    try {
      return _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      print('❌ Ошибка получения товаров: $e');
      return Stream.value([]);
    }
  }

  // 🎯 ПОЛУЧЕНИЕ ТОВАРА ПО ID
  static Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ Ошибка получения товара: $e');
      return null;
    }
  }

  // services/firestore_service.dart - добавляем методы для сортировки



// 🎯 ФИЛЬТРАЦИЯ НА СТОРОНЕ КЛИЕНТА
  static List<Product> _applyClientSideFilters(
      List<Product> products, {
        required String searchQuery,
        required List<String> sizes,
        required List<String> colors,
        required double minPrice,
        required double maxPrice,
      }) {
    return products.where((product) {
      // Поиск по тексту
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final titleMatch = product.title.toLowerCase().contains(query);
        final descriptionMatch = product.description.toLowerCase().contains(query);
        if (!titleMatch && !descriptionMatch) return false;
      }

      // Фильтр по размерам
      if (sizes.isNotEmpty) {
        final hasSize = product.sizes.any((size) => sizes.contains(size));
        if (!hasSize) return false;
      }

      // Фильтр по цветам
      if (colors.isNotEmpty) {
        final hasColor = product.colors.any((color) => colors.contains(color));
        if (!hasColor) return false;
      }

      // Фильтр по цене
      final price = product.discountPrice ?? product.price;
      if (price < minPrice || price > maxPrice) return false;

      return true;
    }).toList();
  }

// 🎯 СОРТИРОВКА ТОВАРОВ
  static List<Product> _sortProducts(List<Product> products, String sortBy) {
    List<Product> sorted = List.from(products);

    switch (sortBy) {
      case 'price_high':
        sorted.sort((a, b) {
          final priceA = a.discountPrice ?? a.price;
          final priceB = b.discountPrice ?? b.price;
          return priceB.compareTo(priceA);
        });
        break;

      case 'price_low':
        sorted.sort((a, b) {
          final priceA = a.discountPrice ?? a.price;
          final priceB = b.discountPrice ?? b.price;
          return priceA.compareTo(priceB);
        });
        break;

      case 'newest':
      // Сначала новинки, потом остальные
        sorted.sort((a, b) {
          if (a.isNew && !b.isNew) return -1;
          if (!a.isNew && b.isNew) return 1;
          return 0;
        });
        break;

      case 'popular':
      default:
      // Сначала популярные, потом остальные
        sorted.sort((a, b) {
          if (a.isPopular && !b.isPopular) return -1;
          if (!a.isPopular && b.isPopular) return 1;
          return 0;
        });
        break;
    }

    return sorted;
  }

  // services/firestore_service.dart - исправляем методы

// 🎯 ПОИСК С СОРТИРОВКОЙ И ФИЛЬТРАЦИЕЙ
  static Stream<List<Product>> searchProductsWithFilters({
    String searchQuery = '',
    ProductCategory category = ProductCategory.all,
    List<String> sizes = const [],
    List<String> colors = const [],
    double minPrice = 0,
    double maxPrice = 500,
    String sortBy = 'popular',
  }) {
    try {
      Query query = _firestore
          .collection('products')
          .where('isActive', isEqualTo: true);

      // Фильтр по категории
      if (!category.isAll) {
        query = query.where('category', isEqualTo: category.toFirestore());
      }

      return query.snapshots().map((snapshot) {
        List<Product> allProducts = snapshot.docs.map((doc) {
          return Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        // Применяем фильтры на стороне клиента
        List<Product> filteredProducts = _applyClientSideFilters(
          allProducts,
          searchQuery: searchQuery,
          sizes: sizes,
          colors: colors,
          minPrice: minPrice,
          maxPrice: maxPrice,
        );

        // Применяем сортировку
        return _sortProducts(filteredProducts, sortBy);
      });
    } catch (e) {
      print('❌ Ошибка поиска с фильтрами: $e');
      return Stream.value([]);
    }
  }

// 🎯 ПОЛУЧЕНИЕ ВСЕХ ДОСТУПНЫХ РАЗМЕРОВ И ЦВЕТОВ (для фильтров)
  static Future<Map<String, List<String>>> getAvailableFilters() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();

      final allProducts = snapshot.docs.map((doc) {
        return Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      final allSizes = <String>{};
      final allColors = <String>{};

      for (final product in allProducts) {
        // Безопасное приведение типов
        allSizes.addAll(product.sizes.whereType<String>());
        allColors.addAll(product.colors.whereType<String>());
      }

      return {
        'sizes': allSizes.toList()..sort(),
        'colors': allColors.toList()..sort(),
      };
    } catch (e) {
      print('❌ Ошибка получения фильтров: $e');
      return {'sizes': [], 'colors': []};
    }
  }

  // 🎯 ОБНОВЛЕНИЕ ОСТАТКОВ ПРИ ПОКУПКЕ
  static Future<bool> updateVariantStock({
    required String productId,
    required String size,
    required String color,
    required int quantity,
  }) async {
    try {
      final productDoc = _firestore.collection('products').doc(productId);

      return await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(productDoc);
        if (!doc.exists) return false;

        final data = doc.data() as Map<String, dynamic>;
        final variants = List<Map<String, dynamic>>.from(data['variants'] ?? []);

        final variantIndex = variants.indexWhere(
                (v) => v['size'] == size && v['color'] == color
        );

        if (variantIndex == -1) return false;

        final currentStock = variants[variantIndex]['stock'] ?? 0;
        if (currentStock < quantity) return false;

        variants[variantIndex]['stock'] = currentStock - quantity;

        transaction.update(productDoc, {'variants': variants});
        return true;
      });
    } catch (e) {
      print('❌ Ошибка обновления остатков: $e');
      return false;
    }
  }
}