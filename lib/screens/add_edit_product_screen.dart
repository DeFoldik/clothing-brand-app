import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/categories.dart';
import '../models/product_variant.dart';
import '../services/admin_service.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _imageController = TextEditingController();
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;


  final _materialController = TextEditingController();
  final _careController = TextEditingController();
  final _seasonController = TextEditingController();
  final _specKeyController = TextEditingController();
  final _specValueController = TextEditingController();

  bool _enableMaterial = false;
  bool _enableCare = false;
  bool _enableSeason = false;

  Map<String, String> _additionalSpecs = {};

  // Контроллеры для вариантов
  final _sizeController = TextEditingController();
  final _colorController = TextEditingController();
  final _stockController = TextEditingController();

  ProductCategory? _selectedCategory;
  bool _isNew = false;
  bool _isPopular = false;

  // Списки размеров и цветов
  List<String> _sizes = [];
  List<String> _colors = [];
  List<ProductVariant> _variants = [];
  List<String> _images = [];

  // Выбранные значения для формы добавления/редактирования варианта
  String? _selectedSize;
  String? _selectedColor;
  int _selectedStock = 0;

  // Для режима редактирования варианта
  ProductVariant? _editingVariant;
  bool _isEditingVariant = false;

  final List<ProductCategory> _availableCategories = ProductCategory.values
      .where((category) => !category.isAll)
      .toList();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _fillFormWithProduct(widget.product!);
    } else {
      _imageController.text = 'https://picsum.photos/400/400?random=1';
      _images.add(_imageController.text);
      _selectedCategory = _availableCategories.isNotEmpty
          ? _availableCategories.first
          : null;
    }
  }

  void _fillFormWithProduct(Product product) {
    _titleController.text = product.title;
    _priceController.text = product.price.toString();
    _descriptionController.text = product.description;
    _selectedCategory = product.category;
    _imageController.text = product.image;
    _images = List.from(product.images);
    _discountPriceController.text = product.discountPrice?.toString() ?? '';
    _isNew = product.isNew;
    _isPopular = product.isPopular;
    _sizes = List.from(product.sizes);
    _colors = List.from(product.colors);
    _variants = List.from(product.variants);

    // Заполняем новые поля и включаем переключатели если есть данные
    _materialController.text = product.material ?? '';
    _careController.text = product.careInstructions ?? '';
    _seasonController.text = product.season ?? '';
    _additionalSpecs = Map.from(product.additionalSpecs ?? {});

    // Включаем переключатели если есть данные
    _enableMaterial = product.material != null && product.material!.isNotEmpty;
    _enableCare = product.careInstructions != null && product.careInstructions!.isNotEmpty;
    _enableSeason = product.season != null && product.season!.isNotEmpty;

    if (_sizes.isNotEmpty) _selectedSize = _sizes.first;
    if (_colors.isNotEmpty) _selectedColor = _colors.first;
  }

  Widget _buildSpecificationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Характеристики товара',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Включите нужные характеристики и заполните их',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // МАТЕРИАЛ С ПЕРЕКЛЮЧАТЕЛЕМ
            _buildToggleField(
              title: 'Материал',
              value: _enableMaterial,
              onChanged: (value) {
                setState(() {
                  _enableMaterial = value;
                  if (!value) _materialController.clear();
                });
              },
              controller: _materialController,
              hintText: 'Например: Хлопок 80%, Полиэстер 20%',
              enabled: _enableMaterial,
            ),
            const SizedBox(height: 16),

            // УХОД С ПЕРЕКЛЮЧАТЕЛЕМ
            _buildToggleField(
              title: 'Рекомендации по уходу',
              value: _enableCare,
              onChanged: (value) {
                setState(() {
                  _enableCare = value;
                  if (!value) _careController.clear();
                });
              },
              controller: _careController,
              hintText: 'Например: Стирка при 30°C, не отбеливать',
              enabled: _enableCare,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // СЕЗОН С ПЕРЕКЛЮЧАТЕЛЕМ
            _buildToggleField(
              title: 'Сезон',
              value: _enableSeason,
              onChanged: (value) {
                setState(() {
                  _enableSeason = value;
                  if (!value) _seasonController.clear();
                });
              },
              controller: _seasonController,
              hintText: 'Например: Круглогодичный, Лето, Зима',
              enabled: _enableSeason,
            ),
            const SizedBox(height: 24),

            // ДОПОЛНИТЕЛЬНЫЕ ХАРАКТЕРИСТИКИ (всегда доступны)
            _buildAdditionalSpecsSection(),
          ],
        ),
      ),
    );
  }

  //  ВИДЖЕТ ДЛЯ ПОЛЯ С ПЕРЕКЛЮЧАТЕЛЕМ
  Widget _buildToggleField({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required TextEditingController controller,
    required String hintText,
    required bool enabled,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок и переключатель
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.blue,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Поле ввода
        TextFormField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            filled: !enabled,
            fillColor: !enabled ? Colors.grey[100] : null,
            hintStyle: TextStyle(
              color: !enabled ? Colors.grey[400] : null,
            ),
          ),
          maxLines: maxLines,
          validator: (text) {
            // Валидация только если поле включено и обязательно для заполнения
            if (value && (text == null || text.trim().isEmpty)) {
              return 'Заполните это поле';
            }
            return null;
          },
        ),

        // Подсказка о статусе
        if (!enabled) ...[
          const SizedBox(height: 4),
          Text(
            'Поле отключено',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  //  СЕКЦИЯ ДОПОЛНИТЕЛЬНЫХ ХАРАКТЕРИСТИК
  Widget _buildAdditionalSpecsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Дополнительные характеристики',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Добавьте любые дополнительные характеристики товара',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),

        // Форма добавления
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _specKeyController,
                decoration: const InputDecoration(
                  labelText: 'Название характеристики',
                  hintText: 'Например: Посадка, Длина, Узор',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _specValueController,
                decoration: const InputDecoration(
                  labelText: 'Значение',
                  hintText: 'Например: Regular Fit, Стандартная',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addAdditionalSpec,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text('Добавить'),
            ),
          ],
        ),

        // Список добавленных характеристик
        if (_additionalSpecs.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Добавленные характеристики:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._additionalSpecs.entries.map((entry) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(entry.value),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeAdditionalSpec(entry.key),
              ),
            ),
          )).toList(),

          // Кнопка очистки всех дополнительных характеристик
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _clearAllAdditionalSpecs,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Очистить все'),
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Дополнительные характеристики не добавлены',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Метод для добавления дополнительной характеристики
  void _addAdditionalSpec() {
    final key = _specKeyController.text.trim();
    final value = _specValueController.text.trim();

    if (key.isNotEmpty && value.isNotEmpty) {
      if (_additionalSpecs.containsKey(key)) {
        _showSnackBar('Характеристика "$key" уже существует', isError: true);
        return;
      }

      setState(() {
        _additionalSpecs[key] = value;
        _specKeyController.clear();
        _specValueController.clear();
      });
      _showSnackBar('Характеристика "$key" добавлена');
    } else {
      _showSnackBar('Заполните оба поля', isError: true);
    }
  }

  // Метод для удаления дополнительной характеристики
  void _removeAdditionalSpec(String key) {
    setState(() {
      _additionalSpecs.remove(key);
    });
    _showSnackBar('Характеристика "$key" удалена');
  }

  // Метод для очистки всех дополнительных характеристик
  void _clearAllAdditionalSpecs() {
    if (_additionalSpecs.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить все характеристики?'),
        content: Text('Будет удалено ${_additionalSpecs.length} характеристик'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _additionalSpecs.clear();
              });
              Navigator.pop(context);
              _showSnackBar('Все характеристики очищены');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _showSnackBar('Выберите категорию', isError: true);
      return;
    }

    //  Проверка включенных полей
    if (_enableMaterial && _materialController.text.trim().isEmpty) {
      _showSnackBar('Заполните поле "Материал"', isError: true);
      return;
    }
    if (_enableCare && _careController.text.trim().isEmpty) {
      _showSnackBar('Заполните поле "Рекомендации по уходу"', isError: true);
      return;
    }
    if (_enableSeason && _seasonController.text.trim().isEmpty) {
      _showSnackBar('Заполните поле "Сезон"', isError: true);
      return;
    }

    try {
      final productId = widget.product?.id ?? DateTime.now().millisecondsSinceEpoch;

      final product = Product(
        id: productId,
        title: _titleController.text.trim(),
        price: double.parse(_priceController.text),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        image: _imageController.text.trim(),
        images: _images,
        discountPrice: _discountPriceController.text.isNotEmpty
            ? double.parse(_discountPriceController.text)
            : null,
        isNew: _isNew,
        isPopular: _isPopular,
        sizes: _sizes,
        colors: _colors,
        variants: _variants,
        //  Добавляем новые поля только если включены
        material: _enableMaterial ? _materialController.text.trim() : null,
        careInstructions: _enableCare ? _careController.text.trim() : null,
        season: _enableSeason ? _seasonController.text.trim() : null,
        additionalSpecs: _additionalSpecs.isNotEmpty ? _additionalSpecs : null,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.product != null) {
        await AdminService.updateProduct(product);
        _showSnackBar('✅ Товар успешно обновлен');
      } else {
        await AdminService.addProduct(product);
        _showSnackBar('✅ Товар успешно добавлен');
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('❌ Ошибка: $e', isError: true);
    }
  }

  //  ДОБАВЛЕНИЕ РАЗМЕРА
  void _addSize() {
    final size = _sizeController.text.trim();
    if (size.isNotEmpty && !_sizes.contains(size)) {
      setState(() {
        _sizes.add(size);
        _sizeController.clear();
        // Автоматически выбираем новый размер
        _selectedSize = size;
      });
      _showSnackBar('Размер "$size" добавлен');
    } else if (_sizes.contains(size)) {
      _showSnackBar('Размер "$size" уже существует', isError: true);
    }
  }

  void _removeSize(String size) {
    setState(() {
      _sizes.remove(size);
      // Удаляем варианты с этим размером
      _variants.removeWhere((variant) => variant.size == size);
      // Обновляем выбранный размер если нужно
      if (_selectedSize == size) {
        _selectedSize = _sizes.isNotEmpty ? _sizes.first : null;
      }
    });
    _showSnackBar('Размер "$size" удален');
  }

  //  ДОБАВЛЕНИЕ ЦВЕТА
  void _addColor() {
    final color = _colorController.text.trim();
    if (color.isNotEmpty && !_colors.contains(color)) {
      setState(() {
        _colors.add(color);
        _colorController.clear();
        // Автоматически выбираем новый цвет
        _selectedColor = color;
      });
      _showSnackBar('Цвет "$color" добавлен');
    } else if (_colors.contains(color)) {
      _showSnackBar('Цвет "$color" уже существует', isError: true);
    }
  }

  void _removeColor(String color) {
    setState(() {
      _colors.remove(color);
      // Удаляем варианты с этим цветом
      _variants.removeWhere((variant) => variant.color == color);
      // Обновляем выбранный цвет если нужно
      if (_selectedColor == color) {
        _selectedColor = _colors.isNotEmpty ? _colors.first : null;
      }
    });
    _showSnackBar('Цвет "$color" удален');
  }

  //  ДОБАВЛЕНИЕ ВАРИАНТА
  void _addVariant() {
    if (_selectedSize == null || _selectedColor == null) {
      _showSnackBar('Выберите размер и цвет', isError: true);
      return;
    }

    if (_selectedStock <= 0) {
      _showSnackBar('Введите корректное количество', isError: true);
      return;
    }

    // Проверяем, не существует ли уже такой вариант
    final existingVariant = _variants.firstWhere(
          (v) => v.size == _selectedSize && v.color == _selectedColor,
      orElse: () => ProductVariant(size: '', color: '', stock: 0),
    );

    if (existingVariant.size.isNotEmpty && !_isEditingVariant) {
      _showSnackBar('Такой вариант уже существует', isError: true);
      return;
    }

    setState(() {
      if (_isEditingVariant && _editingVariant != null) {
        // Обновляем существующий вариант
        final index = _variants.indexOf(_editingVariant!);
        _variants[index] = ProductVariant(
          size: _selectedSize!,
          color: _selectedColor!,
          stock: _selectedStock,
        );
        _showSnackBar('Вариант обновлен: $_selectedSize, $_selectedColor');
      } else {
        // Добавляем новый вариант
        _variants.add(ProductVariant(
          size: _selectedSize!,
          color: _selectedColor!,
          stock: _selectedStock,
        ));
        _showSnackBar('Вариант добавлен: $_selectedSize, $_selectedColor');
      }

      _resetVariantForm();
    });
  }

  //  РЕДАКТИРОВАНИЕ ВАРИАНТА
  void _editVariant(ProductVariant variant) {
    setState(() {
      _editingVariant = variant;
      _isEditingVariant = true;
      _selectedSize = variant.size;
      _selectedColor = variant.color;
      _selectedStock = variant.stock;
      _stockController.text = variant.stock.toString();
    });
    _showSnackBar('Редактирование варианта: ${variant.size}, ${variant.color}');
  }

  //  УДАЛЕНИЕ ВАРИАНТА
  void _removeVariant(ProductVariant variant) {
    setState(() {
      _variants.remove(variant);
    });
    _showSnackBar('Вариант удален');
  }

  //  СБРОС ФОРМЫ ВАРИАНТА
  void _resetVariantForm() {
    setState(() {
      _editingVariant = null;
      _isEditingVariant = false;
      _selectedSize = _sizes.isNotEmpty ? _sizes.first : null;
      _selectedColor = _colors.isNotEmpty ? _colors.first : null;
      _selectedStock = 0;
      _stockController.clear();
    });
  }

  //  ОТМЕНА РЕДАКТИРОВАНИЯ ВАРИАНТА
  void _cancelEditVariant() {
    _resetVariantForm();
    _showSnackBar('Редактирование отменено');
  }

  void _addImageFromUrl() {
    final imageUrl = _imageController.text.trim();
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        setState(() {
          _images.add(imageUrl);
          _imageController.clear();
        });
        _showSnackBar('Изображение добавлено');
      } else {
        _showSnackBar('Введите корректный URL изображения', isError: true);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Редактировать товар' : 'Добавить товар'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _saveProduct,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Основная информация
              _buildSectionTitle('Основная информация'),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Название товара *',
                  border: OutlineInputBorder(),
                  hintText: 'Например: Футболка хлопковая',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название товара';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<ProductCategory>(
                value: _selectedCategory,
                onChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                items: _availableCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          child: SvgPicture.asset(
                            category.iconPath,
                            colorFilter: ColorFilter.mode(
                              Colors.grey[700]!,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(category.displayName),
                      ],
                    ),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Категория *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Выберите категорию';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Цены
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Цена *',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введите цену';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Введите корректную цену';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _discountPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Со скидкой',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание *',
                  border: OutlineInputBorder(),
                  hintText: 'Подробное описание товара...',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите описание';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              //  ИЗОБРАЖЕНИЯ
              _buildSectionTitle('Изображения товара'),
              _buildImageSection(),
              const SizedBox(height: 24),

              //  РАЗМЕРЫ
              _buildSectionTitle('Размеры'),
              _buildSizesSection(),
              const SizedBox(height: 16),

              //  ЦВЕТА
              _buildSectionTitle('Цвета'),
              _buildColorsSection(),
              const SizedBox(height: 24),

              //  ВАРИАНТЫ ТОВАРА
              _buildSectionTitle('Варианты товара'),
              _buildVariantsSection(),
              const SizedBox(height: 24),

              //  ФОРМА ДОБАВЛЕНИЯ/РЕДАКТИРОВАНИЯ ВАРИАНТА
              _buildSectionTitle(_isEditingVariant ? 'Редактировать вариант' : 'Добавить вариант'),
              _buildVariantForm(),
              const SizedBox(height: 24),

              //  ДОБАВЛЯЕМ СЕКЦИЮ ХАРАКТЕРИСТИК ЗДЕСЬ
              _buildSectionTitle('Характеристики товара'),
              _buildSpecificationsSection(),
              const SizedBox(height: 24),

              //  НАСТРОЙКИ
              _buildSectionTitle('Настройки'),
              _buildSettingsSection(),
              const SizedBox(height: 24),

              // Кнопка сохранения
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    widget.product != null ? 'Обновить товар' : 'Добавить товар',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  //  СЕКЦИЯ РАЗМЕРОВ
  Widget _buildSizesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _sizeController,
                decoration: const InputDecoration(
                  labelText: 'Новый размер',
                  border: OutlineInputBorder(),
                  hintText: 'Например: M, L, XL',
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addSize,
              child: const Text('Добавить'),
            ),
          ],
        ),
        if (_sizes.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Доступные размеры:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sizes.map((size) {
              return Chip(
                label: Text(size),
                onDeleted: () => _removeSize(size),
                deleteIconColor: Colors.red,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  //  СЕКЦИЯ ЦВЕТОВ
  Widget _buildColorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Новый цвет',
                  border: OutlineInputBorder(),
                  hintText: 'Например: Черный, Белый, Синий',
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addColor,
              child: const Text('Добавить'),
            ),
          ],
        ),
        if (_colors.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Доступные цвета:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colors.map((color) {
              return Chip(
                label: Text(color),
                onDeleted: () => _removeColor(color),
                deleteIconColor: Colors.red,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  //  ФОРМА ДОБАВЛЕНИЯ/РЕДАКТИРОВАНИЯ ВАРИАНТА
  Widget _buildVariantForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Выбор размера
            _sizes.isNotEmpty
                ? DropdownButtonFormField<String>(
              value: _selectedSize,
              onChanged: (size) {
                setState(() {
                  _selectedSize = size;
                });
              },
              items: _sizes.map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text(size),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Размер',
                border: OutlineInputBorder(),
              ),
            )
                : const Text(
              'Добавьте размеры выше',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 12),

            // Выбор цвета
            _colors.isNotEmpty
                ? DropdownButtonFormField<String>(
              value: _selectedColor,
              onChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              items: _colors.map((color) {
                return DropdownMenuItem(
                  value: color,
                  child: Text(color),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Цвет',
                border: OutlineInputBorder(),
              ),
            )
                : const Text(
              'Добавьте цвета выше',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 12),

            // Количество
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'Количество на складе',
                border: OutlineInputBorder(),
                hintText: 'Введите количество',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _selectedStock = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 16),

            // Кнопки
            Row(
              children: [
                if (_isEditingVariant) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancelEditVariant,
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _addVariant,
                    child: Text(_isEditingVariant ? 'Обновить вариант' : 'Добавить вариант'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //  СЕКЦИЯ ВАРИАНТОВ
  Widget _buildVariantsSection() {
    if (_variants.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Варианты не добавлены',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Добавленные варианты:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ..._variants.map((variant) {
              return _buildVariantCard(variant);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantCard(ProductVariant variant) {
    final isEditing = _isEditingVariant && _editingVariant == variant;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isEditing ? Colors.blue[50] : Colors.grey[50],
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isEditing ? Colors.blue[100] : Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isEditing ? Icons.edit : Icons.inventory_2,
            color: isEditing ? Colors.blue : Colors.blue,
          ),
        ),
        title: Text('Размер: ${variant.size}, Цвет: ${variant.color}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Остаток: ${variant.stock} шт.'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _editVariant(variant),
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: 'Редактировать вариант',
            ),
            IconButton(
              onPressed: () => _removeVariant(variant),
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Удалить вариант',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Изображения товара:',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),

        // Кнопки загрузки
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Добавить изображения:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                     OutlinedButton.icon(
                        onPressed: _isUploadingImage ? null : _pickImageFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Из галереи'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    const SizedBox(width: 12),

                const SizedBox(height: 8),

                // Или по URL
                OutlinedButton.icon(
                  onPressed: _isUploadingImage ? null : _showUrlInputDialog,
                  icon: const Icon(Icons.link),
                  label: const Text('Добавить по URL'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Прогресс загрузки
        if (_isUploadingImage) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Загрузка изображения...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Text('${(_uploadProgress * 100).toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ),
        ],

        // Добавленные изображения
        if (_images.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Добавленные изображения:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return _buildImageItem(_images[index]);
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final File? imageFile = await AdminService.pickImageFromGallery();
      if (imageFile != null) {
        await _uploadImageToStorage(imageFile);
      }
    } catch (e) {
      _showSnackBar('❌ Ошибка выбора изображения: $e', isError: true);
    }
  }


  Future<void> _uploadImageToStorage(File imageFile) async {
    setState(() {
      _isUploadingImage = true;
      _uploadProgress = 0.0;
    });

    try {
      print('🔄 Начинаем процесс загрузки...');

      final String? imageUrl = await AdminService.uploadProductImage(imageFile);

      if (imageUrl != null && mounted) {
        print('✅ Изображение успешно загружено: $imageUrl');

        setState(() {
          _images.add(imageUrl);
          _uploadProgress = 1.0;
        });

        await Future.delayed(const Duration(milliseconds: 500));

        setState(() {
          _isUploadingImage = false;
          _uploadProgress = 0.0;
        });

        _showSnackBar('✅ Изображение успешно загружено');
      } else {
        print('❌ Не удалось получить URL изображения');
        setState(() {
          _isUploadingImage = false;
          _uploadProgress = 0.0;
        });
        _showSnackBar('❌ Ошибка загрузки изображения', isError: true);
      }
    } catch (e, stackTrace) {
      print('❌ Ошибка в процессе загрузки: $e');
      print('📋 Stack trace: $stackTrace');

      setState(() {
        _isUploadingImage = false;
        _uploadProgress = 0.0;
      });
      _showSnackBar('❌ Ошибка загрузки: $e', isError: true);
    }
  }


//  ДИАЛОГ ДЛЯ ВВОДА URL
  void _showUrlInputDialog() {
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить изображение по URL'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
            labelText: 'URL изображения',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty && url.startsWith('http')) {
                setState(() {
                  _images.add(url);
                });
                Navigator.pop(context);
                _showSnackBar('✅ Изображение по URL добавлено');
              } else {
                _showSnackBar('❌ Введите корректный URL', isError: true);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }


//  УДАЛЕНИЕ ИЗОБРАЖЕНИЯ
  void _removeImage(String imageUrl) async {
    // Показываем диалог подтверждения
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить изображение?'),
        content: const Text('Это действие нельзя отменить.'),
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
      setState(() {
        _images.remove(imageUrl);
      });

      // Если это изображение из Firebase Storage, удаляем его и оттуда
      if (imageUrl.contains('firebasestorage.googleapis.com')) {
        try {
          await AdminService.deleteImage(imageUrl);
          _showSnackBar('✅ Изображение удалено');
        } catch (e) {
          _showSnackBar('⚠️ Изображение удалено из списка, но возникла ошибка при удалении из хранилища', isError: true);
        }
      } else {
        _showSnackBar('✅ Изображение удалено');
      }
    }
  }

  Widget _buildImageItem(String imageUrl) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(imageUrl),
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //  СЕКЦИЯ НАСТРОЕК
  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text(
                'Новый товар',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Показывать с меткой "NEW"'),
              value: _isNew,
              onChanged: (value) {
                setState(() {
                  _isNew = value;
                });
              },
              secondary: const Icon(Icons.new_releases, color: Colors.orange),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text(
                'Популярный товар',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Показывать в разделе популярных'),
              value: _isPopular,
              onChanged: (value) {
                setState(() {
                  _isPopular = value;
                });
              },
              secondary: const Icon(Icons.trending_up, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _discountPriceController.dispose();
    _imageController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    _stockController.dispose();
    _materialController.dispose();
    _careController.dispose();
    _seasonController.dispose();
    _specKeyController.dispose();
    _specValueController.dispose();
    super.dispose();
  }
}