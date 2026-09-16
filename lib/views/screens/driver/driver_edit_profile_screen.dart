import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/driver_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class DriverEditProfileScreen extends StatefulWidget {
  final String? initialName;
  final String? initialPhone;
  final String? initialEmail;
  final String? initialVehicle;
  final String? initialPlate;

  const DriverEditProfileScreen({
    super.key,
    this.initialName,
    this.initialPhone,
    this.initialEmail,
    this.initialVehicle,
    this.initialPlate,
  });

  @override
  State<DriverEditProfileScreen> createState() => _DriverEditProfileScreenState();
}

class _DriverEditProfileScreenState extends State<DriverEditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController(text: 'Hyderabad, Telangana');
  final _vehicleController = TextEditingController();
  final _plateController = TextEditingController();
  final _emergencyController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _vehicleController.dispose();
    _plateController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final currentPhone = prefs.getString('currentPhone') ?? '+919876543210';
    final cleanDigits = currentPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final tenDigits = cleanDigits.length >= 10 ? cleanDigits.substring(cleanDigits.length - 10) : cleanDigits;

    final savedName = prefs.getString('user_name_$cleanDigits') ?? prefs.getString('currentUserName') ?? '';
    final savedEmail = prefs.getString('driver_email_$cleanDigits') ?? '';
    final savedVehicle = prefs.getString('driver_vehicle_$cleanDigits') ?? 
                         prefs.getString('driver_vehicle_name_$cleanDigits') ?? '';
    final savedPlate = prefs.getString('driver_vehicle_plate_$cleanDigits') ?? '';
    final savedEmergency = prefs.getString('driver_emergency_$cleanDigits') ?? '';

    setState(() {
      _nameController.text = widget.initialName ?? savedName;
      _emailController.text = widget.initialEmail ?? savedEmail;
      _phoneController.text = tenDigits;
      _vehicleController.text = widget.initialVehicle ?? savedVehicle;
      _plateController.text = widget.initialPlate ?? savedPlate;
      _emergencyController.text = savedEmergency;
    });

    // Also attempt to load from live APIs
    try {
      final personalRes = await DriverService.getPersonalInfo(phone: currentPhone);
      if (personalRes['success'] == true) {
        final p = personalRes['personalInformation'] ?? personalRes['data'] ?? personalRes;
        if (p is Map && mounted) {
          setState(() {
            if (p['fullName'] != null && p['fullName'].toString().isNotEmpty) {
              _nameController.text = p['fullName'].toString();
            }
            if (p['email'] != null && p['email'].toString().isNotEmpty) {
              _emailController.text = p['email'].toString();
            }
            if (p['city'] != null && p['city'].toString().isNotEmpty) {
              _cityController.text = p['city'].toString();
            }
          });
        }
      }

      final vehRes = await DriverService.getVehicleInfo(phone: currentPhone);
      if (vehRes['success'] == true) {
        final v = vehRes['vehicleInformation'] ?? vehRes['data'] ?? vehRes;
        if (v is Map && mounted) {
          setState(() {
            if (v['vehicleName'] != null && v['vehicleName'].toString().isNotEmpty) {
              _vehicleController.text = v['vehicleName'].toString();
            }
            if (v['vehicleNumberPlate'] != null && v['vehicleNumberPlate'].toString().isNotEmpty) {
              _plateController.text = v['vehicleNumberPlate'].toString();
            }
          });
        }
      }

      final summary = await DriverService.getDashboardSummary();
      if (summary['success'] == true && summary['driverProfile'] is Map) {
        final p = summary['driverProfile'] as Map;
        if (mounted) {
          setState(() {
            if (p['name'] != null && p['name'].toString().isNotEmpty) {
              _nameController.text = p['name'].toString();
            }
            if (p['email'] != null && p['email'].toString().isNotEmpty) {
              _emailController.text = p['email'].toString();
            }
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final city = _cityController.text.trim();
    final vehicle = _vehicleController.text.trim();
    final plate = _plateController.text.trim();
    final emergency = _emergencyController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (phone.isNotEmpty && (phone.length < 10 || !RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (email.isNotEmpty && (!email.contains('@') || !email.contains('.'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🚀 Call Backend PUT /drivers/profile/personal
      await DriverService.updatePersonalInfo(
        fullName: name,
        phoneNumber: '+91$phone',
        email: email,
        city: city,
        location: city,
      );

      // 🚀 Call Backend PUT /drivers/profile/vehicle
      if (vehicle.isNotEmpty || plate.isNotEmpty) {
        await DriverService.updateVehicleInfo(
          vehicleName: vehicle.isNotEmpty ? vehicle : null,
          vehicleNumberPlate: plate.isNotEmpty ? plate : null,
        );
      }

      // Persist to local storage fallback
      final prefs = await SharedPreferences.getInstance();
      final cleanDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');

      await prefs.setString('user_name_$cleanDigits', name);
      await prefs.setString('currentUserName', name);
      await prefs.setString('driver_name_$cleanDigits', name);
      await prefs.setString('driver_email_$cleanDigits', email);
      await prefs.setString('driver_city_$cleanDigits', city);
      await prefs.setString('currentPhone', '+91$phone');

      if (vehicle.isNotEmpty) {
        await prefs.setString('driver_vehicle_$cleanDigits', vehicle);
        await prefs.setString('driver_vehicle_name_$cleanDigits', vehicle);
      }
      if (plate.isNotEmpty) {
        await prefs.setString('driver_vehicle_plate_$cleanDigits', plate);
      }
      if (emergency.isNotEmpty) {
        await prefs.setString('driver_emergency_$cleanDigits', emergency);
      }

      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Driver Profile Updated Successfully! 🎉'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context, true);
      }
    }
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'Za';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(_nameController.text);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Driver Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with Camera Badge
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBackground,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withAlpha(50), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Personal Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline_rounded,
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Email Address',
                    hint: 'Enter your email address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 16),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Mobile Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
                        child: Text('+91 ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ),
                      fillColor: AppColors.inputBackground,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Operating City / State',
                    hint: 'Enter city and state',
                    controller: _cityController,
                    prefixIcon: Icons.location_city_rounded,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Vehicle Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: 'Vehicle Name / Model',
                    hint: 'e.g. Kia Carens',
                    controller: _vehicleController,
                    prefixIcon: Icons.directions_car_rounded,
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Vehicle Number Plate',
                    hint: 'e.g. AP40LM7890',
                    controller: _plateController,
                    prefixIcon: Icons.badge_outlined,
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Emergency Contact',
                    hint: 'Enter emergency contact number',
                    controller: _emergencyController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.contact_phone_outlined,
                  ),

                  const SizedBox(height: 32),

                  CustomButton(
                    text: 'Save Changes',
                    isLoading: _isLoading,
                    onPressed: _saveProfile,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
