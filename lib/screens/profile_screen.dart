// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';
import 'order_history_screen.dart';
import 'admin_panel_screen.dart';
import '../models/app_user.dart';
import 'debug_screen.dart';
import 'address_management_screen.dart';
import 'account_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isInitializing) {
      return _buildLoadingScreen();
    }

    //  Для незарегистрированных пользователей
   if (!authProvider.isLoggedIn) {
      return const AuthScreen();
    }

    //  Для зарегистрированных пользователей
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: _buildUserProfile(context),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          //  ШАПКА ПРОФИЛЯ
          _buildProfileHeader(user),
          const SizedBox(height: 32),

          //  ОСНОВНЫЕ КАРТОЧКИ
          _buildProfileCards(context, user),
          const SizedBox(height: 24),

          //  АДМИН ПАНЕЛЬ (только для админов)
          if (user.isAdmin) _buildAdminPanel(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(AppUser user) {  // AppUser вместо User
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // АВАТАР
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // ИМЯ И СТАТУС
            Text(
              user.name ?? 'Пользователь',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // EMAIL
            Text(
              user.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),

            // СТАТУС (USER/ADMIN)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: user.isAdmin ? Colors.blue[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.isAdmin ? 'АДМИНИСТРАТОР' : 'ПОКУПАТЕЛЬ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: user.isAdmin ? Colors.blue[800] : Colors.green[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCards(BuildContext context, AppUser user) {  // AppUser вместо User
    return Column(
      children: [

        //  ИСТОРИЯ ЗАКАЗОВ
        _buildProfileCard(
          icon: Icons.shopping_bag,
          title: 'История заказов',
          subtitle: 'Просмотр и отслеживание заказов',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
          ),
        ),
        const SizedBox(height: 16),

        //  НАСТРОЙКИ АККАУНТА
        _buildProfileCard(
          icon: Icons.settings,
          title: 'Настройки аккаунта',
          subtitle: 'Имя, телефон, email, пароль',
          onTap: () => _showAccountSettings(context),
        ),
        const SizedBox(height: 16),

        //  АДРЕСА ДОСТАВКИ
        _buildProfileCard(
          icon: Icons.location_on,
          title: 'Адреса доставки',
          subtitle: 'Управление адресами доставки',
          onTap: () => _showAddressManagement(context),
        ),
      ],
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAdminPanel(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Панель администратора',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child:
                _buildAdminChip(
                  'Просмотр',
                  Icons.remove_red_eye_sharp,
                      () => _navigateToAdminPanel(context, 'products'),
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminChip(String text, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      onPressed: onTap,
      backgroundColor: Colors.blue[100],
    );
  }

  void _navigateToAdminPanel(BuildContext context, String section) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminPanelScreen(),
      ),
    );
  }

  void _showAccountSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
    );
  }

  void _showAddressManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressManagementScreen()),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: const Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

//  БОТТОМ ШИИТ НАСТРОЕК АККАУНТА
class AccountSettingsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Настройки аккаунта',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingItem('Изменить имя', Icons.person, () {}),
          _buildSettingItem('Изменить телефон', Icons.phone, () {}),
          _buildSettingItem('Изменить email', Icons.email, () {}),
          _buildSettingItem('Сменить пароль', Icons.lock, () {}),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}