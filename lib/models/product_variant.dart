// models/product_variant.dart
class ProductVariant {
  final String size;
  final String color;
  final int stock;
  final String? sku;

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

  ProductVariant copyWith({
    String? size,
    String? color,
    int? stock,
    String? sku,
  }) {
    return ProductVariant(
      size: size ?? this.size,
      color: color ?? this.color,
      stock: stock ?? this.stock,
      sku: sku ?? this.sku,
    );
  }
  @override
  int get hashCode => Object.hash(size, color);
}