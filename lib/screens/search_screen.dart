// screens/search_screen.dart
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/product.dart';
import '../models/categories.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/compact_filter_row.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  ProductCategory _selectedCategory = ProductCategory.all;
  String _selectedSort = 'popular';

  //  ФИЛЬТРЫ
  Map<String, dynamic> _activeFilters = {
    'sizes': <String>[],
    'colors': <String>[],
    'priceRange': {'min': 0, 'max': 500},
  };

  //  ДОСТУПНЫЕ ФИЛЬТРЫ
  List<String> _availableSizes = [];
  List<String> _availableColors = [];
  bool _isLoadingFilters = false;

  //  КАТЕГОРИИ ДЛЯ ПОИСКА
  final List<ProductCategory> _categories = FirestoreService.getCategories();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadAvailableFilters();
  }

  void _loadAvailableFilters() async {
    setState(() {
      _isLoadingFilters = true;
    });

    final filters = await FirestoreService.getAvailableFilters();

    setState(() {
      _availableSizes = filters['sizes'] ?? [];
      _availableColors = filters['colors'] ?? [];
      _isLoadingFilters = false;
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _performSearch() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _filterByCategory(ProductCategory category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = ProductCategory.all;
      _selectedSort = 'popular';
      _activeFilters = {
        'sizes': <String>[],
        'colors': <String>[],
        'priceRange': {'min': 0, 'max': 500},
      };
    });
  }

  void _sortProducts(String sortBy) {
    setState(() {
      _selectedSort = sortBy;
    });
  }

  //  ПОЛУЧЕНИЕ STREAM С ФИЛЬТРАМИ И СОРТИРОВКОЙ
  Stream<List<Product>> get _productsStream {
    // БЕЗОПАСНОЕ ПРИВЕДЕНИЕ ТИПОВ ДЛЯ ФИЛЬТРОВ
    final sizes = _activeFilters['sizes'] is List<String>
        ? _activeFilters['sizes'] as List<String>
        : (_activeFilters['sizes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    final colors = _activeFilters['colors'] is List<String>
        ? _activeFilters['colors'] as List<String>
        : (_activeFilters['colors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    final priceRange = _activeFilters['priceRange'] as Map<String, dynamic>? ?? {'min': 0, 'max': 500};

    return FirestoreService.searchProductsWithFilters(
      searchQuery: _searchQuery,
      category: _selectedCategory,
      sizes: sizes,
      colors: colors,
      minPrice: (priceRange['min'] ?? 0).toDouble(),
      maxPrice: (priceRange['max'] ?? 500).toDouble(),
      sortBy: _selectedSort,
    );
  }

  bool get _hasActiveSearch {
    return _searchQuery.isNotEmpty ||
        !_selectedCategory.isAll ||
        _activeFilters['sizes'].isNotEmpty ||
        _activeFilters['colors'].isNotEmpty ||
        _activeFilters['priceRange']['min'] > 0 ||
        _activeFilters['priceRange']['max'] < 500;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_hasActiveSearch)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearSearch,
              tooltip: 'Очистить все фильтры',
            ),
        ],
      ),
      body: Column(
        children: [
          //  ПОИСКОВАЯ СТРОКА
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Поиск по названию...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => _performSearch(),
              onSubmitted: (value) => _performSearch(),
            ),
          ),

          //  КАТЕГОРИИ ДЛЯ БЫСТРОГО ФИЛЬТРА
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return CategoryChip(
                  category: {
                    'name': category.displayName,
                    'category': category.toFirestore(),
                    'isAllCategory': category.isAll,
                  },
                  isSelected: _selectedCategory == category,
                  onTap: () => _filterByCategory(category),
                  isAllCategory: category.isAll,
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          //  КОМПАКТНЫЕ ФИЛЬТРЫ И СОРТИРОВКА
          CompactFilterRow(
            activeFilters: _activeFilters,
            availableSizes: _availableSizes,
            availableColors: _availableColors,
            onFiltersChanged: (newFilters) {
              setState(() {
                _activeFilters = newFilters;
              });
            },
            selectedSort: _selectedSort,
            onSortChanged: _sortProducts,
          ),

          const SizedBox(height: 8),

          //  АКТИВНЫЕ ФИЛЬТРЫ
          if (_hasActiveSearch) _buildActiveFilters(),

          const SizedBox(height: 8),

          //  ИНФОРМАЦИЯ О ВЫБРАННЫХ ФИЛЬТРАХ
          if (_hasActiveSearch) _buildSearchInfo(),

          const SizedBox(height: 8),

          //  РЕЗУЛЬТАТЫ ПОИСКА
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _productsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildSearchResults(products);
              },
            ),
          ),
        ],
      ),
    );
  }
// В search_screen.dart - обнови метод _buildActiveFilters
  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          if (_searchQuery.isNotEmpty)
            _buildFilterChip(
              'Поиск: "$_searchQuery"',
              onRemove: () {
                _searchController.clear();
                _performSearch();
              },
            ),
          if (!_selectedCategory.isAll)
            _buildFilterChip(
              'Категория: ${_selectedCategory.displayName}',
              onRemove: () {
                setState(() {
                  _selectedCategory = ProductCategory.all;
                });
              },
            ),
          if (_activeFilters['sizes'] != null && _activeFilters['sizes'].isNotEmpty)
            ..._activeFilters['sizes'].map<Widget>((size) => _buildFilterChip(
              'Размер: $size',
              onRemove: () {
                setState(() {
                  _activeFilters['sizes'].remove(size);
                });
              },
            )),
          if (_activeFilters['colors'] != null && _activeFilters['colors'].isNotEmpty)
            ..._activeFilters['colors'].map<Widget>((color) => _buildFilterChip(
              'Цвет: $color',
              onRemove: () {
                setState(() {
                  _activeFilters['colors'].remove(color);
                });
              },
            )),
          if (_activeFilters['priceRange'] != null &&
              (_activeFilters['priceRange']['min'] > 0 || _activeFilters['priceRange']['max'] < 500))
            _buildFilterChip(
              'Цена: \$${_activeFilters['priceRange']['min']} - \$${_activeFilters['priceRange']['max']}',
              onRemove: () {
                setState(() {
                  _activeFilters['priceRange'] = {'min': 0, 'max': 500};
                });
              },
            ),
          if (_selectedSort != 'popular')
            _buildFilterChip(
              'Сортировка: ${_getSortName(_selectedSort)}',
              onRemove: () {
                setState(() {
                  _selectedSort = 'popular';
                });
              },
            ),
        ],
      ),
    );
  }

  String _getSortName(String sortValue) {
    switch (sortValue) {
      case 'price_high': return 'Сначала дорогие';
      case 'price_low': return 'Сначала дешевые';
      case 'newest': return 'По новизне';
      default: return 'По популярности';
    }
  }

  Widget _buildSearchInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder<List<Product>>(
            stream: _productsStream,
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return Text(
                'Найдено товаров: $count',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
          Text(
            'Сортировка: ${_getSortName(_selectedSort)}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
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

  Widget _buildSearchResults(List<Product> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
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
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Поиск товаров...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Ошибка загрузки',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
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
            _hasActiveSearch
                ? 'По вашему запросу ничего не найдено'
                : 'Товары не найдены',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (_hasActiveSearch)
            ElevatedButton(
              onPressed: _clearSearch,
              child: const Text('Показать все товары'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}