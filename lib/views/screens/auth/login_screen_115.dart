import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import 'user_registration_screen.dart';
import '../customer/customer_home_screen_38.dart';
import '../host/become_host_screen_28.dart';
import '../host/host_home_dashboard_screen_37.dart';
import '../host/host_property_submitted_thankyou_screen.dart';
import '../driver/driver_home_dashboard_screen_83.dart';
import '../driver/become_driver_screen_29.dart';
import '../onboarding/application_submitted_screen_23.dart';
import '../onboarding/driver_application_rejected_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/host_service.dart';
import '../../../services/driver_service.dart';

class LoginScreen extends StatefulWidget {
  final bool isExistingUser;
  final String? initialPhone;

  const LoginScreen({
    super.key,
    this.isExistingUser = false,
    this.initialPhone,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null && widget.initialPhone!.isNotEmpty) {
      final clean = widget.initialPhone!.replaceAll(RegExp(r'[^0-9]'), '');
      final tenDigits = clean.length >= 10 ? clean.substring(clean.length - 10) : clean;
      _phoneController.text = tenDigits;
    }
  }

  void _showNoAccountFoundDialog(String phoneNumber) {
    Timer? autoCloseTimer;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        // Auto dismiss after 15 seconds
        autoCloseTimer = Timer(const Duration(seconds: 15), () {
          if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFCDD2), width: 2),
                  ),
                  child: const Icon(
                    Icons.person_off_rounded,
                    color: Colors.redAccent,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'No Account Found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'No registered account was found for mobile number $phoneNumber.\n\nPlease register to create an account or verify your credentials.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Register Now',
                  onPressed: () {
                    autoCloseTimer?.cancel();
                    Navigator.of(dialogContext).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserRegistrationScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      autoCloseTimer?.cancel();
                      Navigator.of(dialogContext).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Cancel (auto closes in 15s)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      autoCloseTimer?.cancel();
    });
  }

  String? _validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one capital letter (A-Z).';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number (0-9).';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return r'Password must contain at least one special character (!@#$%^&* etc.).';
    }
    return null;
  }

  void _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || phone.length < 10 || !RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number starting with 9, 8, 7, or 6.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password.'), backgroundColor: Colors.red),
      );
      return;
    }

    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordError), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final formattedPhone = phone.startsWith('+91') ? phone : '+91 $phone';

    // 🚀 Call Backend Mobile Login (POST /api/auth/mobile/login-init)
    final result = await AuthService.loginInitMobile(
      phone: formattedPhone,
      password: password,
    );

    if (result['success'] != true) {
      setState(() {
        _isLoading = false;
      });

      final backendMessage = (result['message'] ?? result['error'] ?? '').toString().toLowerCase();
      if (backendMessage.contains('password') ||
          backendMessage.contains('invalid password') ||
          backendMessage.contains('incorrect password')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect password. Please try again.'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        // Show "No Account Found" Dialog box that auto-closes after 15 seconds
        if (!mounted) return;
        _showNoAccountFoundDialog(phone);
      }
      return;
    }

    final matchedPhone = result['matchedPhone']?.toString() ?? formattedPhone;
    final prefs = await SharedPreferences.getInstance();
    final cleanDigits = matchedPhone.replaceAll(RegExp(r'[^0-9]'), '');

    // 1. Extract backend database role
    final backendUserRole = (result['role'] ??
            (result['data'] is Map ? result['data']['role'] : null) ??
            (result['user'] is Map ? result['user']['role'] : null))
        ?.toString()
        .toLowerCase();

    // 2. Authoritatively resolve the active role directly without speculative network pre-probing
    String role = 'customer';
    if (backendUserRole == 'driver') {
      role = 'driver';
    } else if (backendUserRole == 'host') {
      role = 'host';
    } else if (backendUserRole == 'customer') {
      role = 'customer';
    } else {
      final localRole = prefs.getString('user_role_$cleanDigits') ??
          prefs.getString('last_registered_role') ??
          prefs.getString('currentUserRole');
      if (localRole != null && (localRole == 'driver' || localRole == 'host' || localRole == 'customer')) {
        role = localRole;
      }
    }

    // 🚀 Complete authentication with selectRoleMobile to fetch JWT token & active user profile
    final roleResult = await AuthService.selectRoleMobile(
      phone: matchedPhone,
      role: role,
    );

    final user = roleResult['user'] ??
        (roleResult['data'] is Map ? roleResult['data']['user'] : null) ??
        result['user'] ??
        (result['data'] is Map ? result['data']['user'] : null);

    if (user != null && user['role'] != null && user['role'].toString().isNotEmpty) {
      final dbRole = user['role'].toString().toLowerCase();
      if (dbRole == 'driver' || dbRole == 'host') {
        role = dbRole;
      }
    }

    final token = roleResult['token'] ??
        (roleResult['data'] is Map ? roleResult['data']['token'] : null) ??
        result['token'] ??
        (result['data'] is Map ? result['data']['token'] : null);

    try {
      if (token != null) {
        await prefs.setString('authToken', token.toString());
      }
      if (user != null) {
        await prefs.setString('userProfile', jsonEncode(user));
        if (user['name'] != null && user['name'].toString().isNotEmpty) {
          await prefs.setString('currentUserName', user['name'].toString());
          await prefs.setString('user_name_$cleanDigits', user['name'].toString());
        }
        if (user['email'] != null && user['email'].toString().isNotEmpty) {
          await prefs.setString('currentUserEmail', user['email'].toString());
          await prefs.setString('user_email_$cleanDigits', user['email'].toString());
        }
        if (user['city'] != null && user['city'].toString().isNotEmpty) {
          await prefs.setString('currentUserCity', user['city'].toString());
          await prefs.setString('user_city_$cleanDigits', user['city'].toString());
        }
        if (user['location'] != null && user['location'].toString().isNotEmpty) {
          await prefs.setString('currentUserLocation', user['location'].toString());
          await prefs.setString('user_location_$cleanDigits', user['location'].toString());
        }
      }
      await prefs.setString('currentUserRole', role);
      await prefs.setString('currentPhone', matchedPhone);
      await prefs.setString('user_role_$cleanDigits', role);
    } catch (_) {}

    // If host, check approval status across all submitted properties
    HostApprovalResult? hostApprovalResult;
    String? resolvedHostName;
    if (role == 'host') {
      final hostId = (user != null && (user['userId'] != null || user['id'] != null))
          ? (user['userId'] ?? user['id']).toString()
          : null;
      resolvedHostName = (user != null && user['name'] != null && user['name'].toString().isNotEmpty)
          ? user['name'].toString()
          : await AuthService.getUserName(phone: matchedPhone);

      hostApprovalResult = await HostService.checkHostApprovalStatus(
        hostId: hostId,
        hostPhone: matchedPhone,
        userProfile: user is Map<String, dynamic> ? user : (user is Map ? Map<String, dynamic>.from(user) : null),
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login Successful!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );

    // 🚀 Intelligent Direct Role Routing:
    if (role == 'host') {
      final approval = hostApprovalResult ?? HostApprovalResult(status: HostApprovalStatus.noProperties, properties: []);
      if (approval.status == HostApprovalStatus.noProperties) {
        // Case 1: New Host (0 properties enlisted) -> Become a Host Screen (Screen 28)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BecomeHostScreen(),
          ),
        );
      } else if (approval.status == HostApprovalStatus.pendingApproval) {
        // Case 2: Pending Approval -> Gated Thank You / Status Screen (NO dashboard access)
        final firstProp = approval.properties.isNotEmpty ? approval.properties.first : null;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HostPropertySubmittedThankYouScreen(
              hostPhone: formattedPhone,
              hostName: resolvedHostName,
              propertyTitle: firstProp?['title'] ?? firstProp?['name'] ?? 'Submitted Property',
              propertyType: firstProp?['type'] ?? 'Hotel',
            ),
          ),
        );
      } else {
        // Case 3: Approved Host (properties approved by Admin) -> Direct Host Dashboard (Screen 37)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HostHomeDashboardScreen(userName: resolvedHostName),
          ),
        );
      }
    } else if (role == 'driver') {
      final statusResult = await DriverService.getDriverApprovalStatus(phone: formattedPhone);
      final isApproved = statusResult['isApproved'] == true;
      final status = (statusResult['status'] ?? '').toString().toLowerCase();
      final kyc = (statusResult['kyc'] ?? '').toString().toLowerCase();
      final isRejected = status == 'suspended' || status == 'rejected' || kyc == 'rejected';

      final driverData = statusResult['driver'];
      final hasSubmittedDocuments = driverData != null &&
          ((driverData['documents'] is Map &&
                  (driverData['documents']['vehicleRegistration']?.toString().isNotEmpty == true ||
                   driverData['documents']['pollutionCertificate']?.toString().isNotEmpty == true)) ||
           (driverData['vehicleInfo'] is Map &&
                  driverData['vehicleInfo']['vehicleNumberPlate']?.toString().isNotEmpty == true));

      if (!mounted) return;
      if (isApproved) {
        // Case 1: Approved by Admin -> Direct Driver Dashboard (Screen 83)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DriverHomeDashboardScreen83(),
          ),
        );
      } else if (isRejected) {
        // Case 2: Rejected by Admin -> Application Rejected Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverApplicationRejectedScreen(
              rejectionReason: statusResult['message']?.toString(),
              driverPhone: formattedPhone,
            ),
          ),
        );
      } else if (status == 'pending' && hasSubmittedDocuments) {
        // Case 3: Application Pending / Under Review -> Application Submitted Screen (Screen 82/23)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ApplicationSubmittedScreen(driverPhone: formattedPhone),
          ),
        );
      } else {
        // Case 4: New Driver User / Not yet submitted onboarding -> Screen 29 (Become a Driver Get Started)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BecomeDriverScreen(),
          ),
        );
      }
    } else {
      if (!mounted) return;
      // Customer / Guest Role -> Direct Customer Dashboard (Screen 38)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomerHomeScreen(),
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
            SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Top Header Row matching Screen 115 (Back Arrow & Country Flag Selector)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: const [
                        Text('🇮🇳', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Centered Zaatra Logo matching Screen 115
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/WhatsApp_Image_2026-07-30_at_9.42.30_PM-removebg-preview 2.png',
                      height: 64,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.airplanemode_active_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Zaatra',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('STAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.2)),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('|', style: TextStyle(color: AppColors.textMuted, fontSize: 10))),
                        Text('RIDE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent, letterSpacing: 1.2)),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('|', style: TextStyle(color: AppColors.textMuted, fontSize: 10))),
                        Text('EXPLORE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.2)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Mobile Number Input Field matching Screen 115
              const Text(
                'Mobile Number',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[6-9][0-9]*')),
                  LengthLimitingTextInputFormatter(10),
                ],
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: '9876543210',
                  counterText: '',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    child: Text(
                      '+91 ',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Password Input Field matching Screen 115
              const Text(
                'Password',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Forget Password Link matching Screen 115
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forget Password',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Login Button matching Screen 115
              CustomButton(
                text: 'Login',
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),

              const SizedBox(height: 28),

              // Register Account Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
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
                        MaterialPageRoute(builder: (context) => const UserRegistrationScreen()),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }
}
