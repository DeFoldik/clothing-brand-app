// providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthProvider with ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user?.isLoggedIn ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;
  String? get error => _error;

  AuthProvider() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        _user = AppUser.guest();
      } else {
        await _loadUserData(firebaseUser.uid);
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final firebaseUser = FirebaseAuth.instance.currentUser!;

      if (doc.exists) {
        _user = AppUser.fromFirebaseAuth(firebaseUser, doc.data());
      } else {
        // Создаем базового пользователя если нет в Firestore
        _user = AppUser(
          uid: uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName, // Может быть null
          phone: firebaseUser.phoneNumber, // Может быть null
          role: UserRole.user,
        );
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Fallback на базовые данные из Firebase Auth
      final firebaseUser = FirebaseAuth.instance.currentUser!;
      _user = AppUser(
        uid: uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName,
        phone: firebaseUser.phoneNumber,
        role: UserRole.user,
      );
    }
  }

  // В providers/auth_provider.dart обновите метод register:
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      print('🎯 НАЧАЛО РЕГИСТРАЦИИ');
      print('📧 Email: $email');
      print('👤 Имя: $name');
      print('📞 Телефон: $phone');

      _isLoading = true;
      _error = null;
      notifyListeners();

      // 🎯 ТЕСТОВАЯ РЕГИСТРАЦИЯ (временная)
      print('🔧 Используем тестовую регистрацию');

      await Future.delayed(const Duration(seconds: 1));

      final UserRole role = _determineUserRole(email);
      print('🎭 Определена роль: $role');

      _user = AppUser(
        uid: 'test_uid_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );

      print('✅ РЕГИСТРАЦИЯ УСПЕШНА');
      print('📊 Новый пользователь: ${_user?.toJson()}');

    } catch (e, stackTrace) {
      print('❌ ОШИБКА РЕГИСТРАЦИИ: $e');
      print('📋 StackTrace: $stackTrace');
      _error = 'Произошла ошибка при регистрации: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🎯 Логин
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      await _loadUserData(FirebaseAuth.instance.currentUser!.uid);

    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
    } catch (e) {
      _error = 'Произошла ошибка при входе: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🎯 Выход
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _user = AppUser.guest();
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка при выходе: $e';
      notifyListeners();
    }
  }

  UserRole _determineUserRole(String email) {
    final domain = email.split('@').last.toLowerCase();
    const adminDomains = ['tommysinny.ru', 'company.com', 'admin.ru'];
    return adminDomains.contains(domain) ? UserRole.admin : UserRole.user;
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found': return 'Пользователь не найден';
      case 'wrong-password': return 'Неверный пароль';
      case 'email-already-in-use': return 'Email уже используется';
      case 'weak-password': return 'Пароль слишком слабый';
      case 'invalid-email': return 'Неверный формат email';
      default: return 'Произошла ошибка';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}