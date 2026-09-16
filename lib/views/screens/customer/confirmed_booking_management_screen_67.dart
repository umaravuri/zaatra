import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_placeholder.dart';
import 'booking_invoice_screen_50.dart';

class ConfirmedBookingManagementScreen extends StatelessWidget {
  const ConfirmedBookingManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card matching 67.png
              Row(
                children: [
                  const CustomImagePlaceholder(
                    width: 70,
                    height: 70,
                    icon: Icons.villa_rounded,
                    borderRadius: BorderRadius.all(Radius.circular(35)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Sun set beach villa',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text('Goa Baga Beach', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Conformed',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Booking ID', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  Text('# BK 123456', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 16),

              // Check-in / Check-out Timeline Box matching 67.png
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Check - in', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      SizedBox(height: 4),
                      Text('20 May . 2024', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      SizedBox(height: 2),
                      Text('11 : 00 AM', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const Text('• • • • • • • • •', style: TextStyle(color: AppColors.border, fontSize: 16)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text('Check - Out', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      SizedBox(height: 4),
                      Text('22 May . 2024', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      SizedBox(height: 2),
                      Text('10 : 00 PM', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text('Stay Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3EDF7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('2 Guests', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),

              const SizedBox(height: 24),
              const Text('Payment Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),

              _buildPaymentDetailRow('Total Amount', '₹24,000'),
              const SizedBox(height: 12),
              _buildPaymentDetailRow('Paid', '₹24,000'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Payment Amount', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  Text('Paid', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                ],
              ),

              const SizedBox(height: 36),

              // Download Invoice CTA matching 67.png
              CustomButton(
                text: 'Download invoice',
                icon: Icons.download_rounded,
                backgroundColor: const Color(0xFFF3EDF7),
                textColor: AppColors.primary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BookingInvoiceScreen()),
                  );
                },
              ),

              const SizedBox(height: 14),

              // Cancel Booking CTA matching 67.png
              CustomButton(
                text: 'Cancel Booking',
                icon: Icons.cancel_outlined,
                backgroundColor: const Color(0xFFFFEBEE),
                textColor: const Color(0xFFD32F2F),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cancel booking request submitted.')),
                  );
                },
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
