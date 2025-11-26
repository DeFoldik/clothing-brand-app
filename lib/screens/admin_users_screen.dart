import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/admin_service.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление пользователями'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: AdminService.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Ошибка загрузки пользователей'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Попробовать снова'),
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserCard(user, currentUser!);
            },
          );
        },
      ),
    );
  }
// В методе _buildUserCard добавьте отображение статуса активности
  Widget _buildUserCard(AppUser user, AppUser currentUser) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? 'Без имени',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(user.email),
                      if (user.phone != null) Text(user.phone!),
                      // 🆕 Показываем статус активности
                      Text(
                        user.isActive ? 'Активен' : 'Неактивен',
                        style: TextStyle(
                          color: user.isActive ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isAdmin ? Colors.blue[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.isAdmin ? 'АДМИН' : 'ПОЛЬЗОВАТЕЛЬ',
                    style: TextStyle(
                      color: user.isAdmin ? Colors.blue[800] : Colors.green[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (user.uid != currentUser.uid) // Не показываем действия для текущего пользователя
              Row(
                children: [
                  if (!user.isAdmin)
                    ElevatedButton(
                      onPressed: () => _makeAdmin(user.uid),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Сделать админом'),
                    ),
                  if (user.isAdmin)
                    ElevatedButton(
                      onPressed: () => _removeAdmin(user.uid),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Убрать админку'),
                    ),
                  const Spacer(),
                  // 🆕 Кнопка активации/деактивации
                  IconButton(
                    onPressed: () => _toggleUserStatus(user),
                    icon: Icon(
                      user.isActive ? Icons.person_off : Icons.person,
                      color: user.isActive ? Colors.orange : Colors.green,
                    ),
                    tooltip: user.isActive ? 'Деактивировать' : 'Активировать',
                  ),
                  IconButton(
                    onPressed: () => _deleteUser(user),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Удалить пользователя',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

// 🆕 Добавьте метод для переключения статуса
  Future<void> _toggleUserStatus(AppUser user) async {
    try {
      await AdminService.toggleUserStatus(user.uid, !user.isActive);
      _showSnackBar(user.isActive ? 'Пользователь деактивирован' : 'Пользователь активирован');
    } catch (e) {
      _showSnackBar('Ошибка: $e', isError: true);
    }
  }


  Future<void> _makeAdmin(String userId) async {
    try {
      await AdminService.updateUserRole(userId, UserRole.admin);
      _showSnackBar('Пользователь назначен администратором');
    } catch (e) {
      _showSnackBar('Ошибка: $e', isError: true);
    }
  }

  Future<void> _removeAdmin(String userId) async {
    try {
      await AdminService.updateUserRole(userId, UserRole.user);
      _showSnackBar('Права администратора сняты');
    } catch (e) {
      _showSnackBar('Ошибка: $e', isError: true);
    }
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пользователя?'),
        content: Text('Вы уверены, что хотите удалить пользователя ${user.name}? Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AdminService.deleteUser(user.uid);
        _showSnackBar('Пользователь удален');
      } catch (e) {
        _showSnackBar('Ошибка удаления: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}