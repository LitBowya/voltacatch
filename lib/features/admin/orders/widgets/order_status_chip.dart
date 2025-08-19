// lib/features/admin/orders/widgets/order_status_chip.dart
import 'package:flutter/material.dart';
import '../../../orders/models/order_model.dart';

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withAlpha((255 * 0.1).toInt()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: 12,
            color: _getStatusColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(),
            style: TextStyle(
              color: _getStatusColor(),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange[600]!;
      case OrderStatus.confirmed:
        return Colors.blue[600]!;
      case OrderStatus.shipped:
        return Colors.purple[600]!;
      case OrderStatus.delivered:
        return Colors.green[600]!;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case OrderStatus.pending:
        return Icons.access_time;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.done_all;
    }
  }

  String _getStatusText() {
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