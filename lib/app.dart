// lib/app.dart
import 'package:voltacatch/features/navigation/controllers/admin_navigation_controller.dart';
import 'package:voltacatch/features/navigation/views/admin_navigation.dart';
import 'package:voltacatch/features/admin/products/controllers/product_controller.dart';
import 'package:voltacatch/features/admin/categories/controllers/category_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/auth/views/forgot_password_screen.dart';
import 'features/auth/views/login_screen.dart';
import 'features/auth/views/register_screen.dart';
import 'features/navigation/views/main_navigation.dart';
import 'features/onboarding/views/onboarding.dart';
import 'redirect.dart';
import 'features/admin/products/views/create_product_screen.dart';
import 'features/admin/categories/views/create_category_screen.dart';

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers globally
    _initializeControllers();

    return GetMaterialApp(
      title: 'Farm Commerce',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: Redirect(hasSeenOnboarding: hasSeenOnboarding),
      getPages: [
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/forgot-password', page: () => const ForgotPasswordScreen()),
        GetPage(name: '/home', page: () => const MainNavigation()),
        GetPage(name: '/admin', page: () => const AdminNavigation()),
        GetPage(name: '/admin/products/create', page: () => const CreateProductScreen()),
        GetPage(name: '/admin/categories/create', page: () => const CreateCategoryScreen()),
      ],
    );
  }

  void _initializeControllers() {
    // Register controllers globally
    Get.put(ProductController(), permanent: true);
    Get.put(CategoryController(), permanent: true);
    Get.put(AdminNavigationController(), permanent: true);
  }
}