import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';

class AuthController extends GetxController {
  // Firebase instances
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // Form keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  final TextEditingController registerFirstNameController =
      TextEditingController();
  final TextEditingController registerLastNameController =
      TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPhoneController = TextEditingController();
  final TextEditingController registerPasswordController =
      TextEditingController();
  final TextEditingController registerConfirmPasswordController =
      TextEditingController();

  final TextEditingController forgotPasswordEmailController =
      TextEditingController();

  // Loading states
  final RxBool isLoginLoading = false.obs;
  final RxBool isSkipLoading = false.obs;
  final RxBool isRegisterLoading = false.obs;
  final RxBool isForgotPasswordLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  static const int timeoutDuration = 60; // seconds

  // Current user
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    firebaseUser.bindStream(auth.authStateChanges());
    ever(firebaseUser, _handleAuthChanged);
  }

  @override
  void onClose() {
    // Dispose controllers
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerFirstNameController.dispose();
    registerLastNameController.dispose();
    registerEmailController.dispose();
    registerPhoneController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    forgotPasswordEmailController.dispose();
    super.onClose();
  }

  void _handleAuthChanged(User? user) {
    if (user != null) {
      _loadUserData(user.uid);
    } else {
      currentUser.value = null;
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        currentUser.value = UserModel.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Login functionality
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text;

    try {
      isLoginLoading.value = true;

      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: timeoutDuration),
        onTimeout: () {
          throw Exception('Request timeout. Please check your connection.');
        },
      );

      if (credential.user != null) {
        _showToast('Login successful!', Colors.green);
        Get.offAllNamed('/home'); // Navigate to home screen
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _showToast('An unexpected error occurred', Colors.red);
    } finally {
      isLoginLoading.value = false;
    }
  }

  // Skip Functionality
  Future<void> skip() async {
    isSkipLoading.value = true;
    Get.offAllNamed('/home');
  }

  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    final email = registerEmailController.text.trim();
    final password = registerPasswordController.text;
    final firstName = registerFirstNameController.text.trim();
    final lastName = registerLastNameController.text.trim();
    final phoneNumber = registerPhoneController.text.trim();

    try {
      isRegisterLoading.value = true;

      final credential = await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Registration timed out. Please try again.');
        },
      );

      if (credential.user != null) {
        // Create user document in Firestore
        final user = UserModel(
          email: email,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(user.toMap());

        // Update Firebase Auth display name
        await credential.user!
            .updateDisplayName('$firstName $lastName');

        // Send email verification
        await credential.user!
            .sendEmailVerification();

        _showToast(
          'Registration successful!',
          Colors.green,
        );
        Get.offAllNamed('/login'); // Navigate to login screen
      }
    } on TimeoutException catch (e) {
      _showToast(e.message ?? 'Operation timed out', Colors.red);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _showToast('An unexpected error occurred', Colors.red);
    } finally {
      isRegisterLoading.value = false;
    }
  }


  // Forgot password functionality
  Future<void> forgotPassword() async {
    if (!forgotPasswordFormKey.currentState!.validate()) return;

    final email = forgotPasswordEmailController.text.trim();

    try {
      isForgotPasswordLoading.value = true;

      await auth.sendPasswordResetEmail(email: email);

      _showToast('Password reset email sent! Check your inbox.', Colors.green);
      Get.back(); // Go back to login screen
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _showToast('An unexpected error occurred', Colors.red);
    } finally {
      isForgotPasswordLoading.value = false;
    }
  }

  // Clear form data
  void clearLoginForm() {
    loginEmailController.clear();
    loginPasswordController.clear();
  }

  void clearRegisterForm() {
    registerFirstNameController.clear();
    registerLastNameController.clear();
    registerEmailController.clear();
    registerPhoneController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
  }

  void clearForgotPasswordForm() {
    forgotPasswordEmailController.clear();
  }

  // Logout functionality
  Future<void> logout() async {
    try {
      await auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      _showToast('Error signing out', Colors.red);
    }
  }

  // Handle Firebase Auth errors
  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email address.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email address.';
        break;
      case 'weak-password':
        message = 'Password is too weak. Please choose a stronger password.';
        break;
      case 'invalid-email':
        message = 'Please enter a valid email address.';
        break;
      case 'too-many-requests':
        message = 'Too many failed attempts. Please try again later.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your connection.';
        break;
      default:
        message = 'Authentication failed: ${e.message}';
    }
    _showToast(message, Colors.red);
  }

  // Show toast message
  // Show message using SnackBar
  void _showToast(String message, Color backgroundColor) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      debugPrint('No context found to show SnackBar');
    }
  }

  // Navigation methods
  void goToLogin() => Get.toNamed('/login');
  void goToRegister() => Get.toNamed('/register');
  void goToForgotPassword() => Get.toNamed('/forgot-password');
}
