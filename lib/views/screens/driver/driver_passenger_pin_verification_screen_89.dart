import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/ride_service.dart';
import '../../widgets/custom_button.dart';
import 'driver_on_trip_seats_screen_91.dart';
import 'driver_wrong_pin_screen_90.dart';

class DriverPassengerPinVerificationScreen extends StatefulWidget {
  final String rideId;
  final String? bookingId;
  final String passengerName;
  final String pickupLocation;
  final String dropoffLocation;
  final String? expectedPin;
  final int totalSeats;
  final List<int> bookedSeats;
  final int boardingSeat;

  const DriverPassengerPinVerificationScreen({
    super.key,
    this.rideId = 'RIDE-8902',
    this.bookingId,
    this.passengerName = 'Passenger',
    this.pickupLocation = 'Madhapur',
    this.dropoffLocation = 'Secunderabad',
    this.expectedPin = '849201',
    this.totalSeats = 4,
    this.bookedSeats = const [1, 2, 3],
    this.boardingSeat = 2,
  });

  @override
  State<DriverPassengerPinVerificationScreen> createState() => _DriverPassengerPinVerificationScreenState();
}

class _DriverPassengerPinVerificationScreenState extends State<DriverPassengerPinVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentEnteredPin => _controllers.map((c) => c.text.trim()).join();

  Future<void> _handleVerifyPin() async {
    final enteredPin = _currentEnteredPin;

    if (enteredPin.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the full 6-digit passenger boarding PIN.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await RideService.verifyPassengerPin(
        rideId: widget.rideId,
        bookingId: widget.bookingId,
        pin: enteredPin,
        expectedPin: widget.expectedPin,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.passengerName} verified and boarded successfully! 🎉'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pop(context, true);
      } else {
        // Wrong PIN -> Navigate to Screen 90
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => DriverWrongPinScreen(
              initialWrongPin: enteredPin,
              passengerName: widget.passengerName,
              rideId: widget.rideId,
              expectedPin: widget.expectedPin,
            ),
          ),
        );

        if (result == true && mounted) {
          // Successfully verified in Screen 90 -> pop back to Screen 88
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification error: $e'),
          backgroundColor: Colors.redAccent,
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verification',
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
                children: [
                  const SizedBox(height: 10),

                  // Smartphone Vector Illustration Graphic matching 89.png
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3EDF7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phonelink_setup_rounded, color: AppColors.primary, size: 70),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Passenger Details Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5FE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withAlpha(40)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary.withAlpha(30),
                          child: const Icon(Icons.person, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.passengerName,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.pickupLocation} → ${widget.dropoffLocation}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Seat S-${widget.boardingSeat}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // 6 PIN Entry Fields Row matching 89.png
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = (constraints.maxWidth - 5 * 8) / 6;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: itemWidth,
                            height: 52,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                } else if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                                if (_currentEnteredPin.length == 6) {
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            ),
                          );
                        }),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Verify PIN Primary Button matching 89.png
                  CustomButton(
                    text: 'Verify pin',
                    isLoading: _isLoading,
                    onPressed: _handleVerifyPin,
                  ),

                  const SizedBox(height: 36),

                  // Seats Available Section matching 89.png
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Seats Available',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5FE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(widget.totalSeats, (index) {
                        final seatNum = index + 1;
                        final isBoarding = seatNum == widget.boardingSeat;
                        final isBooked = widget.bookedSeats.contains(seatNum);

                        String label;
                        if (isBoarding) {
                          label = 'S-$seatNum Boarding';
                        } else if (isBooked) {
                          label = 'S-$seatNum Booked';
                        } else {
                          label = 'S-$seatNum Free';
                        }

                        return _buildSeatBox(
                          label,
                          isBooked: isBooked,
                          isBoarding: isBoarding,
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatBox(String label, {required bool isBooked, bool isBoarding = false}) {
    Color boxColor;
    Color iconColor;

    if (isBoarding) {
      boxColor = AppColors.primary;
      iconColor = Colors.white;
    } else if (isBooked) {
      boxColor = const Color(0xFFE8DEF8);
      iconColor = AppColors.primary;
    } else {
      boxColor = const Color(0xFFC4D5C5);
      iconColor = Colors.transparent;
    }

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isBoarding
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(80),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              isBooked ? Icons.person_rounded : Icons.check_box_outline_blank_rounded,
              color: iconColor,
              size: 22,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isBoarding ? FontWeight.bold : FontWeight.w600,
            color: isBoarding ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
