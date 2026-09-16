import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/driver_service.dart';
import '../auth/login_screen_115.dart';
import 'driver_edit_profile_screen.dart';
import 'driver_notification_screen_85.dart';
import 'driver_ratings_screen_83.dart';

class DriverProfileSettingsScreen extends StatefulWidget {
  const DriverProfileSettingsScreen({super.key});

  @override
  State<DriverProfileSettingsScreen> createState() => _DriverProfileSettingsScreenState();
}

class _DriverProfileSettingsScreenState extends State<DriverProfileSettingsScreen> {
  String _driverName = '-';
  String _driverPhone = '-';
  String _driverEmail = '-';
  String _rating = '-';
  String _vehicleName = '-';
  String _vehicleMake = '-';
  String _vehicleModel = '-';
  String _vehicleType = '-';
  String _vehiclePlate = '-';
  String _fuelType = '-';
  String _licenseNumber = '-';
  String _licenseType = '-';
  String _licenseValidity = '-';
  String _licenseStatus = 'Verified ✅';
  String _accountHolder = '-';
  String _bankName = '-';
  String _accountNumber = '-';
  String _ifscCode = '-';
  String _payoutStatus = 'Instant Transfer Enabled';
  String _city = '-';
  String _statusText = 'Active & Approved ✅';
  Uint8List? _avatarBytes;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentPhone = prefs.getString('currentPhone') ?? '';
      final cleanDigits = currentPhone.replaceAll(RegExp(r'[^0-9]'), '');

      if (currentPhone.isNotEmpty) {
        _driverPhone = currentPhone;
      }
      final savedName = prefs.getString('user_name_$cleanDigits') ?? prefs.getString('currentUserName') ?? '';
      if (savedName.isNotEmpty) {
        _driverName = savedName;
        _accountHolder = savedName;
      }

      final savedAvatar = prefs.getString('driver_avatar_base64_$cleanDigits');
      if (savedAvatar != null && savedAvatar.isNotEmpty) {
        try {
          _avatarBytes = base64Decode(savedAvatar);
        } catch (_) {}
      }

      _vehicleName = prefs.getString('driver_vehicle_$cleanDigits') ?? 
                     prefs.getString('driver_vehicle_name_$cleanDigits') ?? '-';
      _vehicleMake = prefs.getString('driver_vehicle_make_$cleanDigits') ?? '-';
      _vehicleModel = prefs.getString('driver_vehicle_model_$cleanDigits') ?? '-';
      _vehicleType = prefs.getString('driver_vehicle_type_$cleanDigits') ?? '-';
      _vehiclePlate = prefs.getString('driver_vehicle_plate_$cleanDigits') ?? '-';
      _fuelType = prefs.getString('driver_vehicle_fuel_$cleanDigits') ?? '-';
      _licenseNumber = prefs.getString('driver_license_$cleanDigits') ?? '-';
      _city = prefs.getString('driver_city_$cleanDigits') ?? '-';

      // 1. Fetch live Personal Info (GET /api/drivers/profile/personal)
      try {
        final personalRes = await DriverService.getPersonalInfo(phone: currentPhone);
        if (personalRes['success'] == true) {
          final p = personalRes['personalInformation'] ?? personalRes['data'] ?? personalRes;
          if (p is Map) {
            if (p['fullName'] != null && p['fullName'].toString().isNotEmpty) {
              _driverName = p['fullName'].toString();
              _accountHolder = _driverName;
            }
            if (p['phoneNumber'] != null && p['phoneNumber'].toString().isNotEmpty) {
              _driverPhone = p['phoneNumber'].toString();
            }
            if (p['email'] != null && p['email'].toString().isNotEmpty) {
              _driverEmail = p['email'].toString();
            }
            if (p['city'] != null && p['city'].toString().isNotEmpty) {
              _city = p['city'].toString();
            }
            if (p['status'] != null) {
              _statusText = p['status'].toString();
            }
          }
        }
      } catch (_) {}

