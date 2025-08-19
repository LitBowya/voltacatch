import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/colors.dart' as app_colors;
import '../controllers/onboarding_controller.dart';

class OnboardingNavigationButtons extends StatelessWidget {
  const OnboardingNavigationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          AnimatedOpacity(
            opacity: controller.currentPage.value > 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: GestureDetector(
              onTap: controller.currentPage.value > 0
                  ? controller.previousPage
                  : null,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: app_colors.TColors.primary.withAlpha((0.8 * 255).toInt()),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // Next/Get Started button
          GestureDetector(
            onTap: controller.nextPage,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: app_colors.TColors.primary,
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                  BoxShadow(
                    color: app_colors.TColors.primary.withAlpha((0.3 * 255).toInt()),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.currentPage.value ==
                            controller.onboardingData.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    controller.currentPage.value ==
                            controller.onboardingData.length - 1
                        ? Icons.rocket_launch
                        : Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
