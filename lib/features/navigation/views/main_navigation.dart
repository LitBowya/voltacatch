// lib/features/navigation/views/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../controllers/navigation_controller.dart';
import '../../home/views/home_screen.dart';
import '../../shop/views/shop_screen.dart';
import '../../cart/views/cart_screen.dart';
import '../../profile/views/profile_screen.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.put(NavigationController());

    final List<Widget> screens = [
      const HomeScreen(),
      const ShopScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Obx(() => screens[navigationController.selectedIndex.value]),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: navigationController.selectedIndex.value,
        onTap: navigationController.changeIndex,
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
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      )),
    );
  }
}