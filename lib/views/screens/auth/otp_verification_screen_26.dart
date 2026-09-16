import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/driver_service.dart';
import '../../widgets/custom_button.dart';
import '../role_selection_screen_27.dart';
import '../driver/become_driver_screen_29.dart';
import 'login_screen_115.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isExistingUser;
  final bool isRegistrationFlow;
  final String userName;
  final String userRole;
  final String? expectedOtp;
  final String? password;

  const OtpVerificationScreen({
    Key? key,
    required this.phoneNumber,
    this.isExistingUser = false,
    this.isRegistrationFlow = false,
    this.userName = 'User',
    this.userRole = 'Host',
    this.expectedOtp,
    this.password,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _pinControllers = List.generate(6, (_) => TextEditingController());
  late String _currentExpectedOtp;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentExpectedOtp = widget.expectedOtp ?? (100000 + Random().nextInt(900000)).toString();
  }

  void _resendOtp() async {
    String newOtp = (100000 + Random().nextInt(900000)).toString();

    if (widget.password != null && widget.password!.isNotEmpty) {
      final res = await AuthService.loginInitMobile(
        phone: widget.phoneNumber,
        password: widget.password!,
      );
      final backendOtp = (res['otp'] ?? (res['data'] is Map ? res['data']['otp'] : null))?.toString();
      if (backendOtp != null) {
        newOtp = backendOtp;
      }
    }

    setState(() {
      _currentExpectedOtp = newOtp;
      for (var controller in _pinControllers) {
        controller.clear();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.vpn_key_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'New OTP: $_currentExpectedOtp',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _verifyOtp() async {
    final code = _pinControllers.map((c) => c.text).join();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit verification code.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 🚀 Call Backend Mobile Login Step 2 (POST /api/auth/mobile/verify-otp)
    await AuthService.verifyOtpMobile(
      phone: widget.phoneNumber,
      otp: code,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    // 🚀 Flow 1: Registration Flow -> Redirect to Login Screen with phone prefilled
    if (widget.isRegistrationFlow) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number verified! Please log in with your credentials.'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            initialPhone: widget.phoneNumber,
            isExistingUser: true,
          ),
        ),
        (route) => false,
      );
      return;
    }

    // 🚀 Flow 2: Direct OTP verification (Non-registration)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP Verified Successfully!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 1),
      ),
    );

    // 🚀 Check Admin Approval Status
    final isApproved = await DriverService.checkAdminApproval(widget.phoneNumber);

    if (!mounted) return;

    if (isApproved) {
      // Case 1 — Already Approved by Admin:
      // Treat as Old / Existing Customer -> Choose Role Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RoleSelectionScreen(
            phoneNumber: widget.phoneNumber,
            isExistingUser: true,
          ),
        ),
      );
    } else {
      // Case 2 — Not Approved by Admin:
      // Treat as New Customer -> Get Started Screen (BecomeDriverScreen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BecomeDriverScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Bottom Background Graphic (image 31.png)
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Back Button matching Screen 26
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.inputBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
                    ),
                  ),

              const SizedBox(height: 28),

              // Title Header matching Screen 26
              const Text(
                'Verify Your Number',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: 'Enter The 6 Digits code sent to\n',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
                  children: [
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Trial Version Sample OTP Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.vpn_key_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Trial Mode Sample OTP: $_currentExpectedOtp',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        for (int i = 0; i < 6 && i < _currentExpectedOtp.length; i++) {
                          _pinControllers[i].text = _currentExpectedOtp[i];
                        }
                        setState(() {});
                      },
                      child: const Text('Autofill', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 6 PIN Input Boxes matching Screen 26
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 5 * 8) / 6;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      6,
                      (index) => SizedBox(
                        width: itemWidth,
                        height: 54,
                        child: TextField(
                          controller: _pinControllers[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.inputBackground,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && index < 5) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Resend Code Button & Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _resendOtp,
                    child: const Text(
                      'Re-send new code',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: 'Expires in ',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      children: const [
                        TextSpan(
                          text: '00 : 59',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Confirm Button matching Screen 26
              CustomButton(
                text: 'Confirm',
                isLoading: _isLoading,
                onPressed: _verifyOtp,
              ),
            ],
          ),
        ),
      ),
        ],
      ),
);
  }
}
