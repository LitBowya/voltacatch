// lib/redirect.dart
import 'package:voltacatch/features/navigation/views/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/views/login_screen.dart';
import 'features/onboarding/views/onboarding.dart';

class Redirect extends StatelessWidget {
  final bool hasSeenOnboarding;

  const Redirect({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    // Obx listens to reactive changes and rebuilds the widget accordingly
    return Obx(() {
      // Show a loading spinner while checking auth state
      if (authController.firebaseUser.value == null && authController.currentUser.value == null) {
        // If user is not logged in, decide between onboarding and login
        if (hasSeenOnboarding) {
          return const LoginScreen();
        } else {
          return const OnboardingScreen();
        }
      }
      // If user is logged in, go to the home screen
      return const MainNavigation();
    });
  }
}