// widgets/filter_bottom_sheet.dart - обновляем для работы с реальными данными
import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> activeFilters;
  final List<String> availableSizes;
  final List<String> availableColors;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterBottomSheet({
    super.key,
    required this.activeFilters,
    required this.availableSizes,
    required this.availableColors,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, dynamic> _currentFilters;
  late List<String> _availableSizes;
  late List<String> _availableColors;

  @override
  void initState() {
    super.initState();
    _currentFilters = Map<String, dynamic>.from(widget.activeFilters);
    _availableSizes = widget.availableSizes;
    _availableColors = widget.availableColors;
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
                      'sizes': [],
                      'colors': [],
                      'priceRange': {'min': 0, 'max': 1000},
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
        if (_availableSizes.isEmpty)
          const Text('Нет доступных размеров', style: TextStyle(color: Colors.grey))
        else
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
        if (_availableColors.isEmpty)
          const Text('Нет доступных цветов', style: TextStyle(color: Colors.grey))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableColors.map((color) {
              final isSelected = _currentFilters['colors'].contains(color);
              return FilterChip(
                label: Text(color),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _currentFilters['colors'].add(color);
                    } else {
                      _currentFilters['colors'].remove(color);
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