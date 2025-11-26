import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../models/product.dart';
import '../models/app_order.dart';
import '../models/order_status.dart';
import '../models/categories.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final ImagePicker _imagePicker = ImagePicker();

  // 🎯 УЛУЧШЕННЫЙ МЕТОД ЗАГРУЗКИ ИЗОБРАЖЕНИЯ
  static Future<String?> uploadProductImage(File imageFile) async {
    try {
      print('🔄 Начинаем загрузку изображения...');

      // Создаем уникальное имя файла
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final String fileName = 'products/$timestamp.jpg';
      final Reference storageRef = _storage.ref().child(fileName);

      // Устанавливаем метаданные
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': 'admin',
          'timestamp': timestamp.toString(),
        },
      );

      print('📤 Загружаем файл: $fileName');

      // Загружаем файл с метаданными
      final UploadTask uploadTask = storageRef.putFile(imageFile, metadata);

      // Слушаем прогресс загрузки
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('📊 Прогресс загрузки: ${progress.toStringAsFixed(1)}%');
      });

      // Ждем завершения загрузки
      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        print('✅ Файл успешно загружен');

        // Получаем URL для скачивания
        final String downloadUrl = await storageRef.getDownloadURL();
        print('🔗 URL изображения: $downloadUrl');

        return downloadUrl;
      } else {
        print('❌ Ошибка загрузки: ${snapshot.state}');
        return null;
      }

    } catch (e, stackTrace) {
      print('❌ Критическая ошибка загрузки изображения: $e');
      print('📋 Stack trace: $stackTrace');
      return null;
    }
  }

  // 🎯 ВЫБОР ИЗОБРАЖЕНИЯ С ОБРАБОТКОЙ ОШИБОК
  static Future<File?> pickImageFromGallery() async {
    try {
      print('🖼️ Выбор изображения из галереи...');

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        print('✅ Изображение выбрано: ${image.path}');
        return File(image.path);
      } else {
        print('ℹ️ Пользователь отменил выбор изображения');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ Ошибка выбора изображения: $e');
      print('📋 Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<void> deleteImage(String imageUrl) async {
    try {
      // Извлекаем путь из URL
      final Uri uri = Uri.parse(imageUrl);
      final String path = uri.path;

      // Находим ссылку на файл
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();

      print('✅ Изображение удалено: $imageUrl');
    } catch (e) {
      print('❌ Ошибка удаления изображения: $e');
    }
  }
  // ========== USER MANAGEMENT ==========

  static Stream<List<AppUser>> getUsersStream() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data();
      return AppUser(
        uid: doc.id,
        email: data['email'] ?? '',
        name: data['name'],
        phone: data['phone'],
        role: _parseUserRole(data['role'] ?? 'user'),
        createdAt: data['createdAt']?.toDate(),
        isActive: data['isActive'] ?? true,
      );
    })
        .toList());
  }

  static UserRole _parseUserRole(String roleString) {
    switch (roleString) {
      case 'admin':
        return UserRole.admin;
      case 'guest':
        return UserRole.guest;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  static Future<void> updateUserRole(String userId, UserRole newRole) async {
    await _firestore.collection('users').doc(userId).update({
      'role': _roleToString(newRole),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.guest:
        return 'guest';
      case UserRole.user:
      default:
        return 'user';
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // ========== PRODUCT MANAGEMENT ==========

  static Stream<List<Product>> getProductsStream() {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true) // 🆕 Только активные товары
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        } catch (e) {
          print('Error parsing product ${doc.id}: $e');
          // Возвращаем пустой продукт в случае ошибки
          return Product(
            id: int.tryParse(doc.id) ?? 0,
            title: 'Ошибка загрузки',
            price: 0,
            description: '',
            category: ProductCategory.all,
            image: '',
            images: [],
            sizes: [],
            colors: [],
            variants: [],
          );
        }
      }).toList();
    });
  }

  static Future<void> updateProduct(Product product) async {
    try {
      // Используем строковый ID
      final productId = product.id.toString();
      final productDoc = _firestore.collection('products').doc(productId);
      final productSnapshot = await productDoc.get();

      if (!productSnapshot.exists) {
        print('❌ Товар с ID $productId не найден');
        throw Exception('Товар не найден. Проверьте ID: $productId');
      }

      final updateData = {
        'title': product.title,
        'price': product.price,
        'description': product.description,
        'category': product.category.toFirestore(),
        'image': product.image,
        'images': product.images,
        'discountPrice': product.discountPrice,
        'isNew': product.isNew,
        'isPopular': product.isPopular,
        'sizes': product.sizes,
        'colors': product.colors,
        'variants': product.variants.map((v) => v.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await productDoc.update(updateData);
      print('✅ Товар обновлен: ${product.title} (ID: $productId)');
    } catch (e) {
      print('❌ Ошибка обновления товара: $e');
      rethrow;
    }
  }

  static Future<void> deleteProduct(String productId) async {
    try {
      // productId уже должен быть строкой, но на всякий случай
      final stringProductId = productId.toString();
      final productDoc = _firestore.collection('products').doc(stringProductId);
      final productSnapshot = await productDoc.get();

      if (!productSnapshot.exists) {
        print('⚠️ Товар с ID $stringProductId не найден');
        throw Exception('Товар не найден. ID: $stringProductId');
      }

      await productDoc.update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Товар помечен как неактивный: $stringProductId');
    } catch (e) {
      print('❌ Ошибка удаления товара: $e');
      rethrow;
    }
  }

  static Future<void> addProduct(Product product) async {
    try {
      // Используем строковый ID
      final productId = product.id.toString();
      final productDoc = _firestore.collection('products').doc(productId);
      final productSnapshot = await productDoc.get();

      if (productSnapshot.exists) {
        print('⚠️ Товар с ID $productId уже существует');
        throw Exception('Товар с таким ID уже существует: $productId');
      }

      final productData = {
        'id': product.id, // Сохраняем числовой ID в поле данных
        'title': product.title,
        'price': product.price,
        'description': product.description,
        'category': product.category.toFirestore(),
        'image': product.image,
        'images': product.images,
        'discountPrice': product.discountPrice,
        'isNew': product.isNew,
        'isPopular': product.isPopular,
        'isActive': true,
        'sizes': product.sizes,
        'colors': product.colors,
        'variants': product.variants.map((v) => v.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await productDoc.set(productData);
      print('✅ Товар добавлен: ${product.title} (ID: $productId)');
    } catch (e) {
      print('❌ Ошибка добавления товара: $e');
      rethrow;
    }
  }



  // ========== ORDER MANAGEMENT ==========

  static Stream<List<AppOrder>> getAllOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AppOrder.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  static Future<void> updateOrderStatus(String orderId, OrderStatus status, {String? trackingNumber}) async {
    final updateData = {
      'status': status.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (trackingNumber != null) {
      updateData['trackingNumber'] = trackingNumber;
    }

    await _firestore.collection('orders').doc(orderId).update(updateData);
  }

  static Future<Map<String, dynamic>> getOrderStats() async {
    try {
      final ordersSnapshot = await _firestore.collection('orders').get();
      final productsSnapshot = await _firestore.collection('products').where('isActive', isEqualTo: true).get();
      final usersSnapshot = await _firestore.collection('users').get();

      final orders = ordersSnapshot.docs;
      final totalRevenue = orders.fold(0.0, (sum, doc) {
        final data = doc.data();
        return sum + (data['totalPrice'] ?? 0.0);
      });

      final pendingOrders = orders.where((doc) {
        final data = doc.data();
        return data['status'] == 'pending';
      }).length;

      return {
        'totalOrders': orders.length,
        'totalRevenue': totalRevenue,
        'totalProducts': productsSnapshot.docs.length,
        'totalUsers': usersSnapshot.docs.length,
        'pendingOrders': pendingOrders,
      };
    } catch (e) {
      print('Error getting stats: $e');
      return {
        'totalOrders': 0,
        'totalRevenue': 0,
        'totalProducts': 0,
        'totalUsers': 0,
        'pendingOrders': 0,
      };
    }
  }

  static Future<File?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Добавьте эти методы в класс AdminService

  static Future<void> toggleUserStatus(String userId, bool isActive) async {
    await _firestore.collection('users').doc(userId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateOrderTracking(String orderId, String trackingNumber) async {
    await _firestore.collection('orders').doc(orderId).update({
      'trackingNumber': trackingNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}