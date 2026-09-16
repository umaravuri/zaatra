import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/driver_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'application_submitted_screen_23.dart';

class DriverVehicleInfoScreen extends StatefulWidget {
  final String role;
  final Map<String, dynamic>? driverData;

  const DriverVehicleInfoScreen({
    super.key,
    this.role = 'Driver',
    this.driverData,
  });

  @override
  State<DriverVehicleInfoScreen> createState() => _DriverVehicleInfoScreenState();
}

class _DriverVehicleInfoScreenState extends State<DriverVehicleInfoScreen> {
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _typeController = TextEditingController();
  final _yearController = TextEditingController();
  final _fuelTypeController = TextEditingController();
  final _colorController = TextEditingController();
  final _numberPlateController = TextEditingController();

  final _picker = ImagePicker();
  bool _vehiclePhotoUploaded = false;
  String _vehiclePhotoFileName = '';
  String _vehiclePhotoFileSize = '';

  bool _isLoading = false;

  Future<void> _pickVehiclePhoto() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (file != null) {
        final length = await file.length();
        final sizeKb = (length / 1024).toStringAsFixed(1);
        final sizeStr = length > 1024 * 1024
            ? '${(length / (1024 * 1024)).toStringAsFixed(1)} MB'
            : '$sizeKb KB';

        setState(() {
          _vehiclePhotoFileName = file.name;
          _vehiclePhotoFileSize = sizeStr;
          _vehiclePhotoUploaded = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${file.name} uploaded successfully! ($sizeStr)'),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selection error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submitApplication() async {
    final vehicleMake = _makeController.text.trim();
    final vehicleModel = _modelController.text.trim();
    final vehicleType = _typeController.text.trim();
    final vehicleYear = _yearController.text.trim();
    final vehicleFuelType = _fuelTypeController.text.trim();
    final vehicleColor = _colorController.text.trim();
    final vehicleNumberPlate = _numberPlateController.text.trim();

    if (vehicleMake.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Vehicle Make (e.g. Maruti Suzuki, Kia).'), backgroundColor: Colors.red),
      );
      return;
    }
    if (vehicleModel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Vehicle Model (e.g. Swift Dzire, Carens).'), backgroundColor: Colors.red),
      );
      return;
    }
    if (vehicleType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Vehicle Type (e.g. Sedan, SUV, MPV).'), backgroundColor: Colors.red),
      );
      return;
    }
    if (vehicleYear.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Vehicle Year (e.g. 2023, 2024).'), backgroundColor: Colors.red),
      );
      return;
    }
    if (vehicleFuelType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Fuel Type (e.g. Petrol, Diesel, EV).'), backgroundColor: Colors.red),
      );
      return;
    }
    if (vehicleColor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Vehicle Color (e.g. White, Grey, Black).'), backgroundColor: Colors.red),
      );
      return;
    }
    if (vehicleNumberPlate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Vehicle Numberplate (e.g. KA 05 MN 4321).'), backgroundColor: Colors.red),
      );
      return;
    }
    if (!_vehiclePhotoUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload Vehicle Photos (PNG/JPG < 3MB).'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = await AuthService.getCurrentUser();
    final prefs = await SharedPreferences.getInstance();
    final currentPhone = prefs.getString('currentPhone') ?? '';
    final cleanPhone = currentPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final savedName = prefs.getString('user_name_$cleanPhone') ?? prefs.getString('currentUserName') ?? '';

    final name = widget.driverData?['name'] ?? (user != null ? user['name']?.toString() : null) ?? (savedName.isNotEmpty ? savedName : 'Driver');
    final email = widget.driverData?['email'] ?? (user != null ? user['email']?.toString() : null) ?? 'driver@zaatra.com';
    final phone = widget.driverData?['phone'] ?? (user != null ? user['phone']?.toString() : null) ?? (currentPhone.isNotEmpty ? currentPhone : '+919876511223');
    final password = widget.driverData?['password'] ?? 'DriverSecretPassword123';
    final city = widget.driverData?['city'] ?? (user != null ? user['city']?.toString() : null) ?? 'Hyderabad';
    final state = widget.driverData?['state'] ?? (user != null ? user['state']?.toString() : null) ?? 'Telangana';
    final location = widget.driverData?['location'] ?? (user != null ? user['location']?.toString() : null) ?? '$city, $state';
    final country = widget.driverData?['country'] ?? 'India';
    final drivingLicenseNumber = widget.driverData?['drivingLicenseNumber'] ?? '';
    final drivingLicenseDocument = widget.driverData?['drivingLicenseDocument'] ?? '';
    final rcDocument = widget.driverData?['rcDocument'] ?? '';
    final pollutionDocument = widget.driverData?['pollutionDocument'] ?? '';
    final driverPhoto = widget.driverData?['driverPhoto'] ?? '';

    final vehicle = '$vehicleMake $vehicleModel';
    final carImage = '/uploads/$_vehiclePhotoFileName';
    final carImages = [carImage];

    // 🚀 1. Call Backend Driver Registration API (POST /api/drivers/register)
    await DriverService.registerDriver(
      name: name,
      email: email,
      phone: phone,
      password: password,
      location: location,
      city: city,
      state: state,
      country: country,
      drivingLicenseNumber: drivingLicenseNumber,
      drivingLicenseDocument: drivingLicenseDocument,
      driverPhoto: driverPhoto,
    );

    // Normalize fuelType to match backend enum ["Diesel", "Petrol", "Electric", "CNG", "Hybrid"]
    String normalizedFuel = 'Diesel';
    final lowerFuel = vehicleFuelType.toLowerCase();
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
    }

    // 🚀 2. Call Backend Driver & Vehicle Onboarding API (POST /api/drivers/onboarding)
    await DriverService.onboardDriverVehicle(
      name: name,
      email: email,
      phone: phone,
      location: location,
      vehicle: vehicle,
      vehicleMake: vehicleMake,
      vehicleModel: vehicleModel,
      vehicleType: vehicleType,
      vehicleYear: vehicleYear,
      fuelType: normalizedFuel,
      vehicleFuelType: normalizedFuel,
      vehicleNumberPlate: vehicleNumberPlate,
      vehicleColor: vehicleColor,
      carImage: carImage,
      carImages: carImages,
      vehiclePhotos: carImage,
      drivingLicenseNumber: drivingLicenseNumber,
      drivingLicenseDocument: drivingLicenseDocument,
      rcDocument: rcDocument,
      pollutionDocument: pollutionDocument,
      driverPhoto: driverPhoto,
    );

    // Store vehicle details locally in SharedPreferences for seamless Post Ride flow
    await prefs.setString('driver_vehicle_$cleanPhone', vehicle);
    await prefs.setString('driver_vehicle_name_$cleanPhone', vehicle);
    await prefs.setString('driver_vehicle_make_$cleanPhone', vehicleMake);
    await prefs.setString('driver_vehicle_model_$cleanPhone', vehicleModel);
    await prefs.setString('driver_vehicle_type_$cleanPhone', vehicleType);
    await prefs.setString('driver_vehicle_plate_$cleanPhone', vehicleNumberPlate);
    await prefs.setString('driver_vehicle_fuel_$cleanPhone', normalizedFuel);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver registered & application submitted successfully!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ApplicationSubmittedScreen(role: widget.role, driverPhone: phone),
        ),
      );
    }
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
                  // Progress Bar (Step 3 of 3)
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 1.0,
                            minHeight: 6,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Step 3 of 3',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Screen 35 Header matching Figma
                  const Text(
                    'Vehicle Information',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tell us about your vehicle',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 28),

                  // 1. Vehicle Make
                  CustomTextField(
                    label: 'Vehicle Make',
                    hint: 'e.g. Maruti Suzuki, Hyundai, Tata',
                    controller: _makeController,
                    prefixIcon: Icons.business_rounded,
                  ),

                  const SizedBox(height: 18),

                  // 2. Vehicle Model
                  CustomTextField(
                    label: 'Vehicle Model',
                    hint: 'e.g. Swift Dzire, Creta, Nexon',
                    controller: _modelController,
                    prefixIcon: Icons.time_to_leave_rounded,
                  ),

                  const SizedBox(height: 18),

                  // 3. Vehicle Type
                  CustomTextField(
                    label: 'Vehicle Type',
                    hint: 'e.g. Sedan, SUV, Hatchback',
                    controller: _typeController,
                    prefixIcon: Icons.directions_car_rounded,
                  ),

                  const SizedBox(height: 18),

                  // 4. Vehicle Year
                  CustomTextField(
                    label: 'Vehicle Year',
                    hint: 'e.g. 2023, 2024',
                    controller: _yearController,
                    prefixIcon: Icons.calendar_today_rounded,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 18),

                  // 5. Fuel Type
                  CustomTextField(
                    label: 'Fuel Type',
                    hint: 'e.g. Petrol, Diesel, CNG, Electric',
                    controller: _fuelTypeController,
                    prefixIcon: Icons.local_gas_station_rounded,
                  ),

                  const SizedBox(height: 18),

                  // 6. Vehicle Color
                  CustomTextField(
                    label: 'Vehicle Color',
                    hint: 'e.g. White, Silver, Grey, Black',
                    controller: _colorController,
                    prefixIcon: Icons.palette_outlined,
                  ),

                  const SizedBox(height: 18),

                  // 7. Vehicle Numberplate
                  CustomTextField(
                    label: 'Vehicle Numberplate',
                    hint: 'e.g. KA 05 MN 4321, TS 09 AB 1234',
                    controller: _numberPlateController,
                    prefixIcon: Icons.pin_outlined,
                  ),

                  const SizedBox(height: 20),

                  // 8. Vehicle Photos (PNG and JPEG under 3MB)
                  const Text(
                    'Vehicle Photos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildVehiclePhotoCard(),

                  const SizedBox(height: 36),

                  // Continue CTA Button matching Screen 35
                  CustomButton(
                    text: 'Continue',
                    isLoading: _isLoading,
                    onPressed: _submitApplication,
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

  Widget _buildVehiclePhotoCard() {
    return GestureDetector(
      onTap: _pickVehiclePhoto,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _vehiclePhotoUploaded ? AppColors.primary.withAlpha(80) : AppColors.border,
            width: _vehiclePhotoUploaded ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDF7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Vehicle Photos',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PNG/JPG < 3MB',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _vehiclePhotoUploaded
                        ? '$_vehiclePhotoFileName ($_vehiclePhotoFileSize)'
                        : 'Tap to upload vehicle photo (PNG/JPEG under 3MB)',
                    style: TextStyle(
                      fontSize: 12,
                      color: _vehiclePhotoUploaded ? const Color(0xFF2E7D32) : AppColors.textSecondary,
                      fontWeight: _vehiclePhotoUploaded ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _vehiclePhotoUploaded ? const Color(0xFFE8F5E9) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _vehiclePhotoUploaded ? const Color(0xFF4CAF50) : AppColors.border,
                ),
              ),
              child: Icon(
                _vehiclePhotoUploaded ? Icons.check_rounded : Icons.upload_file_rounded,
                color: _vehiclePhotoUploaded ? const Color(0xFF2E7D32) : AppColors.textSecondary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
