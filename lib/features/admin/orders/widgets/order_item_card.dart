// lib/features/admin/orders/widgets/order_item_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../orders/models/order_model.dart';
import '../controllers/admin_order_controller.dart';
import 'order_status_chip.dart';
import 'order_details_bottom_sheet.dart';

class OrderItemCard extends StatelessWidget {
  final OrderModel order;

  const OrderItemCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminOrderController>();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showOrderDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  OrderStatusChip(status: order.status),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.shopping_bag, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'GHS ${order.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: TColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'View Details',
                      Icons.visibility,
                      Colors.blue,
                          () => _showOrderDetails(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      'Update Status',
                      Icons.edit,
                      TColors.primary,
                          () => _showStatusUpdateDialog(context, controller),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String text,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context) {
    OrderDetailsBottomSheet.show(context, order);
  }

  void _showStatusUpdateDialog(BuildContext context, AdminOrderController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderStatus.values.map((status) {
            final isCurrentStatus = status == order.status;
            return ListTile(
              leading: _getStatusIcon(status),
              title: Text(
                _getStatusText(status),
                style: TextStyle(
                  fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
                  color: isCurrentStatus ? TColors.primary : null,
                ),
              ),
              trailing: isCurrentStatus ? const Icon(Icons.check, color: TColors.primary) : null,
              onTap: isCurrentStatus ? null : () {
                Get.back();
                controller.updateOrderStatus(order.id, status);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icon(Icons.access_time, color: Colors.orange[600]);
      case OrderStatus.confirmed:
        return Icon(Icons.check_circle, color: Colors.blue[600]);
      case OrderStatus.shipped:
        return Icon(Icons.local_shipping, color: Colors.purple[600]);
      case OrderStatus.delivered:
        return Icon(Icons.done_all, color: Colors.green[600]);
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