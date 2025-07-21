import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/colors.dart' as app_colors;
import '../../../core/constants/images.dart';
import '../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo and Welcome Text
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: app_colors.TColors.primary.withAlpha(20),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(TImages.logo, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: app_colors.TColors.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your account',
                      style: TextStyle(
                        fontSize: 16,
                        color: app_colors.TColors.lightGrey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Login Form
              Form(
                key: controller.loginFormKey,
                child: Column(
                  children: [
                    // Email Field
                    CustomTextFormField(
                      controller: controller.loginEmailController,
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: CustomValidators.validateEmail,
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    Obx(
                      () => CustomTextFormField(
                        controller: controller.loginPasswordController,
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icons.lock_outlined,
                        obscureText: !controller.isPasswordVisible.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: app_colors.TColors.lightGrey,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                        validator: CustomValidators.validatePassword,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: controller.goToForgotPassword,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: app_colors.TColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    Obx(
                      () => CustomButton(
                        text: 'Sign In',
                        onPressed: controller.login,
                        isLoading: controller.isLoginLoading.value,
                        icon: Icons.login,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Login Button
                    Obx(
                          () => CustomButton(
                        text: 'Skip',
                        onPressed: controller.skip,
                        isLoading: controller.isSkipLoading.value,
                        textColor: Colors.black,
                            backgroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: app_colors.TColors.lightGrey),
                        ),
                        TextButton(
                          onPressed: controller.goToRegister,
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: app_colors.TColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
