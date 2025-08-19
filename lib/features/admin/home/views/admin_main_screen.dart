
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../widgets/stat_card.dart';
import '../widgets/orders_chart.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminDashboardController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TColors.dark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => controller.refreshData(),
            icon: const Icon(
              Icons.refresh,
              color: TColors.dark,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stat Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      title: 'Total Users',
                      value: controller.totalUsers.value.toString(),
                      icon: Icons.people_outline,
                      iconColor: Colors.blue,
                    ),
                    StatCard(
                      title: 'Total Products',
                      value: controller.totalProducts.value.toString(),
                      icon: Icons.inventory_2_outlined,
                      iconColor: Colors.green,
                    ),
                    StatCard(
                      title: 'Total Orders',
                      value: controller.totalOrders.value.toString(),
                      icon: Icons.receipt_long_outlined,
                      iconColor: Colors.orange,
                    ),
                    StatCard(
                      title: 'Categories',
                      value: controller.totalCategories.value.toString(),
                      icon: Icons.category_outlined,
                      iconColor: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Orders Chart
                const OrdersChart(),
                const SizedBox(height: 24),

              ],
            ),
          ),
        );
      }),
    );
  }
}