import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/ride_service.dart';
import '../../widgets/custom_button.dart';

class DriverWrongPinScreen extends StatefulWidget {
  final String initialWrongPin;
  final String passengerName;
  final String rideId;
  final String? bookingId;
  final String? seatNumber;
  final String? expectedPin;

  const DriverWrongPinScreen({
    super.key,
    this.initialWrongPin = '',
    this.passengerName = 'Passenger',
    this.rideId = 'RIDE-8902',
    this.bookingId,
    this.seatNumber,
    this.expectedPin = '8492',
  });

  @override
  State<DriverWrongPinScreen> createState() => _DriverWrongPinScreenState();
}

class _DriverWrongPinScreenState extends State<DriverWrongPinScreen> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (index) {
      if (index < widget.initialWrongPin.length) {
        return TextEditingController(text: widget.initialWrongPin[index]);
      }
      return TextEditingController();
    });
    _focusNodes = List.generate(4, (index) => FocusNode());
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

  Future<void> _handleReVerify() async {
    final pin = _currentEnteredPin;
    if (pin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 4 digits of the PIN.'),
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
        pin: pin,
        seatNumber: widget.seatNumber,
        passengerName: widget.passengerName,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']?.toString() ?? 'Incorrect PIN. Please re-check with ${widget.passengerName}.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification error: $e'), backgroundColor: Colors.redAccent),
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
          'Wrong pin',
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
                  const SizedBox(height: 10),

                  // Smartphone Vector Illustration Graphic matching 90.png
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3EDF7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phonelink_erase_rounded, color: Colors.redAccent, size: 70),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // 4 PIN Entry Fields Row matching 90.png
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = (constraints.maxWidth - 3 * 16) / 4;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return Padding(
                            padding: EdgeInsets.only(right: index < 3 ? 16.0 : 0.0),
                            child: SizedBox(
                              width: itemWidth.clamp(52.0, 68.0),
                              height: 60,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
                                decoration: InputDecoration(
                                  counterText: '',
                                  contentPadding: EdgeInsets.zero,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 3) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                },
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Troubleshooting Instructions List matching 90.png
                  const Text('• Ask co-traveler to check in their app', style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  const Text('• Ask co-traveler to open the Zaatra booking app', style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  const Text('• Confirm their correct ride date and route', style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  const Text('• Cannot verify? Mark as vacate seat', style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),

                  const SizedBox(height: 36),

                  // Try Again Button matching 90.png
                  CustomButton(
                    text: 'Try Again',
                    isOutlined: true,
                    backgroundColor: const Color(0xFFF3EDF7),
                    textColor: AppColors.primary,
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),

                  const SizedBox(height: 12),

                  // Verify Pin Button matching 90.png
                  CustomButton(
                    text: 'Verify pin',
                    isLoading: _isLoading,
                    onPressed: _handleReVerify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
