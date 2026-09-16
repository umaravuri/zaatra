import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/ride_booking_model.dart';
import '../../widgets/custom_button.dart';
import 'passenger_details_screen_107.dart';

class SelectBoardingPointScreen extends StatefulWidget {
  final RideBookingSession? session;

  const SelectBoardingPointScreen({
    super.key,
    this.session,
  });

  @override
  State<SelectBoardingPointScreen> createState() => _SelectBoardingPointScreenState();
}

class _SelectBoardingPointScreenState extends State<SelectBoardingPointScreen> {
  int _selectedPointIndex = 0;
  bool _doorstepPickup = false;
  final double _detourKm = 12.0;
  final double _perKmRate = 5.0;

  late final TextEditingController _addressController;
  late final TextEditingController _landmarkController;
  late final TextEditingController _pincodeController;

  @override
  void initState() {
    super.initState();
    final s = _activeSession;
    _addressController = TextEditingController(text: s.customerPickupAddress);
    _landmarkController = TextEditingController(text: s.customerPickupLandmark);
    _pincodeController = TextEditingController(text: s.customerPickupPincode);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  RideBookingSession get _activeSession =>
      widget.session ??
      RideBookingSession(
        driver: mockRideDrivers[0],
      );

  List<Map<String, String>> get _points => [
        {'location': '${_activeSession.pickup} (Metro Gate 2)', 'time': _activeSession.time},
        {'location': '${_activeSession.pickup} (Main Circle)', 'time': '09:40 AM'},
        {'location': '${_activeSession.pickup} (Highway Junction)', 'time': '09:50 AM'},
      ];

  @override
  Widget build(BuildContext context) {
    final session = _activeSession;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Boarding Point',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
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
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Route Map Preview Box matching 105.png
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8DEF8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 30),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Designated Boarding Stops',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 12),

                        // Boarding Points Selection Radio List matching 105.png
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _points.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final point = _points[index];
                            final isSelected = _selectedPointIndex == index && !_doorstepPickup;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPointIndex = index;
                                  _doorstepPickup = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFF7F4FB) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Radio<int>(
                                      value: index,
                                      groupValue: _doorstepPickup ? -1 : _selectedPointIndex,
                                      activeColor: AppColors.primary,
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedPointIndex = val!;
                                          _doorstepPickup = false;
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        point['location']!,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                    ),
                                    Text(
                                      point['time']!,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Doorstep Pickup Detour Option (Backend Spec Feature)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _doorstepPickup ? const Color(0xFFF7F4FB) : const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _doorstepPickup ? AppColors.primary : AppColors.border,
                              width: _doorstepPickup ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _doorstepPickup,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) {
                                      setState(() => _doorstepPickup = val ?? false);
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Request Doorstep Pickup',
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Detour ~${_detourKm.toStringAsFixed(0)} km (+₹${(_detourKm * _perKmRate).toStringAsFixed(0)} detour fee)',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (_doorstepPickup) ...[
                                const Divider(height: 20),
                                TextField(
                                  controller: _addressController,
                                  decoration: InputDecoration(
                                    labelText: 'Doorstep Pickup Address',
                                    hintText: 'e.g. Billa Bus Stand Area',
                                    isDense: true,
                                    prefixIcon: const Icon(Icons.home_rounded, size: 18, color: AppColors.primary),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _landmarkController,
                                        decoration: InputDecoration(
                                          labelText: 'Landmark',
                                          hintText: 'e.g. Near Metro / Circle',
                                          isDense: true,
                                          prefixIcon: const Icon(Icons.place_rounded, size: 18, color: AppColors.primary),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: _pincodeController,
                                        keyboardType: TextInputType.number,
                                        maxLength: 6,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(6),
                                        ],
                                        decoration: InputDecoration(
                                          labelText: 'Pincode',
                                          hintText: '500081',
                                          counterText: '',
                                          isDense: true,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Continue CTA
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomButton(
                    text: 'Continue',
                    onPressed: () {
                      if (_doorstepPickup) {
                        final address = _addressController.text.trim();
                        final pin = _pincodeController.text.trim();
                        if (address.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter your doorstep pickup address.'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        if (pin.length != 6 || !RegExp(r'^[1-9][0-9]{5}$').hasMatch(pin)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid 6-digit Pincode.'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                      }

                      final detourCharge = _doorstepPickup ? (_detourKm * _perKmRate) : 0.0;
                      final chosenPoint = _points[_selectedPointIndex]['location']!;
                      final updatedSession = session.copyWith(
                        boardingPoint: chosenPoint,
                        isDoorstepPickup: _doorstepPickup,
                        customerPickupAddress: _doorstepPickup ? _addressController.text.trim() : session.customerPickupAddress,
                        customerPickupLandmark: _doorstepPickup ? _landmarkController.text.trim() : session.customerPickupLandmark,
                        customerPickupPincode: _doorstepPickup ? _pincodeController.text.trim() : session.customerPickupPincode,
                        detourDistanceKm: _doorstepPickup ? _detourKm : 0.0,
                        detourCharge: detourCharge,
                        totalAmount: session.driver.pricePerSeat * session.seatsCount + detourCharge,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PassengerDetailsScreen(session: updatedSession),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
