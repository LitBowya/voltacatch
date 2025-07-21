// lib/features/navigation/views/admin_navigation.dart
import 'package:voltacatch/features/admin/home/views/admin_main_screen.dart';
import 'package:voltacatch/features/admin/orders/views/admin_orders_screen.dart';
import 'package:voltacatch/features/admin/products/views/admin_product_screen.dart';
import 'package:voltacatch/features/admin/profile/views/admin_profile_screen.dart';
import 'package:voltacatch/features/navigation/controllers/admin_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';

class AdminNavigation extends StatelessWidget {
  const AdminNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final adminNavigationController = Get.find<AdminNavigationController>();

    final List<Widget> screens = [
      const AdminMainScreen(),
      const AdminProductsScreen(),
      const AdminOrdersScreen(),
      const AdminProfileScreen(),
    ];

    return Scaffold(
      body: Obx(() => screens[adminNavigationController.selectedIndex.value]),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: adminNavigationController.selectedIndex.value,
        onTap: adminNavigationController.changeIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: TColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            activeIcon: Icon(Icons.admin_panel_settings),
            label: 'Profile',
          ),
        ],
      )),
    );
  }
}