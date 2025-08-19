// lib/features/profile/widgets/about_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text.dart';

class AboutBottomSheet extends StatefulWidget {
  const AboutBottomSheet({super.key});

  @override
  State<AboutBottomSheet> createState() => _AboutBottomSheetState();
}

class _AboutBottomSheetState extends State<AboutBottomSheet> {
  String appVersion = '';
  String buildNumber = '';

  @override
  void initState() {
    super.initState();
    _getAppInfo();
  }

  Future<void> _getAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Logo and Info
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          TColors.primary.withAlpha((255 * 0.1).toInt()),
                          TColors.primary.withAlpha((255 * 0.1).toInt()),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // App Logo
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/logos/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.agriculture,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // App Name
                        const Text(
                          TTexts.companyName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D3748),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // App Version
                        Text(
                          'Version $appVersion ($buildNumber)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // App Description
                        Text(
                          'Your trusted marketplace for fresh farm produce, connecting farmers directly with consumers across Ghana.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Features Section
                  _buildSectionHeader('What We Offer'),
                  const SizedBox(height: 16),

                  _buildFeatureItem(
                    icon: Icons.local_shipping_outlined,
                    title: TTexts.offerTitle1,
                    description: TTexts.offerSubtitle1,
                  ),

                  _buildFeatureItem(
                    icon: Icons.support_agent_outlined,
                    title: TTexts.offerTitle2,
                    description: TTexts.offerSubtitle2,
                  ),

                  _buildFeatureItem(
                    icon: Icons.payment_rounded,
                    title: TTexts.offerTitle3,
                    description: TTexts.offerSubtitle3,
                  ),

                  _buildFeatureItem(
                    icon: Icons.download_done,
                    title: TTexts.offerTitle4,
                    description: TTexts.offerSubtitle4,
                  ),

                  const SizedBox(height: 32),

                  // Company Info Section
                  _buildSectionHeader('About Our Company'),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TTexts.aboutCompany1,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          TTexts.aboutCompany2,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Contact & Social Section
                  _buildSectionHeader('Connect With Us'),
                  const SizedBox(height: 16),

                  _buildContactItem(
                    icon: Icons.language_outlined,
                    title: 'Website',
                    subtitle: TTexts.connectWebsite,
                    onTap: () => _launchUrl(TTexts.connectWebsite),
                  ),

                  _buildContactItem(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: TTexts.callSupportEmail,
                    onTap: () => _sendEmail(TTexts.callSupportEmail),
                  ),

                  _buildContactItem(
                    icon: Icons.phone_outlined,
                    title: 'Phone',
                    subtitle: TTexts.callSupportNumber,
                    onTap: () => _makePhoneCall(TTexts.callSupportNumber),
                  ),

                  const SizedBox(height: 24),

                  // Social Media Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        'assets/logos/fb.png',
                            () => _launchUrl(TTexts.connectFacebook),
                      ),
                      const SizedBox(width: 16),
                      _buildSocialButton(
                        null,
                            () => _launchUrl(TTexts.connectTwitter),
                        icon: Icons.close, // Twitter X icon placeholder
                      ),
                      const SizedBox(width: 16),
                      _buildSocialButton(
                        null,
                            () => _launchUrl(TTexts.connectInstagram),
                        icon: Icons.camera_alt_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D3748),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TColors.primary.withAlpha((255 * 0.1).toInt()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: TColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: TColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String? assetPath, VoidCallback onTap, {IconData? icon}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: assetPath != null
                ? Image.asset(
              assetPath,
              width: 24,
              height: 24,
            )
                : Icon(
              icon,
              color: Colors.grey[600],
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not launch $url');
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Farm Commerce Inquiry',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar('Error', 'Could not launch email client');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar('Error', 'Could not launch phone dialer');
    }
  }



}