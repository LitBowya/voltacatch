import 'package:flutter/material.dart';

import '../models/onboarding_model.dart'; // Assuming OnboardingData and TImages are defined here

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold( // Using Scaffold for overall page structure and background color
      backgroundColor: Colors.white, // Set the background color for the entire page
      body: Center( // Center the entire content column vertically and horizontally
        child: SingleChildScrollView( // Allows content to scroll if it overflows
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // Add horizontal padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically within the column
            crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
            children: [
              // Image Container
              SizedBox(
                width: screenWidth * 0.75, // Image takes 70% of screen width
                child: ClipRRect( // Apply rounded corners to the image
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners for the image
                  child: Image.asset(
                    data.image,
                    fit: BoxFit.cover, // Image will cover its defined SizedBox area, potentially cropping
                    // Consider BoxFit.contain if you want the entire image to always be visible,
                    // which might leave empty space around it if aspect ratios don't match.
                  ),
                ),
              ),

              const SizedBox(height: 20), // Spacing between image and text content

              // Text Content (Title and Subtitle)
              // No need for an overlay container as text is now separate from the image
              Column(
                children: [
                  // Title Text
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28, // Adjusted font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black12, // Softer shadow for lighter background
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16), // Spacing between title and subtitle
                  // Subtitle Text
                  Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16, // Adjusted font size
                      color: Colors.black54,
                      height: 1.5, // Line height for readability
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black12, // Softer shadow
                          offset: Offset(0.5, 0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
