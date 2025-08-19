
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../orders/models/order_model.dart';
import '../controllers/admin_order_controller.dart';

class OrderFilterBar extends StatelessWidget {
  const OrderFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminOrderController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Status Filter
          Expanded(
            child: Obx(() => _buildStatusDropdown(controller)),
          ),
          const SizedBox(width: 12),

          // Sort Dropdown
          Expanded(
            child: Obx(() => _buildSortDropdown(controller)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(AdminOrderController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<OrderStatus?>(
          value: controller.selectedStatus,
          hint: const Text('Filter by status'),
          isExpanded: true,
          onChanged: controller.filterByStatus,
          items: [
            const DropdownMenuItem<OrderStatus?>(
              value: null,
              child: Text('All Orders'),
            ),
            ...OrderStatus.values.map((status) {
              return DropdownMenuItem<OrderStatus?>(
                value: status,
                child: Row(
                  children: [
                    _getStatusIcon(status),
                    const SizedBox(width: 8),
                    Text(_getStatusText(status)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown(AdminOrderController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.sortBy,
          isExpanded: true,
          onChanged: (value) => controller.sortOrders(value!),
          items: const [
            DropdownMenuItem(
              value: 'createdAt_desc',
              child: Text('Newest first'),
            ),
            DropdownMenuItem(
              value: 'createdAt_asc',
              child: Text('Oldest first'),
            ),
            DropdownMenuItem(
              value: 'totalPrice_desc',
              child: Text('Highest amount'),
            ),
            DropdownMenuItem(
              value: 'totalPrice_asc',
              child: Text('Lowest amount'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icon(Icons.access_time, color: Colors.orange[600], size: 16);
      case OrderStatus.confirmed:
        return Icon(Icons.check_circle, color: Colors.blue[600], size: 16);
      case OrderStatus.shipped:
        return Icon(Icons.local_shipping, color: Colors.purple[600], size: 16);
      case OrderStatus.delivered:
        return Icon(Icons.done_all, color: Colors.green[600], size: 16);
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }
}