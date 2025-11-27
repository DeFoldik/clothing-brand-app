import 'package:flutter_test/flutter_test.dart';
import 'package:store/models/product_variant.dart';

void main() {
  group('ProductVariant', () {
    test('should create variant with correct properties', () {
      final variant = ProductVariant(
        size: 'M',
        color: 'Черный',
        stock: 10,
        sku: 'TEST-SKU-123',
      );

      expect(variant.size, 'M');
      expect(variant.color, 'Черный');
      expect(variant.stock, 10);
      expect(variant.sku, 'TEST-SKU-123');
    });

    test('should parse from map correctly', () {
      final map = {
        'size': 'L',
        'color': 'Белый',
        'stock': 5,
        'sku': 'TEST-456',
      };

      final variant = ProductVariant.fromMap(map);

      expect(variant.size, 'L');
      expect(variant.color, 'Белый');
      expect(variant.stock, 5);
      expect(variant.sku, 'TEST-456');
    });

    test('should convert to map correctly', () {
      final variant = ProductVariant(
        size: 'XL',
        color: 'Синий',
        stock: 8,
        sku: 'TEST-789',
      );

      final map = variant.toMap();

      expect(map['size'], 'XL');
      expect(map['color'], 'Синий');
      expect(map['stock'], 8);
      expect(map['sku'], 'TEST-789');
    });

    test('should generate correct variant key', () {
      final variant = ProductVariant(
        size: 'M',
        color: 'Красный',
        stock: 1,
      );

      expect(variant.variantKey, 'M-Красный');
    });

    test('should check equality correctly', () {
      final variant1 = ProductVariant(size: 'M', color: 'Черный', stock: 5);
      final variant2 = ProductVariant(size: 'M', color: 'Черный', stock: 10); // Разный stock
      final variant3 = ProductVariant(size: 'L', color: 'Черный', stock: 5); // Разный size

      expect(variant1 == variant2, true); // Только size и color важны для равенства
      expect(variant1 == variant3, false);
    });

    test('should copy with new values', () {
      final original = ProductVariant(
        size: 'M',
        color: 'Черный',
        stock: 5,
        sku: 'ORIGINAL',
      );

      final updated = original.copyWith(
        stock: 10,
        sku: 'UPDATED',
      );

      expect(updated.size, 'M');
      expect(updated.color, 'Черный');
      expect(updated.stock, 10);
      expect(updated.sku, 'UPDATED');
    });
  });
}