// screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/product_detail.dart';
import '../services/product_detail_service.dart';
import '../services/favorite_service.dart';
import '../services/cart_service.dart';
import '../services/firestore_service.dart';
import '../widgets/image_viewer.dart';
import '../widgets/product_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<ProductDetail> _productDetailFuture;
  ProductDetail? _productDetail;
  int _selectedImageIndex = 0;
  String? _selectedSize;
  ProductColor? _selectedColor;
  final PageController _imagePageController = PageController();
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;
  List<Product> _similarProducts = [];
  bool _isLoadingSimilar = true;

  @override
  void initState() {
    super.initState();
    _productDetailFuture = _loadProductDetail();
    _loadSimilarProducts();

    _scrollController.addListener(() {
      setState(() {
        _showAppBarTitle = _scrollController.offset > 100;
      });
    });
  }

  Future<ProductDetail> _loadProductDetail() async {
    try {
      // Сначала пробуем загрузить из Firestore
      final firestoreProduct = await FirestoreService.getProductById(widget.product.id.toString());

      if (firestoreProduct != null) {
        // Используем данные из Firestore
        return ProductDetail(
          id: firestoreProduct.id,
          title: firestoreProduct.title,
          price: firestoreProduct.price,
          description: firestoreProduct.description,
          category: firestoreProduct.category,
          images: [firestoreProduct.image],
          availableSizes: firestoreProduct.sizes.map((size) => ProductSize(
            size: size,
            inStock: firestoreProduct.isVariantAvailable(size, _getDefaultColor(firestoreProduct)),
          )).toList(),
          availableColors: firestoreProduct.colors.map((color) => ProductColor(
            name: color,
            color: _getColorFromName(color),
            imageUrl: firestoreProduct.image,
            inStock: firestoreProduct.isVariantAvailable(_getDefaultSize(firestoreProduct), color),
          )).toList(),
          specification: ProductSpecification(
            material: 'Хлопок 80%, Полиэстер 20%',
            care: 'Стирка при 30°C, не отбеливать',
            season: 'Круглогодичный',
          ),
          discountPrice: firestoreProduct.discountPrice,
          rating: 4.5,
          reviewCount: 128,
          isNew: firestoreProduct.isNew,
          sizeChartImage: 'https://via.placeholder.com/400x600/FFFFFF/000000?text=Size+Chart',
        );
      } else {
        // Fallback на старый сервис
        return ProductDetailService.getProductDetail(widget.product);
      }
    } catch (e) {
      print('❌ Ошибка загрузки деталей товара: $e');
      // Fallback на старый сервис при ошибке
      return ProductDetailService.getProductDetail(widget.product);
    }
  }

  String _getDefaultSize(Product product) {
    return product.sizes.isNotEmpty ? product.sizes.first : 'M';
  }

  String _getDefaultColor(Product product) {
    return product.colors.isNotEmpty ? product.colors.first : 'Черный';
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'черный':
        return Colors.black;
      case 'белый':
        return Colors.white;
      case 'серый':
        return Colors.grey;
      case 'синий':
        return Colors.blue;
      case 'красный':
        return Colors.red;
      case 'зеленый':
        return Colors.green;
      case 'желтый':
        return Colors.yellow;
      case 'розовый':
        return Colors.pink;
      default:
        return Colors.black;
    }
  }

  List<String> get _productImages {
    if (_productDetail != null) {
      return _productDetail!.images.take(10).toList(); // Максимум 10 фото
    }
    // Fallback: используем изображения из product
    if (widget.product.images.isNotEmpty) {
      return widget.product.images.take(10).toList();
    }
    return [widget.product.image];
  }

  Future<void> _loadSimilarProducts() async {
    try {
      setState(() {
        _isLoadingSimilar = true;
      });

      // Загружаем товары из той же категории
      final allProducts = await FirestoreService.getProductsStream().first;
      final similar = allProducts
          .where((p) => p.category == widget.product.category && p.id != widget.product.id)
          .take(4)
          .toList();

      setState(() {
        _similarProducts = similar;
        _isLoadingSimilar = false;
      });
    } catch (e) {
      print('❌ Ошибка загрузки похожих товаров: $e');
      setState(() {
        _isLoadingSimilar = false;
        _similarProducts = [];
      });
    }
  }

  void _onImageSelected(int index) {
    setState(() {
      _selectedImageIndex = index;
    });
    _imagePageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onSizeSelected(String size) {
    setState(() {
      _selectedSize = size;
    });
  }

  void _onColorSelected(ProductColor color) {
    if (color.inStock) {
      setState(() {
        _selectedColor = color;
      });
    }
  }

  void _addToCart() async {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите размер')),
      );
      return;
    }

    final color = _selectedColor ?? _productDetail!.availableColors.firstWhere(
          (color) => color.inStock,
      orElse: () => _productDetail!.availableColors.first,
    );

    // Проверяем доступность в Firestore
    final firestoreProduct = await FirestoreService.getProductById(widget.product.id.toString());
    if (firestoreProduct != null) {
      final isAvailable = firestoreProduct.isVariantAvailable(_selectedSize!, color.name);
      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выбранный вариант отсутствует на складе')),
        );
        return;
      }
    }

    final cartProduct = CartProduct(
      product: widget.product,
      size: _selectedSize!,
      color: color.name,
      quantity: 1,
    );

    await CartService.addToCart(cartProduct);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Товар добавлен в корзину'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleFavorite() async {
    if (_productDetail != null) {
      await FavoriteService.toggleFavorite(_productDetail!.id);

      if (mounted) {
        setState(() {
          // Обновляем локальное состояние
        });
        // Перезагружаем данные товара
        _productDetailFuture = _loadProductDetail();
        setState(() {});
      }
    }
  }

  void _openImageViewer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewer(
          images: _productDetail?.images ?? [widget.product.image],
          initialIndex: _selectedImageIndex,
        ),
      ),
    );
  }

  void _showSizeChart() {
    if (_productDetail?.sizeChartImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Размерная сетка не указана')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(_productDetail!.sizeChartImage!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<ProductDetail>(
        future: _productDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorScreen();
          }

          _productDetail = snapshot.data!;

          // Автоматически выбираем первый доступный размер и цвет
          if (_selectedSize == null && _productDetail!.availableSizes.isNotEmpty) {
            final availableSize = _productDetail!.availableSizes.firstWhere(
                  (size) => size.inStock,
              orElse: () => _productDetail!.availableSizes.first,
            );
            _selectedSize = availableSize.size;
          }

          if (_selectedColor == null && _productDetail!.availableColors.isNotEmpty) {
            final availableColor = _productDetail!.availableColors.firstWhere(
                  (color) => color.inStock,
              orElse: () => _productDetail!.availableColors.first,
            );
            _selectedColor = availableColor;
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                title: _showAppBarTitle ? Text(_productDetail!.title) : null,
                backgroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                floating: true,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              SliverList(
                delegate: SliverChildListDelegate([
                  _buildImageGallery(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPriceSection(),
                        const SizedBox(height: 8),
                        Text(
                          _productDetail!.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_productDetail!.availableColors.isNotEmpty)
                          _buildColorSelector(),
                        const SizedBox(height: 16),
                        _buildSizeSelector(),
                        const SizedBox(height: 16),
                        _buildDescription(),
                        const SizedBox(height: 16),
                        _buildSpecifications(),
                        const SizedBox(height: 24),
                        _buildSimilarProducts(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _productDetail != null ? _buildBottomPanel() : null,
    );
  }

  Widget _buildImageGallery() {
    final images = _productDetail?.images ?? [widget.product.image];

    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          PageView.builder(
            controller: _imagePageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _selectedImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: _openImageViewer,
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedImageIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
          if (_productDetail?.isNew == true)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (_productDetail!.hasDiscount)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '-${_productDetail!.discountPercent.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Row(
      children: [
        if (_productDetail!.hasDiscount) ...[
          Text(
            '\$${_productDetail!.discountPrice!.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${_productDetail!.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ] else ...[
          Text(
            '\$${_productDetail!.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Цвет',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _productDetail!.availableColors.map((color) {
            final isSelected = _selectedColor?.name == color.name;
            final isOutOfStock = !color.inStock;

            return GestureDetector(
              onTap: () => _onColorSelected(color),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.color,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.grey[300]!,
                        ),
                      ),
                    ),
                    if (isOutOfStock)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Размер',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _showSizeChart,
              child: const Text('Таблица размеров'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _productDetail!.availableSizes.map((size) {
            final isSelected = _selectedSize == size.size;
            final isOutOfStock = !size.inStock;

            return GestureDetector(
              onTap: isOutOfStock ? null : () => _onSizeSelected(size.size),
              child: Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.transparent,
                  border: Border.all(
                    color: isOutOfStock ? Colors.grey[300]! :
                    isSelected ? Colors.black : Colors.grey[400]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    size.size,
                    style: TextStyle(
                      color: isOutOfStock ? Colors.grey[400]! :
                      isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Описание',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _productDetail!.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecifications() {
    final spec = _productDetail!.specification;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Характеристики',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (spec.material != null)
          _buildSpecItem('Материал', spec.material!),
        if (spec.care != null)
          _buildSpecItem('Уход', spec.care!),
        if (spec.season != null)
          _buildSpecItem('Сезон', spec.season!),
        if (spec.additionalInfo != null) ...[
          for (final entry in spec.additionalInfo!.entries)
            _buildSpecItem(entry.key, entry.value),
        ],
      ],
    );
  }

  Widget _buildSpecItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarProducts() {
    if (_isLoadingSimilar) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_similarProducts.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Похожие товары',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _similarProducts.length,
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                margin: EdgeInsets.only(
                  right: index == _similarProducts.length - 1 ? 0 : 16,
                ),
                child: ProductCard(
                  product: _similarProducts[index],
                  onFavoriteChanged: () {},
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: FutureBuilder<bool>(
                  future: FavoriteService.isFavorite(_productDetail!.id),
                  builder: (context, snapshot) {
                    final isFavorite = snapshot.data ?? false;
                    return Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey[600],
                    );
                  },
                ),
                onPressed: _toggleFavorite,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'В корзину',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Ошибка загрузки товара',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}