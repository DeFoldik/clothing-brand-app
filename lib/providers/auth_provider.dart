// providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../services/favorite_service.dart';

class AuthProvider with ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  bool get isLoggedIn => _user?.isLoggedIn ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;
  String? get error => _error;

  AuthProvider() {
    _init();
  }

  void _init() {
    print(' AuthProvider инициализирован');
    _user = AppUser.guest();
    notifyListeners();

    // Слушаем изменения аутентификации
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) async {
      print('🔄 Изменение состояния аутентификации: ${firebaseUser?.email}');

      if (firebaseUser == null) {
        _user = AppUser.guest();
        print('👤 Установлен гостевой режим');
      } else {
        print('👤 Пользователь из Firebase: ${firebaseUser.email}');
        await _loadUserData(firebaseUser.uid);
      }

      //  Завершаем инициализацию
      _isInitializing = false;
      notifyListeners();
    });

    //  Таймаут на случай если authStateChanges не сработает
    Future.delayed(const Duration(seconds: 3), () {
      if (_isInitializing) {
        print('⏰ Таймаут инициализации AuthProvider');
        _isInitializing = false;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      print('📥 Загрузка данных пользователя: $uid');

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        print('📄 Данные из Firestore: $data');

        final role = _determineUserRole(data['email'] ?? '');
        print('🎭 Определена роль: $role для email: ${data['email']}');

        _user = AppUser(
          uid: uid,
          email: data['email'] ?? '',
          name: data['name'] ?? 'Пользователь',
          phone: data['phone'] ?? '',
          role: role,
          createdAt: data['createdAt']?.toDate(),
        );

        print('✅ Пользователь загружен: ${_user?.email}, роль: ${_user?.role}');
      } else {
        print('❌ Пользователь не найден в Firestore, создаем запись...');

        final firebaseUser = FirebaseAuth.instance.currentUser!;
        final role = _determineUserRole(firebaseUser.email ?? '');

        print('🎭 Новая роль: $role для email: ${firebaseUser.email}');

        final newUser = AppUser(
          uid: uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'Пользователь',
          phone: firebaseUser.phoneNumber ?? '',
          role: role,
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({
          'email': newUser.email,
          'name': newUser.name,
          'phone': newUser.phone,
          'role': describeEnum(newUser.role),
          'createdAt': FieldValue.serverTimestamp(),
        });

        _user = newUser;
        print('✅ Создана новая запись в Firestore: ${newUser.email}');
      }
    } catch (e) {
      print('❌ Ошибка загрузки пользователя: $e');
      final firebaseUser = FirebaseAuth.instance.currentUser!;
      _user = AppUser(
        uid: uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'Пользователь',
        phone: firebaseUser.phoneNumber ?? '',
        role: UserRole.user,
      );
    }
  }

  //  РЕГИСТРАЦИЯ
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 Начало регистрации: $email');
      print('📝 Данные: name=$name, phone=$phone');

      // 1. Создаем в Firebase Auth
      print('1. Создаем пользователя в Firebase Auth...');
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      print('✅ Пользователь создан в Firebase Auth: ${userCredential.user?.uid}');

      // 2. Определяем роль
      final UserRole role = _determineUserRole(email);
      print('2. Определена роль: $role для email: $email');

      // 3. Сохраняем в Firestore
      print('3. Сохраняем в Firestore...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'phone': phone,
        'email': email,
        'role': describeEnum(role),
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Данные сохранены в Firestore');

      // 4. Обновляем displayName
      print('4. Обновляем displayName...');
      await userCredential.user!.updateDisplayName(name);

      print('✅ Регистрация завершена успешно: $email');

    } on FirebaseAuthException catch (e) {
      print('❌ Ошибка Firebase Auth: ${e.code} - ${e.message}');
      _error = _getAuthErrorMessage(e.code);
    } catch (e) {
      print('❌ Общая ошибка регистрации: $e');
      _error = 'Произошла ошибка при регистрации: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //  ВХОД
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 Попытка входа: $email');

      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      print('✅ Вход успешен: ${userCredential.user?.email}');

      //  МИГРАЦИЯ ЛАЙКОВ ПОСЛЕ УСПЕШНОГО ВХОДА
      if (userCredential.user != null) {
        await FavoriteService.migrateFavoritesOnLogin(userCredential.user!.uid);
      }

    } on FirebaseAuthException catch (e) {
      print('❌ Ошибка входа: ${e.code} - ${e.message}');
      _error = _getAuthErrorMessage(e.code);
    } catch (e) {
      print('❌ Общая ошибка входа: $e');
      _error = 'Произошла ошибка при входе: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _user = AppUser.guest();
      print('✅ Выход выполнен');
    } catch (e) {
      _error = 'Ошибка при выходе';
      print('❌ Ошибка выхода: $e');
    } finally {
      notifyListeners();
    }
  }

  UserRole _determineUserRole(String email) {
    print('🔍 Определение роли для email: $email');
    final domain = email.split('@').last.toLowerCase();
    print('🔍 Домен email: $domain');

    const adminDomains = ['tommysinny.ru', 'company.com', 'admin.ru'];
    final isAdmin = adminDomains.contains(domain);

    print(' Результат: ${isAdmin ? 'ADMIN' : 'USER'}');
    return isAdmin ? UserRole.admin : UserRole.user;
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential': return 'Проверьте введеные данные';
      case 'user-not-found': return 'Пользователь не найден';
      case 'wrong-password': return 'Неверный пароль';
      case 'email-already-in-use': return 'Email уже используется';
      case 'weak-password': return 'Пароль слишком слабый';
      case 'invalid-email': return 'Неверный формат email';
      case 'network-request-failed':
        return 'Ошибка сети. Проверьте подключение к интернету';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      case 'user-disabled':
        return 'Аккаунт заблокирован';
      case 'operation-not-allowed':
        return 'Операция не разрешена';
      default:
        return 'Произошла ошибка. Попробуйте снова';
    }
  }

  Future<void> refreshUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _loadUserData(user.uid);
      notifyListeners(); // Это важно - уведомляем слушателей об изменении
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}