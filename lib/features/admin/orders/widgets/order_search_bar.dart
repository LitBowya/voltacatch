// lib/features/admin/orders/widgets/order_search_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../controllers/admin_order_controller.dart';

class OrderSearchBar extends StatelessWidget {
  const OrderSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminOrderController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: controller.searchOrders,
        decoration: InputDecoration(
          hintText: 'Search orders by ID or customer...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}