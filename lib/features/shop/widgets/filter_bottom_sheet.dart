// lib/features/shop/widgets/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../controllers/shop_controller.dart';

class FilterBottomSheet extends StatefulWidget {
  final ShopController controller;

  const FilterBottomSheet({super.key, required this.controller});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues _priceRange;
  late bool _inStockOnly;

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(
      widget.controller.filterMinPrice.value,
      widget.controller.filterMaxPrice.value,
    );
    _inStockOnly = widget.controller.inStockOnly.value;
  }

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
                  'Filter Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.controller.clearAllFilters();
                    Get.back();
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filter Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price Range
                const Text(
                  'Price Range',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                Obx(() => RangeSlider(
                  values: _priceRange,
                  min: widget.controller.minPrice.value,
                  max: widget.controller.maxPrice.value,
                  divisions: 50,
                  activeColor: TColors.primary,
                  labels: RangeLabels(
                    'GHS ${_priceRange.start.toStringAsFixed(0)}',
                    'GHS ${_priceRange.end.toStringAsFixed(0)}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                )),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GHS ${_priceRange.start.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'GHS ${_priceRange.end.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Stock Filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'In Stock Only',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Switch(
                      value: _inStockOnly,
                      activeColor: TColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _inStockOnly = value;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.controller.updatePriceFilter(
                        _priceRange.start,
                        _priceRange.end,
                      );
                      widget.controller.toggleInStockOnly(_inStockOnly);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}