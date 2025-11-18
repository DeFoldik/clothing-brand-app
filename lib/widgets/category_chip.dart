// widgets/category_chip.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryChip extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isAllCategory; // Добавляем параметр для определения "Все" категории

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.isAllCategory = false, // По умолчанию false
  });

  @override
  Widget build(BuildContext context) {
    final hasCustomIcon = category['iconPath'] != null;
    final hasMaterialIcon = category['icon'] != null;

    // Размеры для "Все" категории
    final iconSize = isAllCategory ? 25.0 : 35.0; // Меньше для "Все"
    final textSize = isAllCategory ? 20.0 : 20.0; // Меньше для "Все"
    final horizontalPadding = isAllCategory ? 16.0 : 20.0; // Меньше для "Все"

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ИКОНКА
            if (hasCustomIcon)
              SvgPicture.asset(
                category['iconPath'],
                width: iconSize, // Разный размер
                height: iconSize, // Разный размер
                color: isSelected ? Colors.white : Colors.grey[600],
              )
            else if (hasMaterialIcon)
              Icon(
                category['icon'] as IconData,
                size: iconSize, // Разный размер
                color: isSelected ? Colors.white : Colors.grey[600],
              )
            else
              Container(),

            const SizedBox(width: 8),

            // ТЕКСТ
            Text(
              category['name'] as String,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: textSize, // Разный размер
              ),
            ),
          ],
        ),
      ),
    );
  }
}