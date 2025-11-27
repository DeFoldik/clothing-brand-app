import 'package:flutter_test/flutter_test.dart';
import 'package:store/models/categories.dart';

void main() {
  group('ProductCategory', () {
    test('should parse from firestore correctly', () {
      expect(ProductCategory.fromFirestore('all'), ProductCategory.all);
      expect(ProductCategory.fromFirestore('hoodies'), ProductCategory.hoodies);
      expect(ProductCategory.fromFirestore('tshirts'), ProductCategory.tshirts);
      expect(ProductCategory.fromFirestore('pants'), ProductCategory.pants);
      expect(ProductCategory.fromFirestore('unknown'), ProductCategory.all); // fallback
    });

    test('should convert to firestore correctly', () {
      expect(ProductCategory.all.toFirestore(), 'all');
      expect(ProductCategory.hoodies.toFirestore(), 'hoodies');
      expect(ProductCategory.tshirts.toFirestore(), 'tshirts');
    });

    test('should have correct display names', () {
      expect(ProductCategory.all.displayName, 'Все');
      expect(ProductCategory.hoodies.displayName, 'Худи и толстовки');
      expect(ProductCategory.tshirts.displayName, 'Футболки');
    });

    test('should check if category is all', () {
      expect(ProductCategory.all.isAll, true);
      expect(ProductCategory.hoodies.isAll, false);
    });

    test('should return available categories without all', () {
      final available = ProductCategory.availableCategories;

      expect(available, isNot(contains(ProductCategory.all)));
      expect(available, contains(ProductCategory.hoodies));
      expect(available, contains(ProductCategory.tshirts));
    });
  });
}