import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/hotel_model.dart';
import '../../widgets/custom_button.dart';
import 'payment_method_screen_57.dart';

class BookingSummaryScreen extends StatelessWidget {
  final Hotel? hotel;
  final HotelRoom? selectedRoom;
  final int nights;

  const BookingSummaryScreen({
    super.key,
    this.hotel,
    this.selectedRoom,
    this.nights = 2,
  });

  @override
  Widget build(BuildContext context) {
    final activeHotel = hotel ?? mockHotels[0];
    final activeRoom = selectedRoom ?? activeHotel.rooms.first;

    final double roomSubtotal = activeRoom.pricePerNight * nights;
    const double cleaningFee = 600.0;
    const double serviceFee = 600.0;
    final double totalAmount = roomSubtotal + cleaningFee + serviceFee;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Booking Summary',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
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
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Card Row matching 55.png
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  color: const Color(0xFFF3EDF7),
                                  child: Image.asset(
                                    activeHotel.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.hotel_rounded, size: 36, color: AppColors.primary),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activeHotel.title,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      activeHotel.location,
                                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${activeHotel.rating}',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '(${activeHotel.reviewCount} reviews)',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 16),

                          // Check-in / Check-out Timeline Row matching 55.png
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Check - in', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                  SizedBox(height: 4),
                                  Text('20 May . 2026', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                ],
                              ),
                              Text('• • • • • • • • •', style: TextStyle(color: AppColors.border, fontSize: 16)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Check - Out', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                  SizedBox(height: 4),
                                  Text('22 May . 2026', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 16),

                          // Selected Room Details Chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F4FB),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.primary.withAlpha(50)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.meeting_room_rounded, color: AppColors.primary, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activeRoom.title,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                      Text(
                                        activeRoom.specs,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 16),

                          // Price Breakdown Rows matching 55.png
                          _buildPriceRow(
                            '${activeRoom.title}\n₹${activeRoom.pricePerNight.toStringAsFixed(0)} x $nights nights',
                            '₹${roomSubtotal.toStringAsFixed(0)}',
                          ),
                          const SizedBox(height: 14),
                          _buildPriceRow('Cleaning Fee', '₹${cleaningFee.toStringAsFixed(0)}'),
                          const SizedBox(height: 14),
                          _buildPriceRow('Services Fee', '₹${serviceFee.toStringAsFixed(0)}'),

                          const SizedBox(height: 20),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              Text(
                                '₹${totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Continue CTA
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomButton(
                    text: 'Continue to Payment',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PaymentMethodScreen()),
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

  Widget _buildPriceRow(String label, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.3)),
        Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
