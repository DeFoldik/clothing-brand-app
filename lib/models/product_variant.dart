// models/product_variant.dart
class ProductVariant {
  final String size;
  final String color;
  final int stock;
  final String? sku; // Артикул варианта (опционально)

  ProductVariant({
    required this.size,
    required this.color,
    required this.stock,
    this.sku,
  });

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      size: map['size'] ?? '',
      color: map['color'] ?? '',
      stock: map['stock'] ?? 0,
      sku: map['sku'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'size': size,
      'color': color,
      'stock': stock,
      if (sku != null) 'sku': sku,
    };
  }

  // Уникальный ключ варианта
  String get variantKey => '$size-$color';

  @override
  bool operator ==(Object other) {
    return other is ProductVariant &&
        other.size == size &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(size, color);
}