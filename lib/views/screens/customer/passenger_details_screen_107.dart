import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/ride_booking_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/ride_service.dart';
import '../../widgets/custom_button.dart';
import 'payment_method_screen_57.dart';

/// ============================================================================
/// SCREEN DATA ARCHITECTURE & API DEPENDENCY SPECIFICATION
/// ============================================================================
/// 
/// 1. APIS CALLED ON THIS SCREEN:
/// ----------------------------------------------------------------------------
/// A) [API 1: Customer Profile Prefill]
///    - Invoked: In `initState()` via `AuthService.getCurrentUser()`
///    - Source / Endpoint: Local Auth / Session Token Cache or `/api/auth/profile`
///    - Data Received:
///        • `name` (String) -> Split into First Name & Last Name controllers
///        • `phone` (String) -> Populates Phone Number controller
///        • `email` (String) -> Populates Email ID controller
///    - Usage: Pre-populates customer input fields if empty so the user doesn't
///      need to retype their profile information.
///
/// B) [API 2: Ride Booking Creation]
///    - Invoked: On "Proceed to Payment" tap via `RideService.createBooking(...)`
///    - Endpoint: `POST /api/rides/book`
///    - Payload Dispatched (Frontend -> Backend):
///        • `rideId`: Driver's published ride ID (from session)
///        • `fullName`: Merged first + last name from text fields
///        • `phoneNumber`: Full phone with prefix `+91 ...`
///        • `emailID`: Customer email address
///        • `numberOfSeats`: Selected count from dropdown (1..4)
///        • `boardingPoint` / `pickup`: Selected boarding/pickup location
///        • `destination`: Ride drop-off point
///        • `customerPickupAddress`, `customerPickupPincode`, `customerPickupLandmark`
///        • `doorstepPickupRequested`: Boolean flag (true if doorstep selected)
///        • `extraPickupCharge`: Detour fee amount
///        • `pricePerSeat`: Price per seat defined on driver ride
///        • `totalAmount`: Total computed fare (seats * price + detour charge)
///        • `luggage`: Selected luggage type (e.g. "1 Medium Bag")
///    - Response Received (Backend -> Frontend):
///        • `bookingId` / `id` / `_id`: Unique booking identifier created in DB
///        • `razorpayOrderId` / `orderId`: Order ID for Razorpay checkout
///        • `success`: Boolean status flag
///    - Usage: Transitions to [PaymentMethodScreen] carrying the verified
///      `bookingId` and `razorpayOrderId` for payment execution.
///
/// ----------------------------------------------------------------------------
/// 2. FIELD CLASSIFICATION (DYNAMIC vs STATIC):
/// ----------------------------------------------------------------------------
/// • DYNAMIC / API & SESSION DRIVEN:
///    - First Name & Last Name: Pre-filled via `AuthService`, editable by user.
///    - Phone Number: Pre-filled via `AuthService`, editable by user (10 digits).
///    - Email ID: Pre-filled via `AuthService`, editable by user.
///    - Number of Seats: Dynamically inherited from customer search session (`session.seatsCount`).
///    - Seat Fare: `session.driver.pricePerSeat * session.seatsCount` (Driver API).
///    - Doorstep Detour Fee: `session.detourCharge` (Google Maps Distance Matrix API).
///    - Total Payable: Live calculation `(pricePerSeat * seats) + detourCharge`.
///
/// • STATIC / UI-ONLY:
///    - Screen title: "Passenger Details"
///    - Field labels: "full name", "Last name", "Phone Number", "Email ID",
///      "Number Of Seats", "Fare Summary", "Total Payable".
///    - Phone prefix badge: "+91 "
///    - Bottom background illustration: `assets/images/image 31.png`
///    - Button CTA: "Proceed to Payment"
/// ============================================================================
class PassengerDetailsScreen extends StatefulWidget {
  final RideBookingSession? session;

  const PassengerDetailsScreen({
    super.key,
    this.session,
  });

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  RideBookingSession get _activeSession => widget.session ?? const RideBookingSession();
  int get _seatsCount => _activeSession.seatsCount > 0 ? _activeSession.seatsCount : 1;

