import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { guest, user, admin }

class AppUser {
  final String uid;
  final String email;
  final String? name;
  final String? phone;
  final UserRole role;
  final DateTime? createdAt;
  final bool isActive;

  AppUser({
    required this.uid,
    required this.email,
    this.name,
    this.phone,
    required this.role,
    this.createdAt,
    this.isActive = true,
  });

  // Конструктор из Firebase Auth + Firestore Data
  factory AppUser.fromFirebaseAuth(User firebaseUser, Map<String, dynamic>? data) {
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: data?['name'] ?? firebaseUser.displayName,
      phone: data?['phone'] ?? firebaseUser.phoneNumber,
      role: _parseUserRole(data?['role'] ?? 'user'),
      createdAt: data?['createdAt']?.toDate(),
      isActive: data?['isActive'] ?? true,
    );
  }

  // 🆕 Конструктор из DocumentSnapshot (для админ-панели)
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'],
      phone: data['phone'],
      role: _parseUserRole(data['role'] ?? 'user'),
      createdAt: data['createdAt']?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  static UserRole _parseUserRole(String roleString) {
    switch (roleString) {
      case 'admin':
        return UserRole.admin;
      case 'guest':
        return UserRole.guest;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  factory AppUser.guest() {
    return AppUser(
      uid: 'guest',
      email: 'guest',
      role: UserRole.guest,
      isActive: false,
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
      'role': _roleToString(role),
      'isActive': isActive,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.guest:
        return 'guest';
      case UserRole.user:
      default:
        return 'user';
    }
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    UserRole? role,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'AppUser{uid: $uid, email: $email, name: $name, role: $role, isAdmin: $isAdmin, isActive: $isActive}';
  }
}