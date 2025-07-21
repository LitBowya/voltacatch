// lib/features/admin/shared/widgets/admin_screen_wrapper.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../controllers/admin_navigation_controller.dart';

class AdminScreenWrapper extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const AdminScreenWrapper({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final adminNavigationController = Get.find<AdminNavigationController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.white),),
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: TColors.dark),
        actions: actions,
      ),
      body: child,
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: adminNavigationController.selectedIndex.value,
        onTap: (index) {
          adminNavigationController.changeIndex(index);
          // Navigate back to admin with the selected tab
          Get.offNamedUntil('/admin', (route) => route.settings.name != '/admin');
        },
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