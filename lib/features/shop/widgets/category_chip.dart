// lib/features/shop/widgets/category_chip.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class CategoryChip extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? imageUrl;

  const CategoryChip({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Category Image/Icon Container
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? TColors.primary : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? TColors.primary : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageUrl != null
                  ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.category,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 24,
                ),
              )
                  : Icon(
                icon ?? Icons.category,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Category Name
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? TColors.primary : Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}