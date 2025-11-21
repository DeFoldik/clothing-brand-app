// screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/product.dart';
import '../models/categories.dart';
import '../widgets/product_card.dart';
import '../widgets/event_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🎯 БАННЕРЫ ИВЕНТОВ
  final List<Map<String, dynamic>> _eventBanners = [
    {
      'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=500',
      'title': 'Новая Осенняя Коллекция',
      'subtitle': 'Открой для себя свежие тренды',
    },
    {
      'image': 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=500',
      'title': 'Распродажа до 50%',
      'subtitle': 'Успей до конца недели',
    },
    {
      'image': 'https://images.unsplash.com/photo-1601924582970-9238bcb495d9?w=500',
      'title': 'Бестселлеры',
      'subtitle': 'То, что выбирают другие',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 🎯 APP BAR
          const SliverAppBar(
            title: Text('Fashion Store'),
            floating: true,
            snap: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),

          // 🎯 БАННЕРЫ
          SliverToBoxAdapter(
            child: EventBanner(
              banners: _eventBanners,
              height: 300,
            ),
          ),

          // 🎯 СЕКЦИЯ: САМЫЕ ПОПУЛЯРНЫЕ
          _buildProductSectionStream(
            title: '🔥 Самые популярные',
            subtitle: 'То, что выбирают наши клиенты',
            stream: FirestoreService.getPopularProducts(),
          ),

          // 🎯 СЕКЦИЯ: НОВИНКИ
          _buildProductSectionStream(
            title: '🆕 Новинки',
            subtitle: 'Самые свежие поступления',
            stream: FirestoreService.getNewProducts(),
          ),

          // 🎯 СЕКЦИЯ: ТОВАРЫ СО СКИДКОЙ
          _buildProductSectionStream(
            title: '💰 Товары со скидкой',
            subtitle: 'Особые предложения этой недели',
            stream: FirestoreService.getDiscountedProducts(),
          ),

          // 🎯 СЕКЦИЯ: КАТЕГОРИИ
          _buildCategoriesSection(),

          // 🎯 СЕКЦИЯ: ВСЕ ТОВАРЫ
          _buildProductSectionStream(
            title: '🛍️ Все товары',
            subtitle: 'Полный ассортимент магазина',
            stream: FirestoreService.getProductsStream(),
          ),
        ],
      ),
    );
  }

  // 🎯 СЕКЦИЯ КАТЕГОРИЙ
  Widget _buildCategoriesSection() {
    final categories = FirestoreService.getCategories();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Категории',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Выберите интересующую категорию',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // ГРИД КАТЕГОРИЙ
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(category);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 КАРТОЧКА КАТЕГОРИИ
  Widget _buildCategoryCard(ProductCategory category) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: Переход на экран категории
          print('Выбрана категория: ${category.displayName}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Добавить иконки для категорий
            Icon(
              Icons.category,
              size: 32,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            Text(
              category.displayName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 УНИВЕРСАЛЬНАЯ СЕКЦИЯ ТОВАРОВ С STREAM
  Widget _buildProductSectionStream({
    required String title,
    required String subtitle,
    required Stream<List<Product>> stream,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            StreamBuilder<List<Product>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingGrid();
                }

                if (snapshot.hasError) {
                  print('❌ Ошибка в секции "$title": ${snapshot.error}');
                  return _buildErrorSection(snapshot.error.toString());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptySection(title);
                }

                final products = snapshot.data!;
                return _buildProductsGrid(products);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 СЕТКА ТОВАРОВ
  Widget _buildProductsGrid(List<Product> products) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          onFavoriteChanged: () {
            setState(() {});
          },
        );
      },
    );
  }

  // 🎯 ЗАГРУЗКА
  Widget _buildLoadingGrid() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Загрузка товаров...',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 ПУСТАЯ СЕКЦИЯ
  Widget _buildEmptySection(String sectionName) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 32,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'В разделе "$sectionName" пока нет товаров',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 ОШИБКА
  Widget _buildErrorSection(String error) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 32,
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            Text(
              'Ошибка загрузки',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Проверьте подключение к интернету',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}