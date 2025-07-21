
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../controllers/navigation_controller.dart';

class MainScreenWrapper extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const MainScreenWrapper({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.white),),
        backgroundColor: TColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: TColors.dark),
        actions: actions,
      ),
      body: child,
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: navigationController.selectedIndex.value,
        onTap: (index) {
          navigationController.changeIndex(index);
          // Navigate back to admin with the selected tab
          Get.offNamedUntil('/home', (route) => route.settings.name != '/home');
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