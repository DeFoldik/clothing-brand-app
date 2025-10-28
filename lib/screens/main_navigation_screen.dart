import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const FavoritesScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  // 🎯 Функция для создания анимированных иконок
  Widget _buildAnimatedIcon(int index, IconData icon) {
    final isSelected = index == _currentIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..scale(isSelected ? 1.2 : 1.0),
      child: Icon(
        icon,
        color: isSelected ? Colors.black : Colors.grey[400],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,

          // 🎨 НАСТРОЙКИ
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          iconSize: 28,
          selectedFontSize: 0,
          unselectedFontSize: 0,

          items: [
            // 🏠 Главная
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(0, Icons.home),
              label: '',
            ),
            // 🔍 Поиск
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(1, Icons.search),
              label: '',
            ),
            // ❤️ Избранное
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(2, Icons.favorite),
              label: '',
            ),
            // 🛒 Корзина
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(3, Icons.shopping_cart),
              label: '',
            ),
            // 👤 Профиль
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(4, Icons.person),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}