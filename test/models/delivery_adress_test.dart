import 'package:flutter_test/flutter_test.dart';
import 'package:store/models/delivery_address.dart';

void main() {
  group('DeliveryAddress', () {
    test('should create address with correct properties', () {
      final address = DeliveryAddress(
        id: 'addr1',
        title: 'Дом',
        fullName: 'Иван Иванов',
        phone: '+79998887766',
        street: 'ул. Примерная, д. 10',
        city: 'Москва',
        postalCode: '123456',
        apartment: '25',
        isDefault: true,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(address.id, 'addr1');
      expect(address.title, 'Дом');
      expect(address.fullName, 'Иван Иванов');
      expect(address.phone, '+79998887766');
      expect(address.street, 'ул. Примерная, д. 10');
      expect(address.city, 'Москва');
      expect(address.postalCode, '123456');
      expect(address.apartment, '25');
      expect(address.isDefault, true);
    });

    test('should create address without apartment', () {
      final address = DeliveryAddress(
        id: 'addr2',
        title: 'Работа',
        fullName: 'Петр Петров',
        phone: '+79997776655',
        street: 'ул. Рабочая, д. 5',
        city: 'Санкт-Петербург',
        postalCode: '654321',
        isDefault: false,
        createdAt: DateTime(2024, 1, 2),
      );

      expect(address.apartment, isNull);
      expect(address.isDefault, false);
    });

    test('should generate full address correctly', () {
      final addressWithApartment = DeliveryAddress(
        id: 'addr1',
        title: 'Тест',
        fullName: 'Тест',
        phone: '+79998887766',
        street: 'ул. Тестовая, д. 1',
        city: 'Москва',
        postalCode: '123456',
        apartment: '10',
        isDefault: false,
        createdAt: DateTime.now(),
      );

      final addressWithoutApartment = DeliveryAddress(
        id: 'addr2',
        title: 'Тест',
        fullName: 'Тест',
        phone: '+79998887766',
        street: 'ул. Другая, д. 2',
        city: 'СПб',
        postalCode: '654321',
        isDefault: false,
        createdAt: DateTime.now(),
      );

      expect(addressWithApartment.fullAddress,
          'ул. Тестовая, д. 1, кв. 10, Москва, 123456');
      expect(addressWithoutApartment.fullAddress,
          'ул. Другая, д. 2, СПб, 654321');
    });

    test('should parse from firestore data', () {
      final firestoreData = {
        'title': 'Офис',
        'fullName': 'Сергей Сергеев',
        'phone': '+79996665544',
        'street': 'ул. Офисная, д. 15',
        'city': 'Екатеринбург',
        'postalCode': '555555',
        'apartment': '100',
        'isDefault': true,
      };

      final address = DeliveryAddress.fromFirestore(firestoreData, 'firestore-id');

      expect(address.id, 'firestore-id');
      expect(address.title, 'Офис');
      expect(address.fullName, 'Сергей Сергеев');
      expect(address.phone, '+79996665544');
      expect(address.street, 'ул. Офисная, д. 15');
      expect(address.city, 'Екатеринбург');
      expect(address.postalCode, '555555');
      expect(address.apartment, '100');
      expect(address.isDefault, true);
    });

    test('should convert to firestore data', () {
      final address = DeliveryAddress(
        id: 'test-id',
        title: 'Для Firestore',
        fullName: 'Фирстор Фирсторов',
        phone: '+79993332211',
        street: 'ул. Фирсторная, д. 99',
        city: 'Новосибирск',
        postalCode: '999999',
        apartment: '50',
        isDefault: false,
        createdAt: DateTime(2024, 1, 1),
      );

      final firestoreData = address.toFirestore();

      expect(firestoreData['title'], 'Для Firestore');
      expect(firestoreData['fullName'], 'Фирстор Фирсторов');
      expect(firestoreData['phone'], '+79993332211');
      expect(firestoreData['street'], 'ул. Фирсторная, д. 99');
      expect(firestoreData['city'], 'Новосибирск');
      expect(firestoreData['postalCode'], '999999');
      expect(firestoreData['apartment'], '50');
      expect(firestoreData['isDefault'], false);
    });
  });
}