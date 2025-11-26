// screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/favorite_service.dart';
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
  StreamSubscription<List<int>>? _favoritesSubscription;

  @override
  void initState() {
    super.initState();
    print('🎬 Инициализация экрана избранного');
    _setupFavoritesStream();
  }

  void _setupFavoritesStream() {
    // Слушаем изменения в избранном
    _favoritesSubscription = FavoriteService.favoritesStream.listen(
            (favoriteIds) {
          print('🔄 Получены обновленные лайки: $favoriteIds');
          _loadFavoriteProducts();
        },
        onError: (error) {
          print('❌ Ошибка в stream избранного: $error');
          _loadFavoriteProducts();
        }
    );

    // Первоначальная загрузка
    _loadFavoriteProducts();
  }

  Future<void> _loadFavoriteProducts() async {
    try {
      print('🔄 Начинаем загрузку избранных товаров из Firebase...');

      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = '';
        });
      }

      //  ИСПОЛЬЗУЕМ НОВЫЙ МЕТОД ДЛЯ ПОЛУЧЕНИЯ ТОВАРОВ ИЗ FIREBASE
      final favorites = await FavoriteService.getFavoriteProducts();

      print('✅ Найдено избранных товаров: ${favorites.length}');
      print('📋 Товары: ${favorites.map((p) => '${p.id}: ${p.title}').toList()}');

      if (mounted) {
        setState(() {
          _favoriteProducts = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Ошибка загрузки избранных товаров: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _favoriteProducts = [];
        });
      }
    }
  }

  //  Callback для обновления при изменении лайка
  void _onFavoriteChanged() {
    print('🔄 Обновляем экран из-за изменения лайка');
    _loadFavoriteProducts();
  }

  //  Метод для RefreshIndicator
  Future<void> _refreshFavorites() async {
    await _loadFavoriteProducts();
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshFavorites,
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'debug') {
                final favorites = await FavoriteService.getFavoriteIds();
                final products = _favoriteProducts.map((p) => '${p.id}: ${p.title}').toList();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Лайков: ${favorites.length}\n'
                            'ID: $favorites\n'
                            'Товары: $products'
                    ),
                    duration: const Duration(seconds: 5),
                  ),
                );
              } else if (value == 'clear') {
                await FavoriteService.clearFavorites();
                _refreshFavorites();
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
        onRefresh: _refreshFavorites,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemCount: _favoriteProducts.length,
          itemBuilder: (context, index) {
            final product = _favoriteProducts[index];
            return ProductCard(
              product: product,
              onFavoriteChanged: _onFavoriteChanged,
            );
          },
        ),
      ),
    );
  }

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
            onPressed: _refreshFavorites,
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }
}