import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/images.dart';
import '../../../core/constants/text.dart';
import '../models/onboarding_model.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<OnboardingData> onboardingData = [
    OnboardingData(
      title: TTexts.onboardingTitle1,
      subtitle: TTexts.onboardingsubtitle1,
      image: TImages.onboardingImage1,
    ),
    OnboardingData(
      title: TTexts.onboardingTitle2,
      subtitle: TTexts.onboardingsubtitle2,
      image: TImages.onboardingImage2,
    ),
    OnboardingData(
      title: TTexts.onboardingTitle3,
      subtitle: TTexts.onboardingsubtitle3,
      image: TImages.onboardingImage3,
    ),
  ];


  void nextPage() async {
    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to next screen (e.g., login/home)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);
      Get.offAllNamed('/login');
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
