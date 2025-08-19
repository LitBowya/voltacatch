import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/colors.dart' as app_colors;
import '../../../core/constants/images.dart';
import '../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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

              const SizedBox(height: 20),

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
                            color: app_colors.TColors.primary.withAlpha((0.2 * 255).toInt()),
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
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: app_colors.TColors.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join us to get fresh farm products',
                      style: TextStyle(
                        fontSize: 16,
                        color: app_colors.TColors.lightGrey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Register Form
              Form(
                key: controller.registerFormKey,
                child: Column(
                  children: [
                    // First Name and Last Name Row
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            controller: controller.registerFirstNameController,
                            labelText: 'First Name',
                            hintText: 'Enter first name',
                            prefixIcon: Icons.person_outlined,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) => CustomValidators.validateName(
                              value,
                              'First name',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                            controller: controller.registerLastNameController,
                            labelText: 'Last Name',
                            hintText: 'Enter last name',
                            prefixIcon: Icons.person_outline,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) => CustomValidators.validateName(
                              value,
                              'Last name',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Email Field
                    CustomTextFormField(
                      controller: controller.registerEmailController,
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: CustomValidators.validateEmail,
                    ),

                    const SizedBox(height: 20),

                    // Phone Number Field (Optional)
                    CustomTextFormField(
                      controller: controller.registerPhoneController,
                      labelText: 'Phone Number (Optional)',
                      hintText: 'Enter your phone number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: CustomValidators.validatePhoneNumber,
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    Obx(
                      () => CustomTextFormField(
                        controller: controller.registerPasswordController,
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
                        validator: CustomValidators.validateStrongPassword,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Confirm Password Field
                    Obx(
                      () => CustomTextFormField(
                        controller:
                            controller.registerConfirmPasswordController,
                        labelText: 'Confirm Password',
                        hintText: 'Confirm your password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: !controller.isConfirmPasswordVisible.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: app_colors.TColors.lightGrey,
                          ),
                          onPressed: controller.toggleConfirmPasswordVisibility,
                        ),
                        validator: (value) =>
                            CustomValidators.validateConfirmPassword(
                              value,
                              controller.registerPasswordController.text,
                            ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Register Button
                    Obx(
                      () => CustomButton(
                        text: 'Create Account',
                        onPressed: controller.register,
                        isLoading: controller.isRegisterLoading.value,
                        icon: Icons.person_add,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: app_colors.TColors.lightGrey.withAlpha((0.5 * 255).toInt()),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: app_colors.TColors.lightGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: app_colors.TColors.lightGrey.withAlpha((0.5 * 255).toInt()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(color: app_colors.TColors.lightGrey),
                        ),
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'Sign In',
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