      // 2. Fetch live Vehicle Info (GET /api/drivers/profile/vehicle)
      try {
        final vehRes = await DriverService.getVehicleInfo(phone: currentPhone);
        if (vehRes['success'] == true) {
          final v = vehRes['vehicleInformation'] ?? vehRes['data'] ?? vehRes;
          if (v is Map) {
            if (v['vehicleName'] != null) _vehicleName = v['vehicleName'].toString();
            if (v['vehicleMake'] != null) _vehicleMake = v['vehicleMake'].toString();
            if (v['vehicleModel'] != null) _vehicleModel = v['vehicleModel'].toString();
            if (v['vehicleType'] != null) _vehicleType = v['vehicleType'].toString();
            if (v['vehicleNumberPlate'] != null) _vehiclePlate = v['vehicleNumberPlate'].toString();
            if (v['fuelType'] != null) _fuelType = v['fuelType'].toString();
          }
        }
      } catch (_) {}

      // 3. Fetch live Driving License (GET /api/drivers/profile/license)
      try {
        final licRes = await DriverService.getDrivingLicenseInfo(phone: currentPhone);
        if (licRes['success'] == true) {
          final l = licRes['licenseInformation'] ?? licRes['data'] ?? licRes;
          if (l is Map) {
            if (l['licenseNumber'] != null) _licenseNumber = l['licenseNumber'].toString();
            if (l['licenseType'] != null) _licenseType = l['licenseType'].toString();
            if (l['validity'] != null) _licenseValidity = l['validity'].toString();
            if (l['status'] != null) _licenseStatus = l['status'].toString();
          }
        }
      } catch (_) {}

      // 4. Fetch live Bank Account (GET /api/drivers/profile/bank)
      try {
        final bankRes = await DriverService.getBankAccountInfo(phone: currentPhone);
        if (bankRes['success'] == true) {
          final b = bankRes['bankInformation'] ?? bankRes['data'] ?? bankRes;
          if (b is Map) {
            if (b['accountHolder'] != null) _accountHolder = b['accountHolder'].toString();
            if (b['bankName'] != null) _bankName = b['bankName'].toString();
            if (b['accountNumber'] != null) _accountNumber = b['accountNumber'].toString();
            if (b['ifscCode'] != null) _ifscCode = b['ifscCode'].toString();
            if (b['payoutStatus'] != null) _payoutStatus = b['payoutStatus'].toString();
          }
        }
      } catch (_) {}

      // 5. Fetch live Dashboard Summary (GET /api/drivers/dashboard-summary)
      try {
        final summary = await DriverService.getDashboardSummary();
        if (summary['success'] == true) {
          if (summary['driverProfile'] is Map) {
            final p = summary['driverProfile'] as Map;
            if (p['name'] != null && p['name'].toString().isNotEmpty) {
              _driverName = p['name'].toString();
            }
            if (p['email'] != null && p['email'].toString().isNotEmpty) {
              _driverEmail = p['email'].toString();
            }
            if (p['phone'] != null && p['phone'].toString().isNotEmpty) {
              _driverPhone = p['phone'].toString();
            }
          }
          if (summary['stats'] is Map && summary['stats']['ratings'] != null) {
            _rating = summary['stats']['ratings'].toString();
          }
        }
      } catch (_) {}

      // 6. Fetch driver approval status if available
      try {
        final status = await DriverService.getDriverApprovalStatus(phone: currentPhone);
        if (status['success'] == true && status['driver'] is Map) {
          final d = status['driver'] as Map;
          if (d['name'] != null && d['name'].toString().isNotEmpty) {
            _driverName = d['name'].toString();
          }
          if (d['vehicle'] != null) _vehicleName = d['vehicle'].toString();
          if (d['vehicleMake'] != null) _vehicleMake = d['vehicleMake'].toString();
          if (d['vehicleModel'] != null) _vehicleModel = d['vehicleModel'].toString();
          if (d['vehicleType'] != null) _vehicleType = d['vehicleType'].toString();
          if (d['vehicleNumberPlate'] != null) _vehiclePlate = d['vehicleNumberPlate'].toString();
          if (d['fuelType'] != null || d['vehicleFuelType'] != null) {
            _fuelType = (d['fuelType'] ?? d['vehicleFuelType']).toString();
          }
        }
      } catch (_) {}

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
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

