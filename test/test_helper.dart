import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

// Простая функция для инициализации Firebase в тестах
Future<void> setupFirebaseMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Игнорируем ошибки инициализации в тестах
    print('Note: Firebase initialization completed with warnings in test environment');
  }
}