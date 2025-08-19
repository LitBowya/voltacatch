// lib/features/home/views/home_screen.dart
import 'package:voltacatch/features/products/widgets/latest_products_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/colors.dart';
import '../controllers/home_controller.dart';
import '../widgets/carousel_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Good Day!!", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("${user != null ? user.displayName : 'Guest'}",  style: const TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SimpleCarouselBanner(),
              const SizedBox(height: 24),
              LatestProductsWidget(products: controller.products),
            ],
          ),
        );
      }),
    );
  }
}