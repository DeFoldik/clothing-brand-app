// models/cart_product.dart
import 'product.dart';

class CartProduct {
  final Product product;
  final String size;
  final String color;
  int quantity;

  CartProduct({
    required this.product,
    required this.size,
    required this.color,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product': {
        'id': product.id,
        'title': product.title,
        'price': product.price,
        'description': product.description,
        'category': product.category,
        'image': product.image,
      },
      'size': size,
      'color': color,
      'quantity': quantity,
    };
  }

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      product: Product.fromJson(Map<String, dynamic>.from(json['product'] as Map)),
      size: json['size'] ?? 'M',
      color: json['color'] ?? 'Черный',
      quantity: json['quantity'] ?? 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartProduct &&
        other.product.id == product.id &&
        other.size == size &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(product.id, size, color);
}