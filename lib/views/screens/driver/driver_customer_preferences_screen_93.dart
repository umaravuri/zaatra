import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/driver_service.dart';
import '../../../services/ride_service.dart';
import '../../widgets/custom_button.dart';
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
  // 1. Driver Preferences State
  bool _autoApproval = true;
  final List<Map<String, dynamic>> _customDriverPreferences = [];

  // 2. Customer Preferences State
  int _luggageCount = 0;
  int _mediumBagCount = 0;
  final List<Map<String, dynamic>> _customCustomerPreferences = [];

  // 3. Ride Features State
  bool _wifi = true;
  bool _usbCharging = true;
  final List<Map<String, dynamic>> _customRideFeatures = [];

  // General State
  bool _saveForFuture = true;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('driver_pref_save_enabled') && prefs.getBool('driver_pref_save_enabled') == true) {
        if (mounted) {
          setState(() {
            _autoApproval = prefs.getBool('driver_pref_auto_approval') ?? _autoApproval;
            _luggageCount = prefs.getInt('driver_pref_luggage_count') ?? _luggageCount;
            _mediumBagCount = prefs.getInt('driver_pref_medium_bag_count') ?? _mediumBagCount;
            _wifi = prefs.getBool('driver_pref_wifi') ?? _wifi;
            _usbCharging = prefs.getBool('driver_pref_usb_charging') ?? _usbCharging;

            // Load custom driver preferences
            final customDriverStr = prefs.getString('driver_pref_custom_driver_list');
            if (customDriverStr != null && customDriverStr.isNotEmpty) {
              final decoded = jsonDecode(customDriverStr);
              if (decoded is List) {
                _customDriverPreferences.clear();
                _customDriverPreferences.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
              }
            }

            // Load custom customer preferences
            final customCustomerStr = prefs.getString('driver_pref_custom_customer_list');
            if (customCustomerStr != null && customCustomerStr.isNotEmpty) {
              final decoded = jsonDecode(customCustomerStr);
              if (decoded is List) {
                _customCustomerPreferences.clear();
                _customCustomerPreferences.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
              }
            }

            // Load custom ride features
            final customFeaturesStr = prefs.getString('driver_pref_custom_features_list');
            if (customFeaturesStr != null && customFeaturesStr.isNotEmpty) {
              final decoded = jsonDecode(customFeaturesStr);
              if (decoded is List) {
                _customRideFeatures.clear();
                _customRideFeatures.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
              }
            }
          });
        }
      }
    } catch (_) {}
  }

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
      final phone = prefs.getString('currentPhone') ?? user?['phone']?.toString() ?? '';
      final cleanDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');

      // Resolve driverId
      final driverId = await DriverService.resolveCurrentDriverId();
      
      String driverName = prefs.getString('user_name_$cleanDigits') ?? 
                          prefs.getString('currentUserName') ?? 
                          user?['name']?.toString() ?? 
                          'Driver';

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
      if (phone.isNotEmpty) {
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
      }

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

      // Collect active custom items
      final activeDriverPrefs = _customDriverPreferences
          .where((c) => c['enabled'] == true)
          .map((c) => c['title'] as String)
          .toList();
      final activeCustomerPrefs = _customCustomerPreferences
          .where((c) => c['enabled'] == true)
          .map((c) => c['title'] as String)
          .toList();
      final activeRideFeatures = _customRideFeatures
          .where((c) => c['enabled'] == true)
          .map((c) => c['title'] as String)
          .toList();

      final combinedCustomPrefs = [...activeDriverPrefs, ...activeCustomerPrefs];

      // Persist preferences if saveForFuture is enabled
      if (_saveForFuture) {
        try {
          await prefs.setBool('driver_pref_save_enabled', true);
          await prefs.setBool('driver_pref_auto_approval', _autoApproval);
          await prefs.setInt('driver_pref_luggage_count', _luggageCount);
          await prefs.setInt('driver_pref_medium_bag_count', _mediumBagCount);
          await prefs.setBool('driver_pref_wifi', _wifi);
          await prefs.setBool('driver_pref_usb_charging', _usbCharging);

          await prefs.setString('driver_pref_custom_driver_list', jsonEncode(_customDriverPreferences));
          await prefs.setString('driver_pref_custom_customer_list', jsonEncode(_customCustomerPreferences));
          await prefs.setString('driver_pref_custom_features_list', jsonEncode(_customRideFeatures));
        } catch (_) {}
      }

      final fromLocation = widget.rideDetails?['from'] ?? widget.rideDetails?['pickupLocation'] ?? '';
      final toLocation = widget.rideDetails?['to'] ?? widget.rideDetails?['destinationLocation'] ?? '';

      final ridePayload = <String, dynamic>{
        'driverId': driverId,
        'driverName': driverName,
        'driverPhone': phone,
        'vehicle': vehicle,
        'vehicleMake': vehicleMake,
        'vehicleModel': vehicleModel,
        'vehicleType': vehicleType,
        'fuelType': normalizedFuelType,
        'vehicleNumberPlate': vehiclePlate,
        'from': fromLocation,
        'pickupLocation': widget.rideDetails?['pickupLocation'] ?? fromLocation,
        'pickupPincode': widget.rideDetails?['pickupPincode'] ?? '',
        'pickupLandmark': widget.rideDetails?['pickupLandmark'] ?? '',
        'to': toLocation,
        'destinationLocation': widget.rideDetails?['destinationLocation'] ?? toLocation,
        'destinationPincode': widget.rideDetails?['destinationPincode'] ?? '',
        'destinationLandmark': widget.rideDetails?['destinationLandmark'] ?? '',
        'duration': widget.rideDetails?['duration'] ?? '',
        'distance': widget.rideDetails?['distance'] ?? '',
        'seats': widget.rideDetails?['seats'] ?? 4,
        'booked': 0,
        'price': widget.rideDetails?['price'] ?? widget.rideDetails?['pricePerSeat'] ?? 0,
        'pricePerSeat': widget.rideDetails?['pricePerSeat'] ?? widget.rideDetails?['price'] ?? 0,
        'ratePerKm': widget.rideDetails?['ratePerKm'] ?? widget.rideDetails?['basePricePerKm'] ?? 10,
        'isDoorstepAllowed': (widget.rideDetails?['offerDoorstepPickupDrop'] == true) || (widget.rideDetails?['isDoorstepAllowed'] == true),
        'maxDetourRadiusKm': widget.rideDetails?['detourRadiusKm'] ?? widget.rideDetails?['maxDetourRadiusKm'] ?? 5,
        'detourRatePerKm': widget.rideDetails?['detourRatePerKm'] ?? 15,
        'maxLuggagePerPassenger': _luggageCount,
        'departs': widget.rideDetails?['departs'] ?? widget.rideDetails?['date'] ?? DateTime.now().toIso8601String(),
        'date': widget.rideDetails?['date'] ?? widget.rideDetails?['departs'] ?? DateTime.now().toIso8601String(),
        'departureDate': widget.rideDetails?['departureDate'] ?? '',
        'departureTime': widget.rideDetails?['departureTime'] ?? '',
        'arrivalTime': widget.rideDetails?['arrivalTime'] ?? '',
        'preferences': {
          'autoApproval': _autoApproval,
          'wifi': _wifi,
          'usbCharging': _usbCharging,
          'luggageCount': _luggageCount,
          'mediumBagCount': _mediumBagCount,
          'saveForFuture': _saveForFuture,
          'driverPreferences': [
            if (_autoApproval) 'Auto approval of passenger',
            ...activeDriverPrefs,
          ],
          'customerPreferences': activeCustomerPrefs,
          'customPreferences': combinedCustomPrefs,
          'customFeatures': activeRideFeatures,
          'rideFeatures': activeRideFeatures,
        },
        'customPreferences': combinedCustomPrefs,
        'customFeatures': activeRideFeatures,
        'intermediatePickups': widget.rideDetails?['intermediatePickups'] ?? [],
        'routePlan': widget.rideDetails?['routePlan'] ?? [],
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
          MaterialPageRoute(builder: (context) => const DriverRideManagementScreen(initialTabIndex: 1)),
          (route) => route.isFirst,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ?? 'Failed to publish ride. Please try again.'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPublishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred while publishing ride: $e'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
          ),
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
          'Preference',
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
                  // ==================== SECTION 1: DRIVER PREFERENCES ====================
                  const Text(
                    'Driver Preferences',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  _buildCheckboxCard('Auto approval of passenger', _autoApproval, (val) {
                    setState(() => _autoApproval = val ?? false);
                  }),

                  // Dynamic Custom Driver Preferences
                  if (_customDriverPreferences.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ..._customDriverPreferences.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCustomItemCard(
                          label: item['title'] as String,
                          value: item['enabled'] as bool,
                          onChanged: (val) {
                            setState(() {
                              _customDriverPreferences[idx]['enabled'] = val ?? false;
                            });
                          },
                          onDelete: () {
                            setState(() {
                              _customDriverPreferences.removeAt(idx);
                            });
                          },
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 10),

                  _buildAddButton(
                    label: '+ Add Custom Preference',
                    onTap: () {
                      _showAddCustomDialog(
                        title: 'Add Driver Preference',
                        hint: 'e.g. Calm Driving, Music Choice, Non-Chatty',
                        onAdd: (name) {
                          setState(() {
                            _customDriverPreferences.add({'title': name, 'enabled': true});
                          });
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ==================== SECTION 2: CUSTOMER PREFERENCES ====================
                  const Text(
                    'Customer Preferences',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  _buildCounterCard('luggage', _luggageCount, (val) {
                    setState(() => _luggageCount = val);
                  }),
                  const SizedBox(height: 12),

                  _buildCounterCard('Medium Bag', _mediumBagCount, (val) {
                    setState(() => _mediumBagCount = val);
                  }),

                  // Dynamic Custom Customer Preferences
                  if (_customCustomerPreferences.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ..._customCustomerPreferences.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCustomItemCard(
                          label: item['title'] as String,
                          value: item['enabled'] as bool,
                          onChanged: (val) {
                            setState(() {
                              _customCustomerPreferences[idx]['enabled'] = val ?? false;
                            });
                          },
                          onDelete: () {
                            setState(() {
                              _customCustomerPreferences.removeAt(idx);
                            });
                          },
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 10),

                  _buildAddButton(
                    label: '+ Add Custom Preference',
                    onTap: () {
                      _showAddCustomDialog(
                        title: 'Add Customer Preference',
                        hint: 'e.g. Pet Friendly, Child Seat, Women Only',
                        onAdd: (name) {
                          setState(() {
                            _customCustomerPreferences.add({'title': name, 'enabled': true});
                          });
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ==================== SECTION 3: RIDE FEATURES ====================
                  const Text(
                    'Ride Features',
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

                  // Dynamic Custom Ride Features
                  if (_customRideFeatures.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ..._customRideFeatures.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCustomItemCard(
                          label: item['title'] as String,
                          value: item['enabled'] as bool,
                          onChanged: (val) {
                            setState(() {
                              _customRideFeatures[idx]['enabled'] = val ?? false;
                            });
                          },
                          onDelete: () {
                            setState(() {
                              _customRideFeatures.removeAt(idx);
                            });
                          },
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 10),

                  _buildAddButton(
                    label: '+ Add Ride Feature',
                    onTap: () {
                      _showAddCustomDialog(
                        title: 'Add Ride Feature',
                        hint: 'e.g. Dashcam, Snack & Water, Sunroof',
                        onAdd: (name) {
                          setState(() {
                            _customRideFeatures.add({'title': name, 'enabled': true});
                          });
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Save for future ride option
                  Row(
                    children: [
                      Checkbox(
                        value: _saveForFuture,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() => _saveForFuture = val ?? false);
                        },
                      ),
                      const Text(
                        'Save for future ride',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Publish Ride CTA Button
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

  Widget _buildAddButton({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withAlpha(60)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
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
