import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DriverEditRideScreen extends StatefulWidget {
  const DriverEditRideScreen({Key? key}) : super(key: key);

  @override
  State<DriverEditRideScreen> createState() => _DriverEditRideScreenState();
}

class _DriverEditRideScreenState extends State<DriverEditRideScreen> {
  int _price = 580;
  bool _nonSmoking = true;
  bool _ac = true;
  bool _luggage = true;
  bool _wifi = true;
  bool _usb = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
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
            // Header with Purple Gradient Background matching 84.png
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Edit Ride',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Main Details Container matching 84.png
            Container(
              transform: Matrix4.translationValues(0, -16, 0),
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),

                  // Manchuria -> Secundrabad card matching 84.png
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5FE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('09 : 10 AM', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Manchuria', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text('5h', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text('Secundrabad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('9 : 30 AM', style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                            Text('• • • • • • •', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            Text('15 : 00 PM', style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Prices Counter Box matching 84.png
                  const Text('Prices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5FE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (_price > 50) _price -= 10;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.remove, color: AppColors.primary, size: 20),
                          ),
                        ),
                        Text(
                          '₹ $_price',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _price += 10;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: AppColors.primary, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Co-traveler & option Section matching 84.png
                  const Text('Co-traveler & option', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('1 . Instant bookings', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('2 . review every request', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),

                  const SizedBox(height: 20),

                  // Customer Preference Checkboxes Card matching 84.png
                  const Text('Customer Preference', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5FE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildCheckboxTile('NON Smoking\'s', _nonSmoking, (val) => setState(() => _nonSmoking = val!))),
                            Expanded(child: _buildCheckboxTile('AC', _ac, (val) => setState(() => _ac = val!))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildCheckboxTile('Luggage\'s', _luggage, (val) => setState(() => _luggage = val!)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Driver Preference Checkboxes Card matching 84.png
                  const Text('Driver Preference', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5FE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildCheckboxTile('WIFI', _wifi, (val) => setState(() => _wifi = val!))),
                        Expanded(child: _buildCheckboxTile('USB', _usb, (val) => setState(() => _usb = val!))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Cancel Ride CTA Button matching 84.png
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEBEE),
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ride Cancelled Successfully.')),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel Ride',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                      ),
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
    );
  }

  Widget _buildCheckboxTile(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Checkbox(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
