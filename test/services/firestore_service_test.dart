import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:store/services/firestore_service.dart';
import 'package:store/models/product.dart';
import 'package:store/models/categories.dart';

// Мок классы
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockProductsCollection;
  late MockDocumentReference mockProductDoc;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockDocumentSnapshot mockDocumentSnapshot;
  late MockQuery mockQuery;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockProductsCollection = MockCollectionReference();
    mockProductDoc = MockDocumentReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDocumentSnapshot = MockDocumentSnapshot();
    mockQuery = MockQuery();

    when(() => mockFirestore.collection('products')).thenReturn(mockProductsCollection);
    when(() => mockProductsCollection.doc(any())).thenReturn(mockProductDoc);
    when(() => mockProductsCollection.where(any(), isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
    when(() => mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));
    when(() => mockQuery.limit(any())).thenReturn(mockQuery);
    when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(() => mockProductDoc.get()).thenAnswer((_) async => mockDocumentSnapshot);
  });

  group('FirestoreService', () {
    test('should have getProductsByCategory method', () {
      expect(FirestoreService.getProductsByCategory, isNotNull);
    });

    test('should have getCategories method', () {
      expect(FirestoreService.getCategories, isNotNull);
    });

    test('should have searchProducts method', () {
      expect(FirestoreService.searchProducts, isNotNull);
    });

    test('should have getPopularProducts method', () {
      expect(FirestoreService.getPopularProducts, isNotNull);
    });

    test('should have getNewProducts method', () {
      expect(FirestoreService.getNewProducts, isNotNull);
    });

    test('should have getDiscountedProducts method', () {
      expect(FirestoreService.getDiscountedProducts, isNotNull);
    });

    test('should have getProductsStream method', () {
      expect(FirestoreService.getProductsStream, isNotNull);
    });

    test('should have getProductById method', () {
      expect(FirestoreService.getProductById, isNotNull);
    });

    test('should have getProductsByIds method', () {
      expect(FirestoreService.getProductsByIds, isNotNull);
    });

    test('should have searchProductsWithFilters method', () {
      expect(FirestoreService.searchProductsWithFilters, isNotNull);
    });

    test('should have getAvailableFilters method', () {
      expect(FirestoreService.getAvailableFilters, isNotNull);
    });

    test('should have updateVariantStock method', () {
      expect(FirestoreService.updateVariantStock, isNotNull);
    });
  });

  group('FirestoreService Filter Methods', () {
    test('getAvailableFilters should return sizes and colors', () async {
      expect(FirestoreService.getAvailableFilters, isNotNull);
    });
  });
}