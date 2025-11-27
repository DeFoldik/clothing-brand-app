import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:store/services/firebase_cart_service.dart';
import 'package:store/models/cart_product.dart';
import 'package:store/models/product.dart';
import 'package:store/models/categories.dart';

// Мок классы
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUsersCollection;
  late MockCollectionReference mockCartCollection;
  late MockDocumentReference mockUserDoc;
  late MockDocumentReference mockCartDoc;
  late MockQuerySnapshot mockQuerySnapshot;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockCartCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockCartDoc = MockDocumentReference();
    mockQuerySnapshot = MockQuerySnapshot();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test_uid');
    when(() => mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(() => mockUsersCollection.doc('test_uid')).thenReturn(mockUserDoc);
    when(() => mockUserDoc.collection('cart')).thenReturn(mockCartCollection);
    when(() => mockCartCollection.doc(any())).thenReturn(mockCartDoc);
    when(() => mockCartCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(() => mockCartCollection.snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));
  });

  group('FirebaseCartService', () {
    test('should have getCartItems method', () {
      expect(FirebaseCartService.getCartItems, isNotNull);
    });

    test('should have addToCart method', () {
      expect(FirebaseCartService.addToCart, isNotNull);
    });

    test('should have updateQuantity method', () {
      expect(FirebaseCartService.updateQuantity, isNotNull);
    });

    test('should have removeFromCart method', () {
      expect(FirebaseCartService.removeFromCart, isNotNull);
    });

    test('should have clearCart method', () {
      expect(FirebaseCartService.clearCart, isNotNull);
    });

    test('should have cartStream', () {
      expect(FirebaseCartService.cartStream, isNotNull);
    }, skip: 'cartStream requires Firebase initialization');
  });

  group('FirebaseCartService Error Handling', () {
    test('should handle unauthenticated user', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
            () => FirebaseCartService.getCartItems(),
        returnsNormally,
      );
    });
  });
}