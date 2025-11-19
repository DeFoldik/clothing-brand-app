// models/app_user.dart
import 'package:firebase_auth/firebase_auth.dart';

enum UserRole { guest, user, admin }

class AppUser {
  final String uid;
  final String email;
  final String? name;
  final String? phone;
  final UserRole role;
  final DateTime? createdAt;

  AppUser({
    required this.uid,
    required this.email,
    this.name,
    this.phone,
    required this.role,
    this.createdAt,
  });

  // Исправленный конструктор
  factory AppUser.fromFirebaseAuth(User firebaseUser, Map<String, dynamic>? data) {
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: data?['name'] ?? firebaseUser.displayName, // displayName может быть null
      phone: data?['phone'] ?? firebaseUser.phoneNumber,
      role: UserRole.values.firstWhere(
            (e) => e.toString() == 'UserRole.${data?['role'] ?? 'user'}',
        orElse: () => UserRole.user,
      ),
      createdAt: data?['createdAt']?.toDate(),
    );
  }

  factory AppUser.guest() {
    return AppUser(
      uid: 'guest',
      email: 'guest',
      role: UserRole.guest,
    );
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isLoggedIn => role != UserRole.guest;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.toString().split('.').last,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }
}