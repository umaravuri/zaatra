import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_button.dart';
import 'auth/login_screen_115.dart';
import 'location_permission_screen_25.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.height < 650;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
          fit: StackFit.expand,
          children: [
            // Bottom Background Graphic
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/images/image 31.png',
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            Stack(
        children: [
          // Background City Skyline & Palm Watermark matching 24(1).png
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/otp bg 1(1).png',
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/otp bg 1.png',
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Top Vector Illustration from Folder 24 matching Screen 24
                      Expanded(
                        flex: isSmallScreen ? 3 : 5,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Image.asset(
                              'assets/images/9c9ca086-b3ad-4e29-b8f1-0002d77c03bd 2.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/screen_24_illustration.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.person_pin_rounded, size: 100, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Text Content & Action Buttons Container
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Title matching Screen 24
                          const Text(
                            'Welcome to Zaatra',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: -0.3,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Subtitle matching Screen 24
                          const Text(
                            'Book, host or drive\neverything you need in one app.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Get Started Button matching Screen 24
                          CustomButton(
                            text: 'Get Started',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LocationPermissionScreen()),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Footer Link: Already have an account? Login
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    );
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
          ],
        ),
    );
  }
}