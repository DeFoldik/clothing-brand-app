import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/favorite_service.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    print('🎬 Инициализация экрана избранного');
    _loadFavoriteProducts();
  }

  Future<void> _loadFavoriteProducts() async {
    try {
      print('🔄 Начинаем загрузку избранных товаров...');
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final favoriteIds = await FavoriteService.getFavoriteIds();
      print('📋 ID избранных товаров: $favoriteIds');

      if (favoriteIds.isEmpty) {
        print('ℹ️ Нет избранных товаров');
        setState(() {
          _favoriteProducts = [];
          _isLoading = false;
        });
        return;
      }

      final allProducts = await ApiService.getProducts();
      print('📦 Всего товаров: ${allProducts.length}');

      final favorites = allProducts.where(
              (product) => favoriteIds.contains(product.id)
      ).toList();

      print('✅ Найдено избранных товаров: ${favorites.length}');

      setState(() {
        _favoriteProducts = favorites;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Ошибка загрузки избранных товаров: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // 🎯 Callback для обновления при изменении лайка
  void _onFavoriteChanged() {
    print('🔄 Обновляем экран из-за изменения лайка');
    _loadFavoriteProducts();
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ Строим экран избранного. Загрузка: $_isLoading, Ошибка: $_error, Товаров: ${_favoriteProducts.length}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadFavoriteProducts,
            icon: const Icon(Icons.refresh),
          ),
          // Кнопка для отладки
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'debug') {
                final favorites = await FavoriteService.getFavoriteIds();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Лайков: ${favorites.length}\nID: $favorites'),
                    duration: const Duration(seconds: 5),
                  ),
                );
              } else if (value == 'clear') {
                await FavoriteService.clearFavorites();
                _loadFavoriteProducts();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'debug',
                child: Text('Показать отладочную информацию'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Очистить все лайки'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : _error.isNotEmpty
          ? _buildErrorScreen()
          : _favoriteProducts.isEmpty
          ? _buildEmptyState()
          : _buildFavoritesGrid(),
    );
  }

  Widget _buildFavoritesGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: RefreshIndicator(
        onRefresh: _loadFavoriteProducts,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemCount: _favoriteProducts.length,
          itemBuilder: (context, index) {
            return ProductCard(
              product: _favoriteProducts[index],
              onFavoriteChanged: _onFavoriteChanged, // Передаем callback
            );
          },
        ),
      ),
    );
  }

  // 🎯 Пустой экран
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'В избранном пусто',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Добавляйте товары, нажимая на сердечко',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Ошибка загрузки',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _error,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadFavoriteProducts,
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }
}