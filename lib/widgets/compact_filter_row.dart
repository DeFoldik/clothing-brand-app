// widgets/compact_filter_row.dart
import 'package:flutter/material.dart';

class CompactFilterRow extends StatefulWidget {
  final Map<String, dynamic> activeFilters;
  final List<String> availableSizes;
  final List<String> availableColors;
  final Function(Map<String, dynamic>) onFiltersChanged;
  final String selectedSort;
  final Function(String) onSortChanged;

  const CompactFilterRow({
    super.key,
    required this.activeFilters,
    required this.availableSizes,
    required this.availableColors,
    required this.onFiltersChanged,
    required this.selectedSort,
    required this.onSortChanged,
  });

  @override
  State<CompactFilterRow> createState() => _CompactFilterRowState();
}

class _CompactFilterRowState extends State<CompactFilterRow> {
  final Map<String, Color> _colorMap = {
    'Черный': Colors.black,
    'Белый': Colors.white,
    'Серый': Colors.grey,
    'Синий': Colors.blue,
    'Красный': Colors.red,
    'Зеленый': Colors.green,
    'Желтый': Colors.yellow,
    'Розовый': Colors.pink,
    'Оранжевый': Colors.orange,
    'Фиолетовый': Colors.purple,
    'Коричневый': Colors.brown,
  };

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildFilterModal(),
    );
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildSortModal(),
    );
  }

  Widget _buildFilterModal() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Фильтры',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildPriceFilter(),
                const SizedBox(height: 20),
                _buildSizeFilter(),
                const SizedBox(height: 20),
                _buildColorFilter(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onFiltersChanged({
                      'sizes': <String>[],
                      'colors': <String>[],
                      'priceRange': {'min': 0, 'max': 500},
                    });
                  },
                  child: const Text('Сбросить'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Применить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortModal() {
    const sortOptions = [
      {'value': 'popular', 'label': 'По популярности'},
      {'value': 'price_high', 'label': 'По цене (сначала дорогие)'},
      {'value': 'price_low', 'label': 'По цене (сначала дешевые)'},
      {'value': 'newest', 'label': 'По новизне'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Сортировка',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...sortOptions.map((option) {
            return ListTile(
              leading: Radio<String>(
                value: option['value']!,
                groupValue: widget.selectedSort,
                onChanged: (value) {
                  widget.onSortChanged(value!);
                  Navigator.pop(context);
                },
              ),
              title: Text(option['label']!),
              onTap: () {
                widget.onSortChanged(option['value']!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPriceFilter() {
    final range = widget.activeFilters['priceRange'] ?? {'min': 0, 'max': 500};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Цена, \$',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Ручной ввод цен
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'От',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final min = int.tryParse(value) ?? 0;
                  widget.onFiltersChanged({
                    ...widget.activeFilters,
                    'priceRange': {
                      'min': min,
                      'max': range['max'],
                    },
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'До',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final max = int.tryParse(value) ?? 500;
                  widget.onFiltersChanged({
                    ...widget.activeFilters,
                    'priceRange': {
                      'min': range['min'],
                      'max': max,
                    },
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Слайдер для визуального выбора
        RangeSlider(
          values: RangeValues(
            range['min'].toDouble(),
            range['max'].toDouble(),
          ),
          min: 0,
          max: 500,
          divisions: 50, // Шаг 10
          labels: RangeLabels(
            '\$${range['min']}',
            '\$${range['max']}',
          ),
          onChanged: (values) {
            widget.onFiltersChanged({
              ...widget.activeFilters,
              'priceRange': {
                'min': values.start.round(),
                'max': values.end.round(),
              },
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$${range['min']}'),
            Text('\$${range['max']}'),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Размер',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableSizes.map((size) {
            final isSelected = (widget.activeFilters['sizes'] as List<dynamic>?)?.contains(size) ?? false;
            return FilterChip(
              label: Text(size),
              selected: isSelected,
              onSelected: (selected) {
                final currentSizes = List<String>.from(widget.activeFilters['sizes'] ?? []);
                if (selected) {
                  currentSizes.add(size);
                } else {
                  currentSizes.remove(size);
                }
                widget.onFiltersChanged({
                  ...widget.activeFilters,
                  'sizes': currentSizes,
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Цвет',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableColors.map((color) {
            final isSelected = (widget.activeFilters['colors'] as List<dynamic>?)?.contains(color) ?? false;
            final colorValue = _colorMap[color] ?? Colors.grey;

            return FilterChip(
              label: Text(
                color,
                style: TextStyle(
                  color: colorValue == Colors.white ? Colors.black : null,
                ),
              ),
              backgroundColor: isSelected ? colorValue : null,
              selected: isSelected,
              onSelected: (selected) {
                final currentColors = List<String>.from(widget.activeFilters['colors'] ?? []);
                if (selected) {
                  currentColors.add(color);
                } else {
                  currentColors.remove(color);
                }
                widget.onFiltersChanged({
                  ...widget.activeFilters,
                  'colors': currentColors,
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        (widget.activeFilters['sizes'] as List?)?.isNotEmpty == true ||
            (widget.activeFilters['colors'] as List?)?.isNotEmpty == true ||
            (widget.activeFilters['priceRange']?['min'] ?? 0) > 0 ||
            (widget.activeFilters['priceRange']?['max'] ?? 500) < 500;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Кнопка фильтров
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.filter_list),
              label: Text(hasActiveFilters ? 'Фильтры •' : 'Фильтры'),
              onPressed: _showFilterModal,
            ),
          ),
          const SizedBox(width: 12),

          // Кнопка сортировки
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.sort),
              label: const Text('Сортировка'),
              onPressed: _showSortModal,
            ),
          ),
        ],
      ),
    );
  }
}