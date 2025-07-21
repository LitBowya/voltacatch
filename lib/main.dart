// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check if the user has seen the onboarding screen
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  // Make the AuthController available for the whole app
  Get.put(AuthController());

  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}
