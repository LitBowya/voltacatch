// lib/features/shop/widgets/sort_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../controllers/shop_controller.dart';

class SortBottomSheet extends StatelessWidget {
  final ShopController controller;

  const SortBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Sort Options
          Obx(() => Column(
            children: SortBy.values.map((sortBy) {
              final isSelected = controller.currentSort.value == sortBy;
              return ListTile(
                title: Text(
                  controller.getSortDisplayName(sortBy),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? TColors.primary : null,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: TColors.primary)
                    : null,
                onTap: () {
                  controller.updateSort(sortBy);
                  Get.back();
                },
              );
            }).toList(),
          )),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}