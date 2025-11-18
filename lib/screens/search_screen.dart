// screens/search_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/filter_bottom_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';

  // 🎯 КАТЕГОРИИ КАК ВЫ ХОТИТЕ
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Все', 'category': 'all', 'icon': Icons.grid_view},
    {'name': 'Верхняя одежда', 'category': 'jackets', 'iconPath': 'assets/icons/down-jacket.svg'},
    {'name': 'Худи и толстовки', 'category': 'hoodies', 'iconPath': 'assets/icons/sweatshirt.svg'},
    {'name': 'Футболки', 'category': 'tshirts', 'iconPath': 'assets/icons/t-shirt.svg'},
    {'name': 'Лонгсливы', 'category': 'longsleeves', 'iconPath': 'assets/icons/longsleeve.svg'},
    {'name': 'Шорты', 'category': 'shorts', 'iconPath': 'assets/icons/knickers.svg'},
    {'name': 'Штаны', 'category': 'pants', 'iconPath': 'assets/icons/trousers.svg'},
    {'name': 'Головные уборы', 'category': 'headwear', 'iconPath': 'assets/icons/beanie.svg'},
  ];

  // 🎯 ФИЛЬТРЫ
  Map<String, dynamic> _activeFilters = {
    'category': 'all',
    'sizes': [],
    'colors': [],
    'priceRange': {'min': 0, 'max': 1000},
    'sortBy': 'popular',
  };

  // 🎯 ЗАГЛУШКА ДЛЯ ТОВАРОВ
  final List<Product> _allProducts = [];
  List<Product> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchResults = _allProducts;
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = query;
      _searchResults = _allProducts.where((product) {
        final matchesSearch = product.title.toLowerCase().contains(query) ||
            product.description.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == 'all' ||
            _getProductCategory(product) == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  String _getProductCategory(Product product) {
    final title = product.title.toLowerCase();
    if (title.contains('jacket') || title.contains('coat') || title.contains('курт') || title.contains('пальт')) return 'jackets';
    if (title.contains('hoodie') || title.contains('sweatshirt') || title.contains('худи') || title.contains('толстов')) return 'hoodies';
    if (title.contains('t-shirt') || title.contains('tshirt') || title.contains('футбол')) return 'tshirts';
    if (title.contains('longsleeve') || title.contains('лонгслив')) return 'longsleeves';
    if (title.contains('tracksuit') || title.contains('sport') || title.contains('спортив')) return 'tracksuits';
    if (title.contains('short') || title.contains('шорт')) return 'shorts';
    if (title.contains('pant') || title.contains('trouser') || title.contains('брюк')) return 'pants';
    if (title.contains('cap') || title.contains('hat') || title.contains('кепк') || title.contains('шапк')) return 'headwear';
    return 'other';
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _activeFilters['category'] = category;
      _performSearch();
    });
  }

  void _openFilters() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        activeFilters: _activeFilters,
        onFiltersChanged: (newFilters) {
          setState(() {
            _activeFilters = newFilters;
            _applyFilters();
          });
        },
      ),
    );
  }

  void _applyFilters() {
    _performSearch();
  }

  void _sortProducts(String sortBy) {
    setState(() {
      _activeFilters['sortBy'] = sortBy;
      switch (sortBy) {
        case 'price_low':
          _searchResults.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          _searchResults.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'newest':
          _searchResults.shuffle();
          break;
        case 'popular':
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = _activeFilters['sizes'].isNotEmpty ||
        _activeFilters['colors'].isNotEmpty ||
        _activeFilters['priceRange']['min'] > 0 ||
        _activeFilters['priceRange']['max'] < 1000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _openFilters,
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🎯 ПОИСКОВАЯ СТРОКА
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск товаров...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch();
                        },
                      ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort),
                      onSelected: _sortProducts,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'popular',
                          child: Text('По популярности'),
                        ),
                        const PopupMenuItem(
                          value: 'price_low',
                          child: Text('По цене (сначала дешевые)'),
                        ),
                        const PopupMenuItem(
                          value: 'price_high',
                          child: Text('По цене (сначала дорогие)'),
                        ),
                        const PopupMenuItem(
                          value: 'newest',
                          child: Text('По новизне'),
                        ),
                      ],
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                _performSearch();
              },
            ),
          ),

          // 🎯 КАТЕГОРИИ
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isAllCategory = category['category'] == 'all'; // Проверяем это "Все" категория

                return CategoryChip(
                  category: category,
                  isSelected: _selectedCategory == category['category'],
                  onTap: () => _filterByCategory(category['category'] as String),
                  isAllCategory: isAllCategory, // Передаем флаг
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 🎯 АКТИВНЫЕ ФИЛЬТРЫ
          if (hasActiveFilters) _buildActiveFilters(),

          // 🎯 РЕЗУЛЬТАТЫ ПОИСКА
          Expanded(
            child: _searchResults.isEmpty
                ? _buildEmptyState()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_activeFilters['sizes'].isNotEmpty)
            ..._activeFilters['sizes'].map<Widget>((size) => _buildFilterChip(
              'Размер: $size',
              onRemove: () {
                setState(() {
                  _activeFilters['sizes'].remove(size);
                  _applyFilters();
                });
              },
            )),
          if (_activeFilters['colors'].isNotEmpty)
            ..._activeFilters['colors'].map<Widget>((color) => _buildFilterChip(
              'Цвет: $color',
              onRemove: () {
                setState(() {
                  _activeFilters['colors'].remove(color);
                  _applyFilters();
                });
              },
            )),
          if (_activeFilters['priceRange']['min'] > 0 || _activeFilters['priceRange']['max'] < 1000)
            _buildFilterChip(
              'Цена: \$${_activeFilters['priceRange']['min']} - \$${_activeFilters['priceRange']['max']}',
              onRemove: () {
                setState(() {
                  _activeFilters['priceRange'] = {'min': 0, 'max': 1000};
                  _applyFilters();
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {required VoidCallback onRemove}) {
    return Chip(
      label: Text(label),
      onDeleted: onRemove,
      backgroundColor: Colors.blue[50],
      labelStyle: const TextStyle(fontSize: 12),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Начните поиск' : 'Ничего не найдено',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Попробуйте изменить запрос или фильтры',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _activeFilters = {
                    'category': 'all',
                    'sizes': [],
                    'colors': [],
                    'priceRange': {'min': 0, 'max': 1000},
                    'sortBy': 'popular',
                  };
                  _selectedCategory = 'all';
                  _performSearch();
                });
              },
              child: const Text('Сбросить фильтры'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          return ProductCard(product: _searchResults[index]);
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}