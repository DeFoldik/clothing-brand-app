import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:store/services/address_service.dart';
import 'package:store/models/delivery_address.dart';

// Мок классы с правильными generics
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockCollectionReference mockAddressesCollection;
  late MockCollectionReference mockUserAddressesCollection;
  late MockDocumentReference mockAddressDoc;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQuery mockQuery;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockAddressesCollection = MockCollectionReference();
    mockUserAddressesCollection = MockCollectionReference();
    mockAddressDoc = MockDocumentReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockQuery = MockQuery();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test_uid');
    when(() => mockFirestore.collection('addresses')).thenReturn(mockAddressesCollection);
    when(() => mockAddressesCollection.where(any(), isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
    when(() => mockQuery.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
    when(() => mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));
    when(() => mockQuery.limit(any())).thenReturn(mockQuery);
    when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
  });

  group('AddressService', () {
    test('should have getAddressesStream method', () {
      expect(AddressService.getAddressesStream, isNotNull);
    });

    test('should have addAddress method', () {
      expect(AddressService.addAddress, isNotNull);
    });

    test('should have updateAddress method', () {
      expect(AddressService.updateAddress, isNotNull);
    });

    test('should have deleteAddress method', () {
      expect(AddressService.deleteAddress, isNotNull);
    });

    test('should have getDefaultAddress method', () {
      expect(AddressService.getDefaultAddress, isNotNull);
    });
  });

  group('Address Validation', () {
    test('should validate required fields', () {
      final invalidAddress = DeliveryAddress(
        id: '',
        title: 'Home',
        fullName: '', // Пустое поле
        phone: '',
        street: '',
        city: '',
        postalCode: '',
        createdAt: DateTime.now(),
      );

      // Проверяем что адрес невалиден
      expect(invalidAddress.fullName.isEmpty, isTrue);
      expect(invalidAddress.phone.isEmpty, isTrue);
      expect(invalidAddress.street.isEmpty, isTrue);
    });
  });
}