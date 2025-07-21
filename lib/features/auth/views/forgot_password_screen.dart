import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/colors.dart' as app_colors;
import '../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Back Button
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back_ios, color: app_colors.TColors.dark),
                padding: EdgeInsets.zero,
              ),

              const SizedBox(height: 40),

              // Logo and Content
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: app_colors.TColors.primary.withAlpha(10),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.lock_reset,
                        size: 50,
                        color: app_colors.TColors.primary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: app_colors.TColors.dark,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'No worries! Enter your email address and we\'ll send you a link to reset your password.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: app_colors.TColors.lightGrey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Forgot Password Form
              Form(
                key: controller.forgotPasswordFormKey,
                child: Column(
                  children: [
                    // Email Field
                    CustomTextFormField(
                      controller: controller.forgotPasswordEmailController,
                      labelText: 'Email Address',
                      hintText: 'Enter your registered email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: CustomValidators.validateEmail,
                    ),

                    const SizedBox(height: 32),

                    // Send Reset Link Button
                    Obx(
                      () => CustomButton(
                        text: 'Send Reset Link',
                        onPressed: controller.forgotPassword,
                        isLoading: controller.isForgotPasswordLoading.value,
                        icon: Icons.send,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: app_colors.TColors.primary.withAlpha(50),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: app_colors.TColors.primary.withAlpha(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: app_colors.TColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Check your email',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: app_colors.TColors.dark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'We\'ll send a password reset link to your email address. Make sure to check your spam folder too.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: app_colors.TColors.lightGrey,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Back to Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: app_colors.TColors.primary,
                        ),
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'Back to Sign In',
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
