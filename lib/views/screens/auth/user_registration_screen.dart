import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/host_service.dart';
import '../../../services/driver_service.dart';
import '../../widgets/custom_button.dart';
import 'otp_verification_screen_26.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');

  String? _selectedRole;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _roles = [
    {
      'role': 'Customer',
      'label': 'Customer',
      'desc': 'Book stays & rides',
      'icon': Icons.person_rounded,
      'color': const Color(0xFFFBC02D),
      'bg': const Color(0xFFFFFDE7),
    },
    {
      'role': 'Host',
      'label': 'Host',
      'desc': 'List properties',
      'icon': Icons.home_rounded,
      'color': const Color(0xFFE53935),
      'bg': const Color(0xFFFFEBEE),
    },
    {
      'role': 'Driver',
      'label': 'Driver',
      'desc': 'Offer rides & earn',
      'icon': Icons.directions_car_rounded,
      'color': const Color(0xFFD32F2F),
      'bg': const Color(0xFFFFEBEE),
    },
  ];

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter (A-Z).';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number (0-9).';
    }
    if (!RegExp(r'[!@#\$%^&*()_\-+=\[\]{}|;:,.<>?/~`]').hasMatch(value)) {
      return 'Password must contain at least one special character (!@#\$%...).';
    }
    return null;
  }

  void _handleRegistration() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final phone = _phoneController.text.trim();
    final city = _cityController.text.trim();
    final state = _stateController.text.trim();
    final country = _countryController.text.trim();

    final selectedRole = _selectedRole;
    if (selectedRole == null || selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an account type (Host, Customer, or Driver).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
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
    final passError = _validatePassword(password);
    if (passError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passError), backgroundColor: Colors.red),
      );
      return;
    }
    if (confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please re-enter your password to confirm.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match. Please re-enter identical passwords.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your city.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (state.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your state.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (country.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your country.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final formattedPhone = phone.startsWith('+91') ? phone : '+91 $phone';

    // 🚀 Call Backend User Registration API (POST /api/auth/register)
    final regResult = await AuthService.registerUser(
      name: name,
      email: email,
      password: password,
      phone: formattedPhone,
      city: city,
      state: state,
      country: country,
      role: selectedRole,
    );

    if (regResult['success'] != true) {
      setState(() {
        _isLoading = false;
      });
      final msg = (regResult['message'] ?? regResult['error'] ?? 'Registration failed. Please check your information and try again.').toString();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Also register Host or Driver profile if applicable
    if (selectedRole.toLowerCase() == 'host') {
      try {
        await HostService.registerHost(
          name: name,
          email: email,
          phone: formattedPhone,
          password: password,
          location: '$city, $state',
          city: city,
          state: state,
          country: country,
        );
      } catch (_) {}
    } else if (selectedRole.toLowerCase() == 'driver') {
      try {
        await DriverService.registerDriver(
          name: name,
          email: email,
          phone: formattedPhone,
          password: password,
          location: '$city, $state',
          city: city,
          state: state,
          country: country,
        );
      } catch (_) {}
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final cleanDigits = formattedPhone.replaceAll(RegExp(r'[^0-9]'), '');
      await prefs.setString('user_role_$cleanDigits', selectedRole.toLowerCase());
      await prefs.setString('last_registered_role', selectedRole.toLowerCase());
      await prefs.setString('currentUserRole', selectedRole.toLowerCase());
      await prefs.setString('currentUserName', name);
      await prefs.setString('currentPhone', formattedPhone);
      final token = regResult['token'] ?? (regResult['data'] is Map ? regResult['data']['token'] : null);
      if (token != null) {
        await prefs.setString('authToken', token.toString());
      }
    } catch (_) {}

    // Call Login Init to trigger OTP
    final loginInitResult = await AuthService.loginInitMobile(
      phone: formattedPhone,
      password: password,
    );

    setState(() {
      _isLoading = false;
    });

    final otp = (loginInitResult['otp'] ?? (loginInitResult['data'] is Map ? loginInitResult['data']['otp'] : null))?.toString() ??
        '123456';

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.vpn_key_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Registration Successful! OTP: $otp',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          phoneNumber: formattedPhone,
          expectedOtp: otp,
          isExistingUser: false,
          isRegistrationFlow: true,
          userName: name,
          userRole: selectedRole,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.inputBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          ),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
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
                  const Text(
                    'Join Zaatra Today!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Fill in your details below to register your account',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildRequiredLabel('Select Role'),
                  const SizedBox(height: 10),
                  Row(
                    children: _roles.map((r) {
                      final isSelected = _selectedRole == r['role'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRole = r['role'] as String;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  r['icon'] as IconData,
                                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  size: 24,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  r['label'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _buildRequiredLabel('Full Name'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      fillColor: AppColors.inputBackground,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRequiredLabel('Phone Number'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
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
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRequiredLabel('Email Address'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'name@example.com',
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      fillColor: AppColors.inputBackground,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRequiredLabel('Password'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Enter password (e.g. Zaatra@123)',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      fillColor: AppColors.inputBackground,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 🛡️ Live Password Criteria Helper
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Password must contain:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        _buildCriteriaRow('At least 6 characters', _passwordController.text.length >= 6),
                        _buildCriteriaRow('At least 1 uppercase letter (A-Z)', RegExp(r'[A-Z]').hasMatch(_passwordController.text)),
                        _buildCriteriaRow('At least 1 number (0-9)', RegExp(r'[0-9]').hasMatch(_passwordController.text)),
                        _buildCriteriaRow('At least 1 special character (!@#\$%...)', RegExp(r'[!@#\$%^&*()_\-+=\[\]{}|;:,.<>?/~`]').hasMatch(_passwordController.text)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildRequiredLabel('Re-enter Password'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Re-enter identical password',
                      prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppColors.textSecondary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      fillColor: AppColors.inputBackground,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  if (_confirmPasswordController.text.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          _confirmPasswordController.text == _passwordController.text
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 14,
                          color: _confirmPasswordController.text == _passwordController.text
                              ? const Color(0xFF2E7D32)
                              : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _confirmPasswordController.text == _passwordController.text
                              ? 'Passwords match'
                              : 'Passwords do not match',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _confirmPasswordController.text == _passwordController.text
                                ? const Color(0xFF2E7D32)
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRequiredLabel('City'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _cityController,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: 'Mumbai',
                                prefixIcon: const Icon(Icons.location_city_rounded, color: AppColors.textSecondary),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                fillColor: AppColors.inputBackground,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRequiredLabel('State'),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _showStatePicker(context),
                              child: AbsorbPointer(
                                child: TextField(
                                  controller: _stateController,
                                  readOnly: true,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    hintText: 'Select State',
                                    prefixIcon: const Icon(Icons.map_outlined, color: AppColors.textSecondary),
                                    suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                    fillColor: AppColors.inputBackground,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: AppColors.border),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: AppColors.border),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRequiredLabel('Country'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _countryController,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'India',
                      prefixIcon: const Icon(Icons.public_rounded, color: AppColors.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      fillColor: AppColors.inputBackground,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Register Account',
                    isLoading: _isLoading,
                    onPressed: _handleRegistration,
                  ),
                  const SizedBox(height: 16),
                  Row(
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
                        onTap: () => Navigator.pop(context),
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _indianStatesAndUTs = [
    'Andaman and Nicobar Islands',
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chandigarh',
    'Chhattisgarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jammu and Kashmir',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Ladakh',
    'Lakshadweep',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Puducherry',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  void _showStatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredStates = _indianStatesAndUTs.where((state) {
              if (searchQuery.trim().isEmpty) return true;
              final q = searchQuery.trim().toLowerCase();
              final s = state.toLowerCase();
              return s.startsWith(q) || s.contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: EdgeInsets.only(
                top: 16,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Indian State / UT',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    autofocus: true,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Type letter to filter (e.g. T, M, K...)',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () => setModalState(() => searchQuery = ''),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      fillColor: AppColors.inputBackground,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        searchQuery = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${filteredStates.length} states found',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: AppColors.border),
                  Expanded(
                    child: filteredStates.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 10),
                                Text(
                                  'No state starting with "$searchQuery"',
                                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: filteredStates.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                            itemBuilder: (context, index) {
                              final stateName = filteredStates[index];
                              final isSelected = _stateController.text.trim().toLowerCase() == stateName.toLowerCase();

                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                leading: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : AppColors.inputBackground,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      stateName[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  stateName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                                    : const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.border, size: 14),
                                onTap: () {
                                  setState(() {
                                    _stateController.text = stateName;
                                  });
                                  Navigator.pop(modalContext);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCriteriaRow(String label, bool isSatisfied) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isSatisfied ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 14,
            color: isSatisfied ? const Color(0xFF2E7D32) : AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSatisfied ? FontWeight.bold : FontWeight.normal,
              color: isSatisfied ? const Color(0xFF2E7D32) : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
