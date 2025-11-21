// models/delivery_address.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryAddress {
  final String id;
  final String title;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String postalCode;
  final String? apartment;
  final bool isDefault;
  final DateTime createdAt;

  DeliveryAddress({
    required this.id,
    required this.title,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.postalCode,
    this.apartment,
    this.isDefault = false,
    required this.createdAt,
  });

  factory DeliveryAddress.fromFirestore(Map<String, dynamic> data, String id) {
    return DeliveryAddress(
      id: id,
      title: data['title'] ?? 'Основной адрес',
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      street: data['street'] ?? '',
      city: data['city'] ?? '',
      postalCode: data['postalCode'] ?? '',
      apartment: data['apartment'],
      isDefault: data['isDefault'] ?? false,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'fullName': fullName,
      'phone': phone,
      'street': street,
      'city': city,
      'postalCode': postalCode,
      if (apartment != null) 'apartment': apartment,
      'isDefault': isDefault,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  String get fullAddress {
    return '$street, ${apartment != null ? 'кв. $apartment, ' : ''}$city, $postalCode';
  }
}