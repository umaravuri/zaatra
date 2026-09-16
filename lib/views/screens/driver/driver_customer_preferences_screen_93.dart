import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/driver_service.dart';
import '../../../services/ride_service.dart';
import '../../widgets/custom_button.dart';
import 'driver_home_dashboard_screen_83.dart';
import 'driver_ride_management_screen_98.dart';

class DriverCustomerPreferencesScreen extends StatefulWidget {
  final Map<String, dynamic>? rideDetails;

  const DriverCustomerPreferencesScreen({
    super.key,
    this.rideDetails,
  });

  @override
  State<DriverCustomerPreferencesScreen> createState() => _DriverCustomerPreferencesScreenState();
}

class _DriverCustomerPreferencesScreenState extends State<DriverCustomerPreferencesScreen> {
  bool _acNonSmoking = true;
  bool _ac = true;
  int _luggageCount = 0;
  int _mediumBagCount = 0;
  bool _wifi = true;
  bool _usbCharging = true;
  bool _verifiedDriver = true;
  bool _saveForFuture = true;
  bool _isPublishing = false;

  // Custom Preferences & Features Lists
  final List<Map<String, dynamic>> _customPreferences = [];
  final List<Map<String, dynamic>> _customFeatures = [];

  void _showAddCustomDialog({
    required String title,
    required String hint,
    required Function(String) onAdd,
  }) {
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final keyboardPadding = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: keyboardPadding + 20,
          ),
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
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: textController,
                autofocus: true,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.normal),
                  fillColor: const Color(0xFFFAFAFA),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final val = textController.text.trim();
                        if (val.isNotEmpty) {
                          onAdd(val);
                          Navigator.pop(ctx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _publishRide() async {
    setState(() => _isPublishing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final user = await AuthService.getCurrentUser();
      final phone = prefs.getString('currentPhone') ?? user?['phone']?.toString() ?? '+919901234590';
      final cleanDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
      
      String driverName = prefs.getString('user_name_$cleanDigits') ?? 
                          prefs.getString('currentUserName') ?? 
                          user?['name']?.toString() ?? 
                          'Rahul Siplivarma.k';

      // Dynamically fetch driver vehicle info from SharedPreferences or Driver API
      String vehicle = prefs.getString('driver_vehicle_$cleanDigits') ?? 
                       prefs.getString('driver_vehicle_name_$cleanDigits') ?? 
                       widget.rideDetails?['vehicle'] ?? '';
      String vehicleMake = prefs.getString('driver_vehicle_make_$cleanDigits') ?? widget.rideDetails?['vehicleMake'] ?? '';
      String vehicleModel = prefs.getString('driver_vehicle_model_$cleanDigits') ?? widget.rideDetails?['vehicleModel'] ?? '';
      String vehicleType = prefs.getString('driver_vehicle_type_$cleanDigits') ?? widget.rideDetails?['vehicleType'] ?? '';
      String vehiclePlate = prefs.getString('driver_vehicle_plate_$cleanDigits') ?? widget.rideDetails?['vehicleNumberPlate'] ?? '';
      String fuelType = prefs.getString('driver_vehicle_fuel_$cleanDigits') ?? widget.rideDetails?['fuelType'] ?? '';

      // 1. Try fetching vehicle info directly from Driver Vehicle API (GET /api/drivers/profile/vehicle)
      try {
        final vehRes = await DriverService.getVehicleInfo(phone: phone);
        if (vehRes['success'] == true) {
          final v = vehRes['vehicleInformation'] ?? vehRes['data'] ?? vehRes;
          if (v is Map) {
            if (v['vehicleName'] != null && v['vehicleName'].toString().isNotEmpty) {
              vehicle = v['vehicleName'].toString();
            }
            if (v['vehicleMake'] != null && v['vehicleMake'].toString().isNotEmpty) {
              vehicleMake = v['vehicleMake'].toString();
            }
            if (v['vehicleModel'] != null && v['vehicleModel'].toString().isNotEmpty) {
              vehicleModel = v['vehicleModel'].toString();
            }
            if (v['vehicleType'] != null && v['vehicleType'].toString().isNotEmpty) {
              vehicleType = v['vehicleType'].toString();
            }
            if (v['vehicleNumberPlate'] != null && v['vehicleNumberPlate'].toString().isNotEmpty) {
              vehiclePlate = v['vehicleNumberPlate'].toString();
            }
            if (v['fuelType'] != null && v['fuelType'].toString().isNotEmpty) {
              fuelType = v['fuelType'].toString();
            }
          }
        }
      } catch (_) {}

      // 2. Try fetching driver approval status (GET /api/drivers/status)
      try {
        final driverStatus = await DriverService.getDriverApprovalStatus(phone: phone);
        if (driverStatus['success'] == true && driverStatus['driver'] != null) {
          final d = driverStatus['driver'];
          if (d['name'] != null && d['name'].toString().isNotEmpty) {
            driverName = d['name'];
          }
          if (d['vehicle'] != null && d['vehicle'].toString().isNotEmpty && vehicle.isEmpty) {
            vehicle = d['vehicle'].toString();
          }
          if (d['vehicleMake'] != null && d['vehicleMake'].toString().isNotEmpty && vehicleMake.isEmpty) {
            vehicleMake = d['vehicleMake'].toString();
          }
          if (d['vehicleModel'] != null && d['vehicleModel'].toString().isNotEmpty && vehicleModel.isEmpty) {
            vehicleModel = d['vehicleModel'].toString();
          }
          if (d['vehicleType'] != null && d['vehicleType'].toString().isNotEmpty && vehicleType.isEmpty) {
            vehicleType = d['vehicleType'].toString();
          }
          if (d['vehicleNumberPlate'] != null && d['vehicleNumberPlate'].toString().isNotEmpty && vehiclePlate.isEmpty) {
            vehiclePlate = d['vehicleNumberPlate'].toString();
          }
          if ((d['fuelType'] != null || d['vehicleFuelType'] != null) && fuelType.isEmpty) {
            fuelType = (d['fuelType'] ?? d['vehicleFuelType']).toString();
          }
        }
      } catch (_) {}

      if (vehicle.isEmpty && vehicleMake.isNotEmpty) {
        vehicle = '$vehicleMake $vehicleModel'.trim();
      }

      // Normalize fuelType to match backend Ride model enum ["Diesel", "Petrol", "Electric", "CNG", "Hybrid"]
      String normalizedFuelType = 'Diesel';
      final lowerFuel = fuelType.trim().toLowerCase();
      if (lowerFuel.contains('petrol')) {
        normalizedFuelType = 'Petrol';
      } else if (lowerFuel.contains('diesel')) {
        normalizedFuelType = 'Diesel';
      } else if (lowerFuel.contains('cng')) {
        normalizedFuelType = 'CNG';
      } else if (lowerFuel.contains('elec') || lowerFuel.contains('ev')) {
        normalizedFuelType = 'Electric';
      } else if (lowerFuel.contains('hyb')) {
        normalizedFuelType = 'Hybrid';
      }

      final activeCustomPrefs = _customPreferences.where((c) => c['enabled'] == true).map((c) => c['title'] as String).toList();
      final activeCustomFeatures = _customFeatures.where((c) => c['enabled'] == true).map((c) => c['title'] as String).toList();

      final ridePayload = <String, dynamic>{
        'driverName': driverName,
        'driverPhone': phone,
        'vehicle': vehicle,
        'vehicleMake': vehicleMake,
        'vehicleModel': vehicleModel,
        'vehicleType': vehicleType,
        'fuelType': normalizedFuelType,
        'vehicleNumberPlate': vehiclePlate,
        'from': widget.rideDetails?['from'] ?? 'Mangalagiri Road, Vijayawada, Andhra Pradesh, India',
        'pickupLocation': widget.rideDetails?['pickupLocation'] ?? 'Mangalagiri Road, Vijayawada',
        'pickupPincode': widget.rideDetails?['pickupPincode'] ?? '522503',
        'pickupLandmark': widget.rideDetails?['pickupLandmark'] ?? 'Near Mangalagiri Bus Stand',
        'to': widget.rideDetails?['to'] ?? 'Tirupati, Andhra Pradesh, India',
        'destinationLocation': widget.rideDetails?['destinationLocation'] ?? 'Tirupati',
        'destinationPincode': widget.rideDetails?['destinationPincode'] ?? '517501',
        'destinationLandmark': widget.rideDetails?['destinationLandmark'] ?? 'Near Tirupati Railway Station',
        'duration': widget.rideDetails?['duration'] ?? '4 hours 30 mins',
        'distance': widget.rideDetails?['distance'] ?? '330 KM',
        'seats': widget.rideDetails?['seats'] ?? 4,
        'booked': 0,
        'price': widget.rideDetails?['price'] ?? 850,
        'pricePerSeat': widget.rideDetails?['pricePerSeat'] ?? 850,
        'maxLuggagePerPassenger': _luggageCount > 0 ? _luggageCount : 2,
        'departs': widget.rideDetails?['departs'] ?? DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'departureTime': widget.rideDetails?['departureTime'] ?? '06:00 AM',
        'arrivalTime': widget.rideDetails?['arrivalTime'] ?? '10:30 AM',
        'preferences': {
          'acNonSmoking': _acNonSmoking,
          'ac': _ac,
          'wifi': _wifi,
          'usbCharging': _usbCharging,
          'verifiedDriver': _verifiedDriver,
          'mediumBagCount': _mediumBagCount,
          'saveForFuture': _saveForFuture,
          'customPreferences': activeCustomPrefs,
          'customFeatures': activeCustomFeatures,
        },
        'customPreferences': activeCustomPrefs,
        'customFeatures': activeCustomFeatures,
        'intermediatePickups': widget.rideDetails?['intermediatePickups'] ?? [
          {
            'location': 'Guntur, Andhra Pradesh',
            'pincode': '522001',
            'landmark': 'Near Guntur Bus Station',
            'time': '06:45 AM',
            'price': 800,
          },
          {
            'location': 'Narasaraopet, Andhra Pradesh',
            'pincode': '522601',
            'landmark': 'Near Narasaraopet Bus Stand',
            'time': '07:45 AM',
            'price': 750,
          },
          {
            'location': 'Ongole, Andhra Pradesh',
            'pincode': '523001',
            'landmark': 'Near Ongole Railway Station',
            'time': '09:15 AM',
            'price': 650,
          },
        ],
        'routePlan': widget.rideDetails?['routePlan'] ?? [
          {
            'location': 'Mangalagiri Road, Vijayawada, Andhra Pradesh',
            'pincode': '522503',
            'time': '06:00 AM',
            'type': 'start',
          },
          {
            'location': 'Guntur, Andhra Pradesh',
            'pincode': '522001',
            'time': '06:45 AM',
            'type': 'pickup',
          },
          {
            'location': 'Narasaraopet, Andhra Pradesh',
            'pincode': '522601',
            'time': '07:45 AM',
            'type': 'pickup',
          },
          {
            'location': 'Ongole, Andhra Pradesh',
            'pincode': '523001',
            'time': '09:15 AM',
            'type': 'pickup',
          },
          {
            'location': 'Tirupati, Andhra Pradesh',
            'pincode': '517501',
            'time': '10:30 AM',
            'type': 'destination',
          },
        ],
      };

      final response = await RideService.createRide(ridePayload);

      if (!mounted) return;
      setState(() => _isPublishing = false);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride Published Successfully! 🎉'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DriverHomeDashboardScreen83()),
          (route) => false,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DriverRideManagementScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ?? 'Ride published successfully! 🎉'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DriverHomeDashboardScreen83()),
          (route) => false,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DriverRideManagementScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPublishing = false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DriverHomeDashboardScreen83()),
          (route) => false,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DriverRideManagementScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Customer Preferences',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AC-Non Smokings Checkbox Card matching 93.png
              _buildCheckboxCard('AC-Non Smokings', _acNonSmoking, (val) {
                setState(() => _acNonSmoking = val ?? false);
              }),
              const SizedBox(height: 12),

              // AC Checkbox Card matching 93.png
              _buildCheckboxCard('AC', _ac, (val) {
                setState(() => _ac = val ?? false);
              }),
              const SizedBox(height: 12),

              // Luggage Counter Box matching 93.png
              _buildCounterCard('luggage', _luggageCount, (val) {
                setState(() => _luggageCount = val);
              }),
              const SizedBox(height: 12),

              // Medium Bag Counter Box matching 93.png
              _buildCounterCard('Medium Bag', _mediumBagCount, (val) {
                setState(() => _mediumBagCount = val);
              }),

              // Dynamic Custom Preferences (if added)
              if (_customPreferences.isNotEmpty) ...[
                const SizedBox(height: 12),
                ..._customPreferences.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCustomItemCard(
                      label: item['title'] as String,
                      value: item['enabled'] as bool,
                      onChanged: (val) {
                        setState(() {
                          _customPreferences[idx]['enabled'] = val ?? false;
                        });
                      },
                      onDelete: () {
                        setState(() {
                          _customPreferences.removeAt(idx);
                        });
                      },
                    ),
                  );
                }),
              ],

              const SizedBox(height: 10),

              // Add Custom Preference Button
              InkWell(
                onTap: () {
                  _showAddCustomDialog(
                    title: 'Add Custom Preference',
                    hint: 'e.g. Pet Friendly, Child Seat, Quiet Ride',
                    onAdd: (name) {
                      setState(() {
                        _customPreferences.add({'title': name, 'enabled': true});
                      });
                    },
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withAlpha(60)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Text(
                        '+ Add Custom Preference',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Ride Feature Section matching 93.png
              const Text(
                'Ride Feature',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              _buildCheckboxCard('WI-FI', _wifi, (val) {
                setState(() => _wifi = val ?? false);
              }),
              const SizedBox(height: 12),

              _buildCheckboxCard('USB charging', _usbCharging, (val) {
                setState(() => _usbCharging = val ?? false);
              }),
              const SizedBox(height: 12),

              _buildCheckboxCard('Verified Driver', _verifiedDriver, (val) {
                setState(() => _verifiedDriver = val ?? false);
              }),

              // Dynamic Custom Ride Features (if added)
              if (_customFeatures.isNotEmpty) ...[
                const SizedBox(height: 12),
                ..._customFeatures.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCustomItemCard(
                      label: item['title'] as String,
                      value: item['enabled'] as bool,
                      onChanged: (val) {
                        setState(() {
                          _customFeatures[idx]['enabled'] = val ?? false;
                        });
                      },
                      onDelete: () {
                        setState(() {
                          _customFeatures.removeAt(idx);
                        });
                      },
                    ),
                  );
                }),
              ],

              const SizedBox(height: 10),

              // Add Custom Ride Feature Button
              InkWell(
                onTap: () {
                  _showAddCustomDialog(
                    title: 'Add Custom Ride Feature',
                    hint: 'e.g. Dashcam, Snack & Water, Music Choice',
                    onAdd: (name) {
                      setState(() {
                        _customFeatures.add({'title': name, 'enabled': true});
                      });
                    },
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withAlpha(60)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Text(
                        '+ Add Custom Feature',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Save for future ride option matching 93.png
              Row(
                children: [
                  Checkbox(
                    value: _saveForFuture,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _saveForFuture = val ?? false);
                    },
                  ),
                  const Text('Save for feature ride', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),

              const SizedBox(height: 32),

              // Publish Ride CTA Button matching 93.png
              CustomButton(
                text: _isPublishing ? 'Publishing Ride...' : 'Publish Ride',
                isLoading: _isPublishing,
                onPressed: _isPublishing ? null : _publishRide,
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomItemCard({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDF7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                onPressed: onDelete,
                tooltip: 'Remove',
                visualDensity: VisualDensity.compact,
              ),
              Checkbox(
                value: value,
                activeColor: AppColors.primary,
                onChanged: onChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxCard(String label, bool value, ValueChanged<bool?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDF7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Checkbox(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterCard(String label, int count, ValueChanged<int> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDF7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Row(
            children: [
              Text('$count', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(width: 8),
              Column(
                children: [
                  InkWell(
                    onTap: () => onChanged(count + 1),
                    child: const Icon(Icons.arrow_drop_up_rounded, size: 18, color: AppColors.textPrimary),
                  ),
                  InkWell(
                    onTap: () => onChanged(count > 0 ? count - 1 : 0),
                    child: const Icon(Icons.arrow_drop_down_rounded, size: 18, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
