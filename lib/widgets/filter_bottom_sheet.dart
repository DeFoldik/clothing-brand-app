// widgets/filter_bottom_sheet.dart
import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> activeFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterBottomSheet({
    super.key,
    required this.activeFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, dynamic> _currentFilters;

  final List<String> _availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  final List<Map<String, dynamic>> _availableColors = [
    {'name': 'Черный', 'color': Colors.black},
    {'name': 'Белый', 'color': Colors.white},
    {'name': 'Серый', 'color': Colors.grey},
    {'name': 'Синий', 'color': Colors.blue},
    {'name': 'Красный', 'color': Colors.red},
    {'name': 'Зеленый', 'color': Colors.green},
    {'name': 'Желтый', 'color': Colors.yellow},
    {'name': 'Розовый', 'color': Colors.pink},
  ];

  @override
  void initState() {
    super.initState();
    _currentFilters = Map<String, dynamic>.from(widget.activeFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Фильтры',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentFilters = {
                      'category': 'all',
                      'sizes': [],
                      'colors': [],
                      'priceRange': {'min': 0, 'max': 1000},
                      'sortBy': 'popular',
                    };
                  });
                },
                child: const Text('Сбросить все'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView(
              children: [
                _buildPriceFilter(),
                const SizedBox(height: 24),
                _buildSizeFilter(),
                const SizedBox(height: 24),
                _buildColorFilter(),
                const SizedBox(height: 24),
              ],
            ),
          ),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onFiltersChanged(_currentFilters);
                    Navigator.pop(context);
                  },
                  child: const Text('Применить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceFilter() {
    final range = _currentFilters['priceRange'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Цена, \$',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: RangeValues(
            range['min'].toDouble(),
            range['max'].toDouble(),
          ),
          min: 0,
          max: 1000,
          divisions: 20,
          labels: RangeLabels(
            '\$${range['min']}',
            '\$${range['max']}',
          ),
          onChanged: (values) {
            setState(() {
              _currentFilters['priceRange'] = {
                'min': values.start.round(),
                'max': values.end.round(),
              };
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSizes.map((size) {
            final isSelected = _currentFilters['sizes'].contains(size);
            return FilterChip(
              label: Text(size),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _currentFilters['sizes'].add(size);
                  } else {
                    _currentFilters['sizes'].remove(size);
                  }
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableColors.map((colorData) {
            final isSelected = _currentFilters['colors'].contains(colorData['name']);
            return FilterChip(
              label: Text(
                colorData['name'],
                style: TextStyle(
                  color: colorData['color'] == Colors.white ? Colors.black : null,
                ),
              ),
              backgroundColor: colorData['color'],
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _currentFilters['colors'].add(colorData['name']);
                  } else {
                    _currentFilters['colors'].remove(colorData['name']);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}