  Widget _buildModalField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? hint,
    String? prefixText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: readOnly ? AppColors.textSecondary : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: readOnly ? AppColors.textMuted : AppColors.primary, size: 20),
              prefixText: prefixText,
              prefixStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              filled: true,
              fillColor: readOnly ? Colors.grey.shade100 : AppColors.inputBackground,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Personal Information Modal (View | Edit)
  void _showPersonalInfoModal() {
    final nameCtrl = TextEditingController(text: _driverName);
    final cleanDigits = _driverPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final tenDigits = cleanDigits.length >= 10 ? cleanDigits.substring(cleanDigits.length - 10) : cleanDigits;
    final phoneCtrl = TextEditingController(text: tenDigits);
    final emailCtrl = TextEditingController(text: _driverEmail);
    final cityCtrl = TextEditingController(text: _city);
    bool isEditing = false;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            isEditing ? 'Edit Personal Information' : 'Personal Information',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ),
                        if (isEditing)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Edit Mode', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (!isEditing) ...[
                      _buildModalField('Full Name', _driverName),
                      _buildModalField('Phone Number', _driverPhone),
                      _buildModalField('Email', _driverEmail),
                      _buildModalField('Status', _statusText),
                      _buildModalField('City', _city),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Close', style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setModalState(() => isEditing = true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                                  SizedBox(width: 6),
                                  Text('Edit', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _buildModalTextField(label: 'Full Name', controller: nameCtrl, icon: Icons.person_outline_rounded),
                      _buildModalTextField(label: 'Phone Number', controller: phoneCtrl, icon: Icons.phone_outlined, keyboardType: TextInputType.phone, prefixText: '+91 '),
                      _buildModalTextField(label: 'Email Address', controller: emailCtrl, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                      _buildModalTextField(label: 'Operating City / State', controller: cityCtrl, icon: Icons.location_city_rounded),
                      _buildModalTextField(label: 'Status (Backend-Managed)', controller: TextEditingController(text: _statusText), icon: Icons.lock_outline_rounded, readOnly: true),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSubmitting ? null : () => setModalState(() => isEditing = false),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      final name = nameCtrl.text.trim();
                                      final phone = phoneCtrl.text.trim();
                                      final email = emailCtrl.text.trim();
                                      final city = cityCtrl.text.trim();

                                      if (name.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please enter your full name.'), backgroundColor: Colors.redAccent),
                                        );
                                        return;
                                      }
                                      if (phone.isNotEmpty && (phone.length < 10 || !RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone))) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please enter a valid 10-digit phone number.'), backgroundColor: Colors.redAccent),
                                        );
                                        return;
                                      }
                                      if (email.isNotEmpty && (!email.contains('@') || !email.contains('.'))) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please enter a valid email address.'), backgroundColor: Colors.redAccent),
                                        );
                                        return;
                                      }

                                      setModalState(() => isSubmitting = true);
                                      final res = await DriverService.updatePersonalInfo(
                                        fullName: name,
                                        phoneNumber: '+91$phone',
                                        email: email,
                                        city: city,
                                        location: city,
                                      );
                                      setModalState(() => isSubmitting = false);

                                      if (res['success'] == true) {
                                        setState(() {
                                          _driverName = name;
                                          _driverPhone = '+91$phone';
                                          _driverEmail = email;
                                          _city = city;
                                          _accountHolder = name;
                                        });

                                        final prefs = await SharedPreferences.getInstance();
                                        final cd = phone.replaceAll(RegExp(r'[^0-9]'), '');
                                        await prefs.setString('user_name_$cd', name);
                                        await prefs.setString('currentUserName', name);
                                        await prefs.setString('driver_name_$cd', name);
                                        await prefs.setString('driver_email_$cd', email);
                                        await prefs.setString('driver_city_$cd', city);
                                        await prefs.setString('currentPhone', '+91$phone');

                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Personal Information updated successfully! 🎉'),
                                            backgroundColor: AppColors.success,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        setModalState(() => isEditing = false);
                                      } else {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(res['message']?.toString() ?? 'Failed to update personal information.'),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_rounded, color: Colors.white, size: 18),
                                        SizedBox(width: 6),
                                        Text('Done', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 2. Vehicle Information Modal (View | Edit)
  void _showVehicleInfoModal() {
    final nameCtrl = TextEditingController(text: _vehicleName);
    final makeCtrl = TextEditingController(text: _vehicleMake);
    final modelCtrl = TextEditingController(text: _vehicleModel);
    final typeCtrl = TextEditingController(text: _vehicleType);
    final plateCtrl = TextEditingController(text: _vehiclePlate);
    final fuelCtrl = TextEditingController(text: _fuelType);
    bool isEditing = false;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            isEditing ? 'Edit Vehicle Information' : 'Vehicle Information',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ),
                        if (isEditing)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Edit Mode', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (!isEditing) ...[
                      _buildModalField('Vehicle Name', _vehicleName),
                      _buildModalField('Make / Brand', _vehicleMake),
                      _buildModalField('Model', _vehicleModel),
                      _buildModalField('Type', _vehicleType),
                      _buildModalField('Number Plate', _vehiclePlate),
                      _buildModalField('Fuel Type', _fuelType),
                      _buildModalField('Capacity', '6 Seater MPV'),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Close', style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setModalState(() => isEditing = true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                                  SizedBox(width: 6),
                                  Text('Edit', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _buildModalTextField(label: 'Vehicle Name', controller: nameCtrl, icon: Icons.directions_car_rounded),
                      _buildModalTextField(label: 'Make / Brand', controller: makeCtrl, icon: Icons.branding_watermark_rounded),
                      _buildModalTextField(label: 'Model', controller: modelCtrl, icon: Icons.car_repair_rounded),
                      _buildModalTextField(label: 'Vehicle Type', controller: typeCtrl, icon: Icons.category_rounded, hint: 'MPV / Sedan / SUV'),
                      _buildModalTextField(label: 'Number Plate', controller: plateCtrl, icon: Icons.badge_outlined),
                      _buildModalTextField(label: 'Fuel Type', controller: fuelCtrl, icon: Icons.local_gas_station_rounded, hint: 'Diesel / Petrol / CNG / EV'),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSubmitting ? null : () => setModalState(() => isEditing = false),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      final vName = nameCtrl.text.trim();
                                      final vMake = makeCtrl.text.trim();
                                      final vModel = modelCtrl.text.trim();
                                      final vType = typeCtrl.text.trim();
                                      final vPlate = plateCtrl.text.trim();
                                      final vFuel = fuelCtrl.text.trim();

                                      if (vName.isEmpty && vPlate.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please enter vehicle details.'), backgroundColor: Colors.redAccent),
                                        );
                                        return;
                                      }

                                      String normalizedFuel = vFuel;
                                      if (vFuel.isNotEmpty) {
                                        final lowerFuel = vFuel.toLowerCase();
                                        if (lowerFuel.contains('petrol')) {
                                          normalizedFuel = 'Petrol';
                                        } else if (lowerFuel.contains('diesel')) {
                                          normalizedFuel = 'Diesel';
                                        } else if (lowerFuel.contains('cng')) {
                                          normalizedFuel = 'CNG';
                                        } else if (lowerFuel.contains('elec') || lowerFuel.contains('ev')) {
                                          normalizedFuel = 'Electric';
                                        } else if (lowerFuel.contains('hyb')) {
                                          normalizedFuel = 'Hybrid';
                                        } else {
                                          normalizedFuel = 'Petrol';
                                        }
                                      }

                                      setModalState(() => isSubmitting = true);
                                      final res = await DriverService.updateVehicleInfo(
                                        vehicleName: vName.isNotEmpty ? vName : null,
                                        vehicleMake: vMake.isNotEmpty ? vMake : null,
                                        vehicleModel: vModel.isNotEmpty ? vModel : null,
                                        vehicleType: vType.isNotEmpty ? vType : null,
                                        vehicleNumberPlate: vPlate.isNotEmpty ? vPlate : null,
                                        fuelType: normalizedFuel.isNotEmpty ? normalizedFuel : null,
                                      );
                                      setModalState(() => isSubmitting = false);

                                      if (res['success'] == true) {
                                        setState(() {
                                          if (vName.isNotEmpty) _vehicleName = vName;
                                          if (vMake.isNotEmpty) _vehicleMake = vMake;
                                          if (vModel.isNotEmpty) _vehicleModel = vModel;
                                          if (vType.isNotEmpty) _vehicleType = vType;
                                          if (vPlate.isNotEmpty) _vehiclePlate = vPlate;
                                          if (normalizedFuel.isNotEmpty) _fuelType = normalizedFuel;
                                        });

                                        final cd = _driverPhone.replaceAll(RegExp(r'[^0-9]'), '');
                                        final prefs = await SharedPreferences.getInstance();
                                        if (vName.isNotEmpty) {
                                          await prefs.setString('driver_vehicle_$cd', vName);
                                          await prefs.setString('driver_vehicle_name_$cd', vName);
                                        }
                                        if (vMake.isNotEmpty) await prefs.setString('driver_vehicle_make_$cd', vMake);
                                        if (vModel.isNotEmpty) await prefs.setString('driver_vehicle_model_$cd', vModel);
                                        if (vType.isNotEmpty) await prefs.setString('driver_vehicle_type_$cd', vType);
                                        if (vPlate.isNotEmpty) await prefs.setString('driver_vehicle_plate_$cd', vPlate);
                                        if (normalizedFuel.isNotEmpty) await prefs.setString('driver_vehicle_fuel_$cd', normalizedFuel);

                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Vehicle Information updated successfully! 🎉'),
                                            backgroundColor: AppColors.success,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        setModalState(() => isEditing = false);
                                      } else {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(res['message']?.toString() ?? 'Failed to update vehicle information.'),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_rounded, color: Colors.white, size: 18),
                                        SizedBox(width: 6),
                                        Text('Done', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 3. Driving License Modal (View | Edit)
  void _showDrivingLicenseModal() {
    final numberCtrl = TextEditingController(text: _licenseNumber);
    final typeCtrl = TextEditingController(text: _licenseType);
    final validityCtrl = TextEditingController(text: _licenseValidity);
    bool isEditing = false;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.description_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            isEditing ? 'Edit Driving License' : 'Driving License',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ),
                        if (isEditing)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Edit Mode', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (!isEditing) ...[
                      _buildModalField('License Number', _licenseNumber),
                      _buildModalField('License Type', _licenseType),
                      _buildModalField('Validity', _licenseValidity),
                      _buildModalField('Status', _licenseStatus),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Close', style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setModalState(() => isEditing = true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                                  SizedBox(width: 6),
                                  Text('Edit', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _buildModalTextField(label: 'License Number', controller: numberCtrl, icon: Icons.description_outlined),
                      _buildModalTextField(label: 'License Type', controller: typeCtrl, icon: Icons.category_rounded, hint: 'Commercial & LMV'),
                      _buildModalTextField(label: 'Validity Date', controller: validityCtrl, icon: Icons.calendar_today_rounded, hint: 'e.g. 28 Dec 2032'),
                      _buildModalTextField(label: 'Status (Backend-Verified)', controller: TextEditingController(text: _licenseStatus), icon: Icons.lock_outline_rounded, readOnly: true),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSubmitting ? null : () => setModalState(() => isEditing = false),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      final num = numberCtrl.text.trim();
                                      final type = typeCtrl.text.trim();
                                      final val = validityCtrl.text.trim();

                                      if (num.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please enter your license number.'), backgroundColor: Colors.redAccent),
                                        );
                                        return;
                                      }

                                      setModalState(() => isSubmitting = true);
                                      final res = await DriverService.updateDrivingLicenseInfo(
                                        licenseNumber: num,
                                        licenseType: type.isNotEmpty ? type : null,
                                        validity: val.isNotEmpty ? val : null,
                                      );
                                      setModalState(() => isSubmitting = false);

                                      if (res['success'] == true) {
                                        setState(() {
                                          _licenseNumber = num;
                                          if (type.isNotEmpty) _licenseType = type;
                                          if (val.isNotEmpty) _licenseValidity = val;
                                        });

                                        final prefs = await SharedPreferences.getInstance();
                                        final cd = _driverPhone.replaceAll(RegExp(r'[^0-9]'), '');
                                        await prefs.setString('driver_license_$cd', num);

                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Driving License updated successfully! 🎉'),
                                            backgroundColor: AppColors.success,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        setModalState(() => isEditing = false);
                                      } else {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(res['message']?.toString() ?? 'Failed to update license information.'),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_rounded, color: Colors.white, size: 18),
                                        SizedBox(width: 6),
                                        Text('Done', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 4. Bank Account Modal (View | Edit)
  void _showBankAccountModal() {
    final holderCtrl = TextEditingController(text: _accountHolder);
    final bankCtrl = TextEditingController(text: _bankName);
    final numberCtrl = TextEditingController(text: _accountNumber);
    final ifscCtrl = TextEditingController(text: _ifscCode);
    bool isEditing = false;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            isEditing ? 'Edit Bank Account' : 'Bank Account & Payouts',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ),
                        if (isEditing)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Edit Mode', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (!isEditing) ...[
                      _buildModalField('Account Holder', _accountHolder),
                      _buildModalField('Bank Name', _bankName),
                      _buildModalField('Account Number', _accountNumber),
                      _buildModalField('IFSC Code', _ifscCode),
                      _buildModalField('Payout Status', _payoutStatus),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Close', style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setModalState(() => isEditing = true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                                  SizedBox(width: 6),
                                  Text('Edit', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _buildModalTextField(label: 'Account Holder Name', controller: holderCtrl, icon: Icons.person_outline_rounded),
                      _buildModalTextField(label: 'Bank Name', controller: bankCtrl, icon: Icons.account_balance_rounded),
                      _buildModalTextField(label: 'Account Number', controller: numberCtrl, icon: Icons.numbers_rounded, keyboardType: TextInputType.number),
                      _buildModalTextField(label: 'IFSC Code', controller: ifscCtrl, icon: Icons.qr_code_rounded),
                      _buildModalTextField(label: 'Payout Status (System-Managed)', controller: TextEditingController(text: _payoutStatus), icon: Icons.lock_outline_rounded, readOnly: true),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSubmitting ? null : () => setModalState(() => isEditing = false),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      final holder = holderCtrl.text.trim();
                                      final bank = bankCtrl.text.trim();
                                      final num = numberCtrl.text.trim();
                                      final ifsc = ifscCtrl.text.trim();

                                      if (holder.isEmpty || bank.isEmpty || num.isEmpty || ifsc.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please fill all bank details.'), backgroundColor: Colors.redAccent),
                                        );
                                        return;
                                      }

                                      setModalState(() => isSubmitting = true);
                                      final res = await DriverService.updateBankAccountInfo(
                                        accountHolder: holder,
                                        bankName: bank,
                                        accountNumber: num,
                                        ifscCode: ifsc,
                                      );
                                      setModalState(() => isSubmitting = false);

                                      if (res['success'] == true) {
                                        setState(() {
                                          _accountHolder = holder;
                                          _bankName = bank;
                                          _accountNumber = num;
                                          _ifscCode = ifsc;
                                        });

                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Bank Account details updated successfully! 🎉'),
                                            backgroundColor: AppColors.success,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        setModalState(() => isEditing = false);
                                      } else {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(res['message']?.toString() ?? 'Failed to update bank account details.'),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_rounded, color: Colors.white, size: 18),
                                        SizedBox(width: 6),
                                        Text('Done', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPassController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Current Password', prefixIcon: Icon(Icons.lock_outline_rounded)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPassController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'New Password', prefixIcon: Icon(Icons.lock_rounded)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPassController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.check_circle_outline_rounded)),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (currentPassController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter current password.'), backgroundColor: Colors.redAccent),
                            );
                            return;
                          }
                          if (newPassController.text.trim().length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('New password must be at least 6 characters.'), backgroundColor: Colors.redAccent),
                            );
                            return;
                          }
                          if (newPassController.text != confirmPassController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Passwords do not match!'), backgroundColor: Colors.redAccent),
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);
                          final res = await DriverService.changePassword(
                            currentPassword: currentPassController.text.trim(),
                            newPassword: newPassController.text.trim(),
                          );
                          setDialogState(() => isSubmitting = false);

                          if (ctx.mounted) Navigator.pop(ctx);
                          if (!mounted) return;

                          final success = res['success'] == true;
                          final msg = res['message']?.toString() ??
                              (success ? 'Password updated successfully!' : 'Failed to update password.');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(msg),
                              backgroundColor: success ? AppColors.success : Colors.redAccent,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Update', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;

      final ext = file.name.split('.').last.toLowerCase();
      if (ext != 'png' && ext != 'jpg' && ext != 'jpeg') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a PNG or JPEG image.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      final bytes = await file.readAsBytes();
      if (bytes.lengthInBytes > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image size must be under 5MB.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      setState(() => _avatarBytes = bytes);

      final prefs = await SharedPreferences.getInstance();
      final currentPhone = prefs.getString('currentPhone') ?? '+919876543210';
      final cleanDigits = currentPhone.replaceAll(RegExp(r'[^0-9]'), '');
      await prefs.setString('driver_avatar_base64_$cleanDigits', base64Encode(bytes));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully! 🎉'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(_driverName);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Driver Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Stack(
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
            child: Column(
              children: [
                // Header with Purple Background matching Image 2
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickAndUploadAvatar,
                        child: Stack(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withAlpha(200), width: 2),
                              ),
                              child: ClipOval(
                                child: _avatarBytes != null
                                    ? Image.memory(
                                        _avatarBytes!,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                      )
                                    : Center(
                                        child: Text(
                                          initials,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: AppColors.primary,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _driverName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _driverPhone,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DriverRatingsScreen()),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    _rating,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(40),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Verified Driver',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Settings Card Container matching Image 2
                Container(
                  transform: Matrix4.translationValues(0, -20, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        context,
                        icon: Icons.edit_note_rounded,
                        title: 'Edit Profile',
                        onTap: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriverEditProfileScreen(
                                initialName: _driverName,
                                initialPhone: _driverPhone,
                                initialEmail: _driverEmail,
                                initialVehicle: _vehicleName,
                                initialPlate: _vehiclePlate,
                              ),
                            ),
                          );
                          if (updated == true) _loadProfileData();
                        },
                      ),
                      const Divider(height: 24, color: AppColors.border),
                      _buildSettingsItem(
                        context,
                        icon: Icons.person_outline_rounded,
                        title: 'Personal Information',
                        onTap: _showPersonalInfoModal,
                      ),
                      const Divider(height: 24, color: AppColors.border),
                      _buildSettingsItem(
                        context,
                        icon: Icons.directions_car_outlined,
                        title: 'Vehicle Information',
                        onTap: _showVehicleInfoModal,
                      ),
                      const Divider(height: 24, color: AppColors.border),
                      _buildSettingsItem(
                        context,
                        icon: Icons.description_outlined,
                        title: 'Driving License',
                        onTap: _showDrivingLicenseModal,
                      ),
                      const Divider(height: 24, color: AppColors.border),
                      _buildSettingsItem(
                        context,
                        icon: Icons.badge_outlined,
                        title: 'Bank Account',
                        onTap: _showBankAccountModal,
                      ),
                      const Divider(height: 24, color: AppColors.border),
                      _buildSettingsItem(
                        context,
                        icon: Icons.notifications_none_rounded,
                        title: 'Notification Setting',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DriverNotificationScreen()),
                          );
                        },
                      ),
                      const Divider(height: 24, color: AppColors.border),
                      _buildSettingsItem(
                        context,
                        icon: Icons.lock_outline_rounded,
                        title: 'Change Password',
                        onTap: _showChangePasswordDialog,
                      ),
                      const Divider(height: 24, color: AppColors.border),
                      _buildSettingsItem(
                        context,
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        isLogout: true,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('Confirm Logout'),
                              content: const Text('Are you sure you want to log out of your driver account?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                  child: const Text('Logout', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );

                          if (confirm != true) return;

                          await AuthService.logout();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logged Out Successfully.'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen(isExistingUser: true)),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Footer Version Tag matching Image 2
                const Text(
                  'App Version 2.5.0',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening $title...')),
            );
          },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout ? Colors.redAccent : AppColors.textPrimary,
              size: 22,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isLogout ? Colors.redAccent : AppColors.textPrimary,
                ),
              ),
            ),
            if (!isLogout)
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}
