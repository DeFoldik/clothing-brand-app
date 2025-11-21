import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Обновить имя пользователя
  static Future<void> updateName(String newName, String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    // Подтверждаем пароль
    await _reauthenticateUser(password);

    // Обновляем в Firestore
    await _firestore.collection('users').doc(user.uid).update({
      'name': newName,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Обновляем в Firebase Auth (displayName)
    await user.updateDisplayName(newName);
  }

  // Обновить email
  static Future<void> updateEmail(String newEmail, String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    // Подтверждаем пароль
    await _reauthenticateUser(password);

    // Обновляем email
    await user.verifyBeforeUpdateEmail(newEmail);

    // Обновляем в Firestore
    await _firestore.collection('users').doc(user.uid).update({
      'email': newEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Обновить телефон
  static Future<void> updatePhone(String newPhone, String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    // Подтверждаем пароль
    await _reauthenticateUser(password);

    // Обновляем в Firestore
    await _firestore.collection('users').doc(user.uid).update({
      'phone': newPhone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Сменить пароль
  static Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    // Подтверждаем текущий пароль
    await _reauthenticateUser(currentPassword);

    // Устанавливаем новый пароль
    await user.updatePassword(newPassword);
  }

  // Удалить аккаунт
  static Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    // Подтверждаем пароль
    await _reauthenticateUser(password);

    // Удаляем данные пользователя из Firestore
    await _deleteUserData(user.uid);

    // Удаляем аккаунт из Firebase Auth
    await user.delete();
  }

  // Удаление данных пользователя
  static Future<void> _deleteUserData(String userId) async {
    try {
      // Удаляем основные данные пользователя
      await _firestore.collection('users').doc(userId).delete();

      // Удаляем подколлекции пользователя
      final userRef = _firestore.collection('users').doc(userId);

      // Удаляем избранное
      final favorites = await userRef.collection('favorites').get();
      for (final doc in favorites.docs) {
        await doc.reference.delete();
      }

      // Удаляем корзину
      final cart = await userRef.collection('cart').get();
      for (final doc in cart.docs) {
        await doc.reference.delete();
      }

      // Удаляем адреса (из отдельной коллекции)
      final addresses = await _firestore.collection('addresses')
          .where('userId', isEqualTo: userId)
          .get();
      for (final doc in addresses.docs) {
        await doc.reference.delete();
      }

      print('✅ Данные пользователя удалены: $userId');
    } catch (e) {
      print('❌ Ошибка удаления данных пользователя: $e');
      // Не прерываем удаление аккаунта из-за ошибки удаления данных
    }
  }

  // services/account_service.dart

  static Future<void> _reauthenticateUser(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');
    if (user.email == null) throw Exception('Email пользователя не найден');

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Неверный пароль');
      } else if (e.code == 'user-mismatch') {
        throw Exception('Ошибка аутентификации');
      } else if (e.code == 'user-not-found') {
        throw Exception('Пользователь не найден');
      } else if (e.code == 'invalid-email') {
        throw Exception('Неверный формат email');
      } else if (e.code == 'network-request-failed') {
        throw Exception('Ошибка сети');
      } else {
        throw Exception('Ошибка подтверждения пароля: ${e.message}');
      }
    } catch (e) {
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  // Получить текущего пользователя
  static User? get currentUser => _auth.currentUser;
}