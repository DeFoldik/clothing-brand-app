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

  late Map<String, dynamic> _currentFilters;
  late String _currentSort;

  @override
  void initState() {
    super.initState();
    _currentFilters = Map<String, dynamic>.from(widget.activeFilters);
    _currentSort = widget.selectedSort;
  }

  @override
  void didUpdateWidget(CompactFilterRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeFilters != widget.activeFilters) {
      _currentFilters = Map<String, dynamic>.from(widget.activeFilters);
    }
    if (oldWidget.selectedSort != widget.selectedSort) {
      _currentSort = widget.selectedSort;
    }
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildFilterModal(),
    ).then((_) {
      // После закрытия модального окна обновляем состояние
      setState(() {});
    });
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildSortModal(),
    );
  }

  Widget _buildFilterModal() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
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
                    _buildPriceFilter(setModalState),
                    const SizedBox(height: 20),
                    _buildSizeFilter(setModalState),
                    const SizedBox(height: 20),
                    _buildColorFilter(setModalState),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _currentFilters = {
                            'sizes': <String>[],
                            'colors': <String>[],
                            'priceRange': {'min': 0, 'max': 500},
                          };
                        });
                        widget.onFiltersChanged(_currentFilters);
                      },
                      child: const Text('Сбросить'),
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
      },
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
                groupValue: _currentSort,
                onChanged: (value) {
                  setState(() {
                    _currentSort = value!;
                  });
                  widget.onSortChanged(value!);
                  Navigator.pop(context);
                },
              ),
              title: Text(option['label']!),
              onTap: () {
                setState(() {
                  _currentSort = option['value']!;
                });
                widget.onSortChanged(option['value']!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPriceFilter(StateSetter setModalState) {
    final range = _currentFilters['priceRange'] ?? {'min': 0, 'max': 500};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Цена, \$',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'От',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: range['min'].toString()),
                onChanged: (value) {
                  final min = int.tryParse(value) ?? 0;
                  setModalState(() {
                    _currentFilters['priceRange'] = {
                      'min': min,
                      'max': range['max'],
                    };
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
                controller: TextEditingController(text: range['max'].toString()),
                onChanged: (value) {
                  final max = int.tryParse(value) ?? 500;
                  setModalState(() {
                    _currentFilters['priceRange'] = {
                      'min': range['min'],
                      'max': max,
                    };
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: RangeValues(
            range['min'].toDouble(),
            range['max'].toDouble(),
          ),
          min: 0,
          max: 500,
          divisions: 50,
          labels: RangeLabels(
            '\$${range['min']}',
            '\$${range['max']}',
          ),
          onChanged: (values) {
            setModalState(() {
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

  Widget _buildSizeFilter(StateSetter setModalState) {
    final currentSizes = List<String>.from(_currentFilters['sizes'] ?? []);

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
            final isSelected = currentSizes.contains(size);
            return FilterChip(
              label: Text(size),
              selected: isSelected,
              onSelected: (selected) {
                setModalState(() {
                  if (selected) {
                    currentSizes.add(size);
                  } else {
                    currentSizes.remove(size);
                  }
                  _currentFilters['sizes'] = currentSizes;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorFilter(StateSetter setModalState) {
    final currentColors = List<String>.from(_currentFilters['colors'] ?? []);

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
            final isSelected = currentColors.contains(color);
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
                setModalState(() {
                  if (selected) {
                    currentColors.add(color);
                  } else {
                    currentColors.remove(color);
                  }
                  _currentFilters['colors'] = currentColors;
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
        (_currentFilters['sizes'] as List?)?.isNotEmpty == true ||
            (_currentFilters['colors'] as List?)?.isNotEmpty == true ||
            (_currentFilters['priceRange']?['min'] ?? 0) > 0 ||
            (_currentFilters['priceRange']?['max'] ?? 500) < 500;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Кнопка фильтров
          Expanded(
            child: OutlinedButton.icon(
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
                    )
                ],
              ),
              label: Text(hasActiveFilters ? 'Фильтры •' : 'Фильтры'),
              onPressed: _showFilterModal,
            ),
          ),
          const SizedBox(width: 12),

          // Кнопка сортировки
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.sort),
              label: Text(_getSortLabel(_currentSort)),
              onPressed: _showSortModal,
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(String sortValue) {
    switch (sortValue) {
      case 'price_high':
        return 'Цена ↓';
      case 'price_low':
        return 'Цена ↑';
      case 'newest':
        return 'Новинки';
      default:
        return 'Популярные';
    }
  }
}