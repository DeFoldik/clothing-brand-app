import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:store/services/admin_service.dart';
import 'package:store/models/product.dart';
import 'package:store/models/categories.dart';

// Мок классы с правильными generics
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockCollectionReference mockProductsCollection;
  late MockCollectionReference mockUsersCollection;
  late MockCollectionReference mockOrdersCollection;
  late MockDocumentReference mockProductDoc;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockDocumentSnapshot mockDocumentSnapshot;
  late MockQuery mockQuery;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockProductsCollection = MockCollectionReference();
    mockUsersCollection = MockCollectionReference();
    mockOrdersCollection = MockCollectionReference();
    mockProductDoc = MockDocumentReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDocumentSnapshot = MockDocumentSnapshot();
    mockQuery = MockQuery();

    // Базовая настройка моков
    when(() => mockFirestore.collection('products')).thenReturn(mockProductsCollection);
    when(() => mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(() => mockFirestore.collection('orders')).thenReturn(mockOrdersCollection);
    when(() => mockProductsCollection.doc(any())).thenReturn(mockProductDoc);
    when(() => mockProductsCollection.where(any(), isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
    when(() => mockQuery.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
    when(() => mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));
    when(() => mockProductDoc.get()).thenAnswer((_) async => mockDocumentSnapshot);
    when(() => mockDocumentSnapshot.exists).thenReturn(false);
    when(() => mockProductDoc.set(any())).thenAnswer((_) async {});
    when(() => mockProductDoc.update(any())).thenAnswer((_) async {});
  });

  group('AdminService', () {
    test('should have getProductsStream method', () {
      expect(AdminService.getProductsStream, isNotNull);
    });

    test('should have addProduct method', () {
      expect(AdminService.addProduct, isNotNull);
    });

    test('should have updateProduct method', () {
      expect(AdminService.updateProduct, isNotNull);
    });

    test('should have deleteProduct method', () {
      expect(AdminService.deleteProduct, isNotNull);
    });

    test('should have getUsersStream method', () {
      expect(AdminService.getUsersStream, isNotNull);
    });
  });
}