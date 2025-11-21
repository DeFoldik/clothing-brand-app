// widgets/category_chip.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/categories.dart';

class CategoryChip extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isAllCategory;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.isAllCategory,
  });

  @override
  Widget build(BuildContext context) {
    final categoryEnum = ProductCategory.values.firstWhere(
          (cat) => cat.toFirestore() == category['category'],
      orElse: () => ProductCategory.all,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SVG иконка с transform для принудительного увеличения
            Transform.scale(
              scale: 1.4, // Увеличивает в 1.4 раза
              child: SvgPicture.asset(
                categoryEnum.iconPath,
                width: 24, // Базовый размер
                height: 24,
                colorFilter: ColorFilter.mode(
                  isSelected ? Colors.white : Colors.grey[700]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              category['name'] as String,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}