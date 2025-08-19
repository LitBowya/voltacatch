
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_order_controller.dart';
import 'order_item_card.dart';
import 'order_search_bar.dart';
import 'order_filter_bar.dart';

class OrderList extends StatelessWidget {
  const OrderList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminOrderController());

    return Column(
      children: [
        // Search Bar
        const OrderSearchBar(),
        const SizedBox(height: 12),

        // Filter Bar
        const OrderFilterBar(),
        const SizedBox(height: 16),

        // Orders List
        Expanded(
          child: Obx(() {
            if (controller.isLoading && controller.orders.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No orders found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Orders will appear here when customers place them',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.loadOrders(refresh: true),
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!controller.isLoading &&
                      controller.hasMore &&
                      scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                    controller.loadOrders();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.orders.length + (controller.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.orders.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final order = controller.orders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OrderItemCard(order: order),
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}