  @override
  void initState() {
    super.initState();
    final nameParts = _activeSession.passengerName.trim().split(' ');
    _firstNameController = TextEditingController(text: nameParts.isNotEmpty ? nameParts.first : '');
    _lastNameController = TextEditingController(text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');
    _phoneController = TextEditingController(text: _activeSession.passengerPhone.replaceAll(RegExp(r'^\+91\s*'), ''));
    _emailController = TextEditingController(text: _activeSession.passengerEmail);
    _prefillFromAuth();
  }

  Future<void> _prefillFromAuth() async {
    final user = await AuthService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        if (_firstNameController.text.isEmpty && _lastNameController.text.isEmpty) {
          final n = user['name']?.toString() ?? '';
          if (n.isNotEmpty) {
            final parts = n.trim().split(' ');
            _firstNameController.text = parts.first;
            if (parts.length > 1) {
              _lastNameController.text = parts.sublist(1).join(' ');
            }
          }
        }
        if (_emailController.text.isEmpty) {
          final e = user['email']?.toString() ?? '';
          if (e.isNotEmpty) _emailController.text = e;
        }
        if (_phoneController.text.isEmpty) {
          final p = user['phone']?.toString() ?? '';
          final digits = p.replaceAll(RegExp(r'[^0-9]'), '');
          final tenDigits = digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
          if (tenDigits.isNotEmpty) _phoneController.text = tenDigits;
        }
      });
    } else {
      final name = await AuthService.getUserName(defaultFallback: '');
      if (name.isNotEmpty && mounted && _firstNameController.text.isEmpty) {
        setState(() {
          final parts = name.trim().split(' ');
          _firstNameController.text = parts.first;
          if (parts.length > 1) {
            _lastNameController.text = parts.sublist(1).join(' ');
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _isSubmitting = false;

  Future<void> _handleProceedToPayment(RideBookingSession session, double totalFare) async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final fullName = '$firstName $lastName'.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter full name.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (phone.isEmpty || phone.length < 10 || !RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number starting with 9, 8, 7, or 6.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final rideId = session.rideId.isNotEmpty ? session.rideId : session.driver.id;
    final res = await RideService.createBooking(
      rideId: rideId,
      fullName: fullName,
      lastName: lastName.isNotEmpty ? lastName : firstName,
      phoneNumber: '+91 $phone',
      emailID: email,
      numberOfSeats: _seatsCount,
      boardingPoint: session.boardingPoint.isNotEmpty ? session.boardingPoint : session.pickup,
      destination: session.destination,
      pickup: session.pickup.isNotEmpty ? session.pickup : session.boardingPoint,
      customerPickupAddress: session.customerPickupAddress.isNotEmpty ? session.customerPickupAddress : session.boardingPoint,
      customerPickupPincode: session.customerPickupPincode,
      customerPickupLandmark: session.customerPickupLandmark,
      custPickupLandmark: session.customerPickupLandmark,
      doorstepPickupRequested: session.isDoorstepPickup,
      extraPickupCharge: session.detourCharge,
      pricePerSeat: session.driver.pricePerSeat,
      totalAmount: totalFare,
      luggage: session.luggage.isNotEmpty ? session.luggage : "1 Medium Bag",
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']?.toString() ?? 'Failed to create booking. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bookingId = res['bookingId']?.toString() ??
        res['id']?.toString() ??
        (res['data'] is Map
            ? (res['data']['bookingId'] ?? res['data']['id'] ?? res['data']['_id'])?.toString() ?? ''
            : '');
    final razorpayOrderId = res['razorpayOrderId']?.toString() ??
        res['orderId']?.toString() ??
        res['order_id']?.toString() ??
        res['razorpay_order_id']?.toString() ??
        (res['data'] is Map
            ? (res['data']['razorpayOrderId'] ??
                    res['data']['orderId'] ??
                    res['data']['order_id'] ??
                    res['data']['razorpay_order_id'])
                ?.toString() ??
                ''
            : '');

    final finalSession = session.copyWith(
      rideId: rideId,
      bookingId: bookingId,
      razorpayOrderId: razorpayOrderId,
      passengerName: fullName,
      passengerPhone: '+91 $phone',
      passengerEmail: email,
      seatsCount: _seatsCount,
      totalAmount: totalFare,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(
          totalAmount: totalFare,
          rideSession: finalSession,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = _activeSession;
    final seatsCount = _seatsCount;
    final seatFare = session.driver.pricePerSeat * seatsCount;
    final totalFare = seatFare + session.detourCharge;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Passenger Details',
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
                        const Text('full name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _firstNameController,
                          hintText: 'Enter first name',
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                        ),

                        const SizedBox(height: 16),

                        const Text('Last name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _lastNameController,
                          hintText: 'Enter last name',
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                        ),

                        const SizedBox(height: 16),

                        const Text('Phone Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          hintText: '9876543210',
                          maxLength: 10,
                          prefixWidget: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            child: Text(
                              '+91 ',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^[6-9][0-9]*')),
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),

                        const SizedBox(height: 16),

                        const Text('Email ID', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          hintText: 'name@example.com',
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                        ),

                        const SizedBox(height: 20),

                        const Text('Number Of Seats', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),

                        // Dynamic Read-Only Seat Badge inherited from Search Session
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.airline_seat_recline_normal_rounded, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '$seatsCount ${seatsCount == 1 ? 'Seat' : 'Seats'}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F4FB),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Fare Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              const SizedBox(height: 12),
                              _buildFareRow('Seat Fare (${seatsCount}x ₹${session.driver.pricePerSeat.toStringAsFixed(0)})', '₹${seatFare.toStringAsFixed(0)}'),
                              if (session.isDoorstepPickup) ...[
                                const SizedBox(height: 8),
                                _buildFareRow('Doorstep Detour Fee (${session.detourDistanceKm.toStringAsFixed(0)} km)', '₹${session.detourCharge.toStringAsFixed(0)}'),
                              ],
                              const SizedBox(height: 10),
                              const Divider(color: AppColors.border),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Payable', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  Text(
                                    '₹${totalFare.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomButton(
                    text: 'Proceed to Payment',
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : () => _handleProceedToPayment(session, totalFare),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    Widget? prefixIcon,
    Widget? prefixWidget,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        counterText: '',
        prefixIcon: prefixWidget ?? prefixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}
