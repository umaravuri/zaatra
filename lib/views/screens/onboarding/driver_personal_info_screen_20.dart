import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'driver_document_upload_screen_21.dart';

class DriverPersonalInfoScreen extends StatefulWidget {
  final String role;

  const DriverPersonalInfoScreen({super.key, this.role = 'Driver'});

  @override
  State<DriverPersonalInfoScreen> createState() => _DriverPersonalInfoScreenState();
}

class _DriverPersonalInfoScreenState extends State<DriverPersonalInfoScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAuthProfile();
  }

  Future<void> _loadAuthProfile() async {
    final user = await AuthService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _nameController.text = user['name']?.toString() ?? '';
        _emailController.text = user['email']?.toString() ?? '';
        final p = user['phone']?.toString() ?? '';
        final digits = p.replaceAll(RegExp(r'[^0-9]'), '');
        final tenDigits = digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
        _phoneController.text = tenDigits;
        _locationController.text = user['location']?.toString() ?? user['city']?.toString() ?? '';
      });
    } else {
      final name = await AuthService.getUserName(defaultFallback: '');
      if (name.isNotEmpty && mounted) {
        setState(() {
          _nameController.text = name;
        });
      }
    }
  }

  void _nextStep() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (phone.isEmpty || phone.length < 10 || !RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number starting with 9, 8, 7, or 6.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.'), backgroundColor: Colors.red),
      );
      return;
    }

    final formattedPhone = phone.startsWith('+91') ? phone : '+91 $phone';

    final driverData = {
      'name': name,
      'email': email,
      'phone': formattedPhone,
      'password': 'DriverSecretPassword123',
      'location': location.isNotEmpty ? location : 'India',
      'country': 'India',
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverDocumentUploadScreen(
          role: widget.role,
          driverData: driverData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Bar matching Screen 31
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.33,
                            minHeight: 6,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Step 1 of 3',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Screen 31 Header matching Figma
                  const Text(
                    'Tell us About yourself',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Fill in the details about your profile',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 28),

                  // Full Name Field
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter here',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline_rounded,
                  ),

                  const SizedBox(height: 18),

                  // Email ID Field
                  CustomTextField(
                    label: 'Email ID',
                    hint: 'Enter here',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 18),

                  // Phone Number Field
                  CustomTextField(
                    label: 'Phone Number',
                    hint: '9876543210',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^[6-9][0-9]*')),
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Location Field
                  CustomTextField(
                    label: 'Location',
                    hint: 'Enter your location (e.g. Indiranagar, Bengaluru)',
                    controller: _locationController,
                    prefixIcon: Icons.my_location_rounded,
                  ),

                  const SizedBox(height: 36),

                  // Continue CTA Button matching Screen 31
                  CustomButton(
                    text: 'Continue',
                    onPressed: _nextStep,
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
