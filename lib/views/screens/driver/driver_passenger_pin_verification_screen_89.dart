import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/ride_booking_model.dart';
import '../../../services/ride_service.dart';
import '../../widgets/custom_button.dart';
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
    this.expectedPin = '8492',
    this.totalSeats = 4,
    this.bookedSeats = const [1, 2, 3],
    this.boardingSeat = 2,
  });

  @override
  State<DriverPassengerPinVerificationScreen> createState() => _DriverPassengerPinVerificationScreenState();
}

class _DriverPassengerPinVerificationScreenState extends State<DriverPassengerPinVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  bool _isLoading = false;
  PassengerBoardingVerifyDetails? _verifyDetails;

  @override
  void initState() {
    super.initState();
    _loadVerifyDetails();
  }

  Future<void> _loadVerifyDetails() async {
    final bId = widget.bookingId ?? '';
    if (bId.isEmpty) return;

    final res = await RideService.getPassengerVerifyDetails(
      rideId: widget.rideId,
      bookingId: bId,
      passengerName: widget.passengerName,
    );

    if (mounted && res['success'] == true) {
      setState(() {
        _verifyDetails = PassengerBoardingVerifyDetails.fromJson(res);
      });
    }
  }

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

    if (enteredPin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the full 4-digit passenger boarding PIN.'),
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
        expectedPin: _verifyDetails?.expectedPin ?? widget.expectedPin,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res['success'] == true) {
        final pName = _verifyDetails?.passengerName ?? widget.passengerName;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$pName verified and boarded successfully! 🎉'),
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
              passengerName: _verifyDetails?.passengerName ?? widget.passengerName,
              rideId: widget.rideId,
              bookingId: widget.bookingId,
              seatNumber: _verifyDetails?.seatNumber.isNotEmpty == true ? _verifyDetails!.seatNumber : 'S-${widget.boardingSeat}',
              expectedPin: _verifyDetails?.expectedPin ?? widget.expectedPin,
            ),
          ),
        );

        if (result == true && mounted) {
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

  Future<void> _handleVerifyQrPass() async {
    final qrTokenController = TextEditingController();

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 26),
                  SizedBox(width: 10),
                  Text(
                    'Contactless QR Pass',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter passenger QR Pass token or scan QR code:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: qrTokenController,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'e.g. ZAATRA-PASS-66129...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.qr_code, color: AppColors.primary),
                  filled: true,
                  fillColor: const Color(0xFFF7F5FE),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final token = qrTokenController.text.trim();
                        if (token.isEmpty) return;
                        Navigator.pop(ctx, token);
                      },
                      child: const Text('Verify Pass', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result == null || result.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final res = await RideService.verifyQrPass(
        token: result,
        bookingId: widget.bookingId,
        rideId: widget.rideId,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res['success'] == true) {
        final pName = res['customerName']?.toString() ?? widget.passengerName;
        final seat = res['seatNumber']?.toString() ?? '${widget.boardingSeat}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 $pName verified via QR Pass! Boarded in seat $seat'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']?.toString() ?? 'Invalid QR Pass token.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pName = _verifyDetails?.passengerName ?? widget.passengerName;
    final fromLoc = _verifyDetails?.pickupLocation.isNotEmpty == true ? _verifyDetails!.pickupLocation : widget.pickupLocation;
    final toLoc = _verifyDetails?.dropoffLocation.isNotEmpty == true ? _verifyDetails!.dropoffLocation : widget.dropoffLocation;
    final seatLabel = _verifyDetails?.seatNumber.isNotEmpty == true ? _verifyDetails!.seatNumber : 'S-${widget.boardingSeat}';
    final seatGrid = _verifyDetails?.seatGrid ?? [];

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

                  // Smartphone Vector Illustration Graphic
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
                                pName,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$fromLoc → $toLoc',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            seatLabel.startsWith('S-') ? seatLabel : 'Seat $seatLabel',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // 4-Digit PIN Entry Fields Row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = (constraints.maxWidth - 3 * 14) / 4;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: itemWidth,
                            height: 56,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 3) {
                                  _focusNodes[index + 1].requestFocus();
                                } else if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                                if (_currentEnteredPin.length == 4) {
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

                  // Verify PIN Primary Button
                  CustomButton(
                    text: 'Verify PIN',
                    isLoading: _isLoading,
                    onPressed: _handleVerifyPin,
                  ),

                  const SizedBox(height: 12),

                  // Contactless QR Pass Verification Button
                  CustomButton(
                    text: 'Verify via QR Pass 📷',
                    isOutlined: true,
                    backgroundColor: const Color(0xFFF3EDF7),
                    textColor: AppColors.primary,
                    onPressed: _isLoading ? null : _handleVerifyQrPass,
                  ),

                  const SizedBox(height: 28),

                  // Seats Layout Section with Visual Matrix
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Visual Seat Grid',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: seatGrid.isNotEmpty
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: seatGrid.map((item) {
                              final isCurrent = item.seat == seatLabel || item.isPassengerSeat;
                              return _buildSeatBox(
                                '${item.seat} ${item.status}',
                                isBooked: item.isBooked,
                                isBoarding: isCurrent,
                                isAvailable: item.isAvailable,
                              );
                            }).toList(),
                          )
                        : Row(
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
                                label = 'S-$seatNum Available';
                              }

                              return _buildSeatBox(
                                label,
                                isBooked: isBooked,
                                isBoarding: isBoarding,
                                isAvailable: !isBooked && !isBoarding,
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

  Widget _buildSeatBox(String label, {required bool isBooked, bool isBoarding = false, bool isAvailable = false}) {
    Color boxColor;
    Color iconColor;

    if (isBoarding) {
      boxColor = AppColors.primary;
      iconColor = Colors.white;
    } else if (isBooked) {
      boxColor = const Color(0xFFE8DEF8);
      iconColor = AppColors.primary;
    } else {
      boxColor = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF2E7D32);
    }

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(12),
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
              isAvailable ? Icons.event_seat_outlined : (isBooked ? Icons.person_rounded : Icons.check_box_outline_blank_rounded),
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
