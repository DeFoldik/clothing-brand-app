import 'package:flutter_test/flutter_test.dart';
import 'package:store/models/app_user.dart';

void main() {
  group('AppUser Model', () {
    test('should create user with correct properties', () {
      final user = AppUser(
        uid: 'user123',
        email: 'test@example.com',
        name: 'Test User',
        phone: '+79998887766',
        role: UserRole.admin,
        createdAt: DateTime(2024, 1, 1),
        isActive: true,
      );

      expect(user.uid, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.phone, '+79998887766');
      expect(user.role, UserRole.admin);
      expect(user.isAdmin, true);
      expect(user.isLoggedIn, true);
      expect(user.isActive, true);
    });

    test('guest user should have correct properties', () {
      final guest = AppUser.guest();

      expect(guest.uid, 'guest');
      expect(guest.email, 'guest');
      expect(guest.role, UserRole.guest);
      expect(guest.isLoggedIn, false);
      expect(guest.isAdmin, false);
      expect(guest.isActive, false);
    });

    test('should determine admin role from email', () {
      final adminUser = AppUser(
        uid: 'admin1',
        email: 'admin@tommysinny.ru', // Админский домен
        name: 'Admin User',
        role: UserRole.admin,
      );

      final regularUser = AppUser(
        uid: 'user1',
        email: 'user@gmail.com', // Обычный домен
        name: 'Regular User',
        role: UserRole.user,
      );

      expect(adminUser.isAdmin, true);
      expect(regularUser.isAdmin, false);
    });

    test('should convert to json correctly', () {
      final user = AppUser(
        uid: 'json123',
        email: 'json@example.com',
        name: 'JSON User',
        phone: '+79998887766',
        role: UserRole.user,
        createdAt: DateTime(2024, 1, 1),
        isActive: true,
      );

      final json = user.toJson();

      expect(json['uid'], 'json123');
      expect(json['email'], 'json@example.com');
      expect(json['name'], 'JSON User');
      expect(json['phone'], '+79998887766');
      expect(json['role'], 'user');
      expect(json['isActive'], true);
    });

    test('should copy with new values', () {
      final original = AppUser(
        uid: 'original',
        email: 'original@example.com',
        name: 'Original',
        role: UserRole.user,
      );

      final updated = original.copyWith(
        name: 'Updated Name',
        phone: '+79998887766',
      );

      expect(updated.uid, 'original');
      expect(updated.email, 'original@example.com');
      expect(updated.name, 'Updated Name');
      expect(updated.phone, '+79998887766');
      expect(updated.role, UserRole.user);
    });

    test('should provide correct string representation', () {
      final user = AppUser(
        uid: 'test123',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.admin,
        isActive: true,
      );

      final str = user.toString();

      expect(str, contains('test123'));
      expect(str, contains('test@example.com'));
      expect(str, contains('Test User'));
      expect(str, contains('admin'));
      expect(str, contains('isAdmin: true'));
      expect(str, contains('isActive: true'));
    });
  });
}