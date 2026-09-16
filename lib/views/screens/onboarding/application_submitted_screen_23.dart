import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/driver_service.dart';
import '../../widgets/custom_button.dart';
import '../driver/driver_home_dashboard_screen_83.dart';
import '../auth/login_screen_115.dart';
import 'driver_application_rejected_screen.dart';

class ApplicationSubmittedScreen extends StatefulWidget {
  final String role;
  final String? driverPhone;

  const ApplicationSubmittedScreen({
    super.key,
    this.role = 'Driver',
    this.driverPhone,
  });

  @override
  State<ApplicationSubmittedScreen> createState() => _ApplicationSubmittedScreenState();
}

class _ApplicationSubmittedScreenState extends State<ApplicationSubmittedScreen> {
  bool _isCheckingApproval = false;

  Future<void> _handleGoToDashboard() async {
    setState(() {
      _isCheckingApproval = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final phone = widget.driverPhone ?? prefs.getString('currentPhone') ?? '';
    final statusResult = await DriverService.getDriverApprovalStatus(phone: phone);
    final isApproved = statusResult['isApproved'] == true;
    final status = (statusResult['status'] ?? '').toString().toLowerCase();
    final kyc = (statusResult['kyc'] ?? '').toString().toLowerCase();
    final isRejected = status == 'suspended' || status == 'rejected' || kyc == 'rejected';
    final message = statusResult['message']?.toString() ??
        "Your application is under review. We will notify you once you're approved.";

    setState(() {
      _isCheckingApproval = false;
    });

    if (!mounted) return;

    if (isApproved) {
      // 🚀 Admin Approval = YES -> Driver Dashboard (Screen 83)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DriverHomeDashboardScreen83()),
        (route) => false,
      );
    } else if (isRejected) {
      // 🚀 Admin Rejection = YES -> Driver Application Rejected Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DriverApplicationRejectedScreen(
            rejectionReason: message,
            driverPhone: phone,
          ),
        ),
      );
    } else {
      // 🚀 Admin Approval = NO -> Show Waiting for Admin Approval dialog (NO dashboard access)
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF3EDF7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.hourglass_top_rounded, color: AppColors.primary, size: 36),
          ),
          title: const Text(
            'Waiting for Admin Approval',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            '$message\n\nYou will be able to access the Driver Dashboard once your application is approved by the admin team.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'OK',
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const Spacer(),

                  // Green Check Circle Graphic matching Screen 82
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 56,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title matching Screen 82
                  const Text(
                    "You're all set !",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle Notice matching Screen 82
                  const Text(
                    "Your application is under review\nwe'll notify you once you're approved.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(),

                  // Primary Button matching Screen 82: Go To Dashboard (Gated by checkAdminApproval)
                  CustomButton(
                    text: _isCheckingApproval ? 'Checking Approval...' : 'Go To Dashboard',
                    onPressed: _isCheckingApproval ? () {} : _handleGoToDashboard,
                  ),

                  const SizedBox(height: 16),

                  // Secondary Button matching Screen 82: Back To Home
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Back To Login',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}