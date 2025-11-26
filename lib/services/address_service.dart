import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/delivery_address.dart';

class AddressService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  //  ВАРИАНТ 1: Отдельная коллекция addresses
  static CollectionReference get _addressesCollection {
    return _firestore.collection('addresses');
  }

  //  ВАРИАНТ 2: Подколлекция в users (для обратной совместимости)
  static CollectionReference get _userAddressesCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(userId).collection('addresses');
  }

  // Метод для отладки - проверка существования адресов
  static Future<void> debugAddresses() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('❌ Пользователь не авторизован');
      return;
    }

    try {
      final snapshot = await _addressesCollection
          .where('userId', isEqualTo: user.uid)
          .get();

      print('🔍 Отладка адресов для пользователя: ${user.uid}');
      print('📊 Найдено документов: ${snapshot.docs.length}');

      for (final doc in snapshot.docs) {
        print('📍 Адрес ${doc.id}: ${doc.data()}');
      }
    } catch (e) {
      print('❌ Ошибка отладки адресов: $e');
    }
  }

  // Получить все адреса пользователя (из отдельной коллекции)
  // Получить все адреса пользователя (из отдельной коллекции)
  static Stream<List<DeliveryAddress>> getAddressesStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    print('🔍 Загрузка адресов для пользователя: ${user.uid}');

    try {
      return _addressesCollection
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        print('📦 Получено ${snapshot.docs.length} адресов');

        final addresses = snapshot.docs.map((doc) {
          try {
            print('📄 Обработка адреса ${doc.id}: ${doc.data()}');
            return DeliveryAddress.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          } catch (e) {
            print('❌ Ошибка парсинга адреса ${doc.id}: $e');
            print('📊 Данные адреса: ${doc.data()}');
            return DeliveryAddress(
              id: doc.id,
              title: 'Ошибка загрузки',
              fullName: '',
              phone: '',
              street: '',
              city: '',
              postalCode: '',
              createdAt: DateTime.now(),
            );
          }
        }).toList();

        print('✅ Успешно загружено ${addresses.length} адресов');
        return addresses;
      });
    } catch (e) {
      print('❌ Ошибка получения адресов: $e');
      return Stream.value([]);
    }
  }

  // Добавить новый адрес (в отдельную коллекцию)
  static Future<void> addAddress(DeliveryAddress address) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      _validateAddress(address);

      // Если это адрес по умолчанию, снимаем флаг с других адресов
      if (address.isDefault) {
        await _clearDefaultAddresses();
      }

      // Сохраняем в отдельную коллекцию addresses с userId
      final addressData = address.toFirestore();
      addressData['userId'] = user.uid; // Важно для правил доступа

      await _addressesCollection.add(addressData);

      print('✅ Адрес сохранен в коллекцию addresses');
      print('👤 User ID: ${user.uid}');

    } catch (e) {
      print('❌ Ошибка сохранения адреса: $e');

      // Если ошибка доступа, пробуем сохранить в подколлекцию
      if (e.toString().contains('permission-denied')) {
        print('🔄 Пробуем сохранить в подколлекцию users/{uid}/addresses');
        await _addAddressToUserSubcollection(address);
      } else {
        throw Exception('Не удалось сохранить адрес: $e');
      }
    }
  }

  // Резервный метод: сохранение в подколлекцию пользователя
  static Future<void> _addAddressToUserSubcollection(DeliveryAddress address) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      if (address.isDefault) {
        await _clearDefaultAddressesInSubcollection();
      }

      await _userAddressesCollection.add(address.toFirestore());
      print('✅ Адрес сохранен в подколлекцию users/${user.uid}/addresses');
    } catch (e) {
      print('❌ Ошибка сохранения в подколлекцию: $e');
      throw Exception('Не удалось сохранить адрес: $e');
    }
  }

  // Обновить адрес
  static Future<void> updateAddress(DeliveryAddress address) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      //  ПРОВЕРКА: Убедимся, что ID не пустой
      if (address.id.isEmpty) {
        throw Exception('ID адреса не может быть пустым при обновлении');
      }

      _validateAddress(address);

      if (address.isDefault) {
        await _clearDefaultAddresses();
      }

      print('🔄 Обновление адреса: ${address.id}');
      await _addressesCollection.doc(address.id).update(address.toFirestore());
      print('✅ Адрес обновлен: ${address.title}');
    } catch (e) {
      print('❌ Ошибка обновления адреса: $e');
      throw e;
    }
  }

  // Удалить адрес
  static Future<void> deleteAddress(String addressId) async {
    try {
      await _addressesCollection.doc(addressId).delete();
      print('✅ Адрес удален: $addressId');
    } catch (e) {
      print('❌ Ошибка удаления адреса: $e');
      throw e;
    }
  }

  // Получить адрес по умолчанию
  static Future<DeliveryAddress?> getDefaultAddress() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final snapshot = await _addressesCollection
          .where('userId', isEqualTo: user.uid)
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return DeliveryAddress.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ Ошибка получения адреса по умолчанию: $e');
      return null;
    }
  }

  // Снять флаг "по умолчанию" со всех адресов пользователя
  static Future<void> _clearDefaultAddresses() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _addressesCollection
          .where('userId', isEqualTo: user.uid)
          .where('isDefault', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
      await batch.commit();
    } catch (e) {
      print('❌ Ошибка очистки адресов по умолчанию: $e');
    }
  }

  // Очистка адресов по умолчанию в подколлекции
  static Future<void> _clearDefaultAddressesInSubcollection() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _userAddressesCollection
          .where('isDefault', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
      await batch.commit();
    } catch (e) {
      print('❌ Ошибка очистки адресов в подколлекции: $e');
    }
  }

  // Метод валидации адреса
  static void _validateAddress(DeliveryAddress address) {
    if (address.fullName.isEmpty) throw Exception('Введите ФИО');
    if (address.phone.isEmpty) throw Exception('Введите телефон');
    if (address.postalCode.isEmpty) throw Exception('Введите почтовый индекс');
    if (address.city.isEmpty) throw Exception('Введите город');
    if (address.street.isEmpty) throw Exception('Введите улицу и дом');
  }
}