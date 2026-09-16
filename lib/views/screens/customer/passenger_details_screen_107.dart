import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/ride_booking_model.dart';
import '../../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import 'payment_method_screen_57.dart';

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
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  int _selectedSeatsCount = 1;

  RideBookingSession get _activeSession =>
      widget.session ??
      RideBookingSession(
        driver: mockRideDrivers[0],
      );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _activeSession.passengerName);
    _phoneController = TextEditingController(text: _activeSession.passengerPhone.replaceAll(RegExp(r'^\+91\s*'), ''));
    _emailController = TextEditingController(text: _activeSession.passengerEmail);
    _selectedSeatsCount = _activeSession.seatsCount;
    _prefillFromAuth();
  }

  Future<void> _prefillFromAuth() async {
    final user = await AuthService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        if (_nameController.text.isEmpty) {
          final n = user['name']?.toString() ?? '';
          if (n.isNotEmpty) _nameController.text = n;
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
      if (name.isNotEmpty && mounted && _nameController.text.isEmpty) {
        setState(() {
          _nameController.text = name;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleProceedToPayment(RideBookingSession session, double totalFare) {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter passenger full name.'), backgroundColor: Colors.red),
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

    final finalSession = session.copyWith(
      passengerName: name,
      passengerPhone: '+91 $phone',
      passengerEmail: email,
      seatsCount: _selectedSeatsCount,
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
    final seatFare = session.driver.pricePerSeat * _selectedSeatsCount;
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
                        const Text('Full Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _nameController,
                          hintText: 'Enter full name',
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                        ),

                        const SizedBox(height: 20),

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

                        const SizedBox(height: 20),

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

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedSeatsCount,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              items: [1, 2, 3, 4].map((count) {
                                return DropdownMenuItem<int>(
                                  value: count,
                                  child: Text('$count ${count == 1 ? 'Seat' : 'Seats'} (₹${(session.driver.pricePerSeat * count).toStringAsFixed(0)})'),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedSeatsCount = val!),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F4FB),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Fare Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              const SizedBox(height: 12),
                              _buildFareRow('Seat Fare (${_selectedSeatsCount}x ₹${session.driver.pricePerSeat.toStringAsFixed(0)})', '₹${seatFare.toStringAsFixed(0)}'),
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
                    onPressed: () => _handleProceedToPayment(session, totalFare),
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
