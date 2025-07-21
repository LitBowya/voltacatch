// lib/features/admin/orders/widgets/order_timeline.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../orders/models/order_model.dart';

class OrderTimeline extends StatelessWidget {
  final OrderModel order;

  const OrderTimeline({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final timelineItems = _generateTimelineItems();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: timelineItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == timelineItems.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: item.isCompleted ? item.color : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      size: 12,
                      color: item.isCompleted ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: item.isCompleted ? TColors.dark : Colors.grey[600],
                      ),
                    ),
                    if (item.timestamp != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM dd, yyyy HH:mm').format(item.timestamp!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (!isLast) const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<TimelineItem> _generateTimelineItems() {
    return [
      TimelineItem(
        title: 'Order Placed',
        icon: Icons.shopping_cart,
        color: Colors.green,
        isCompleted: true,
        timestamp: order.createdAt,
      ),
      TimelineItem(
        title: 'Order Confirmed',
        icon: Icons.check_circle,
        color: Colors.blue,
        isCompleted: _isStatusReached(OrderStatus.confirmed),
        timestamp: _isStatusReached(OrderStatus.confirmed) ? order.updatedAt : null,
      ),
      TimelineItem(
        title: 'Order Shipped',
        icon: Icons.local_shipping,
        color: Colors.purple,
        isCompleted: _isStatusReached(OrderStatus.shipped),
        timestamp: _isStatusReached(OrderStatus.shipped) ? order.updatedAt : null,
      ),
      TimelineItem(
        title: 'Order Delivered',
        icon: Icons.done_all,
        color: Colors.green,
        isCompleted: _isStatusReached(OrderStatus.delivered),
        timestamp: _isStatusReached(OrderStatus.delivered) ? order.updatedAt : null,
      ),
    ];
  }

  bool _isStatusReached(OrderStatus targetStatus) {
    final statusOrder = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];

    final currentIndex = statusOrder.indexOf(order.status);
    final targetIndex = statusOrder.indexOf(targetStatus);

    return currentIndex >= targetIndex;
  }
}

class TimelineItem {
  final String title;
  final IconData icon;
  final Color color;
  final bool isCompleted;
  final DateTime? timestamp;

  TimelineItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.isCompleted,
    this.timestamp,
  });
}