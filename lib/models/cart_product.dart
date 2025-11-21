import 'product.dart';
import 'categories.dart';

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
        'category': product.category.toFirestore(), // 🎯 ИСПРАВЛЕНО: используем toFirestore()
        'image': product.image,
        'images': product.images,
        'discountPrice': product.discountPrice,
        'isNew': product.isNew,
        'isPopular': product.isPopular,
        'sizes': product.sizes,
        'colors': product.colors,
      },
      'size': size,
      'color': color,
      'quantity': quantity,
    };
  }

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      product: Product(
        id: json['product']['id'],
        title: json['product']['title'],
        price: (json['product']['price'] ?? 0.0).toDouble(),
        description: json['product']['description'],
        category: ProductCategory.fromFirestore(json['product']['category'] ?? ''), // 🎯 ИСПРАВЛЕНО
        image: json['product']['image'],
        images: List<String>.from(json['product']['images'] ?? []),
        discountPrice: json['product']['discountPrice']?.toDouble(),
        isNew: json['product']['isNew'] ?? false,
        isPopular: json['product']['isPopular'] ?? false,
        sizes: List<String>.from(json['product']['sizes'] ?? []),
        colors: List<String>.from(json['product']['colors'] ?? []),
        variants: [],
      ),
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