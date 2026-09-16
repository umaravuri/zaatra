import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/booking_model.dart';
import '../../../models/ride_option_model.dart';
import '../../widgets/custom_button.dart';

class CustomerRideTrackingScreen extends StatefulWidget {
  final BookingModel? booking;

  const CustomerRideTrackingScreen({Key? key, this.booking}) : super(key: key);

  @override
  State<CustomerRideTrackingScreen> createState() => _CustomerRideTrackingScreenState();
}

class _CustomerRideTrackingScreenState extends State<CustomerRideTrackingScreen> {
  late final BookingModel _booking;
  final String _status = 'Driver arriving in 3 mins';

  @override
  void initState() {
    super.initState();
    _booking = widget.booking ??
        BookingModel.createSample(
          pickup: 'Madhapur, Hyderabad',
          dropoff: 'Gachibowli, Hyderabad',
          ride: RideOptionModel.sampleOptions.first,
          payment: 'Credit Card',
        );
  }

  void _cancelRide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride?'),
        content: const Text('Are you sure you want to cancel your ride booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No, Keep Ride')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Cancel Ride'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Booking #${_booking.bookingId}'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Live Map Tracking Area matching Screen 23
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFE8E5F4),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.directions_car_rounded, size: 40, color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Live Driver GPS Tracking',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                          ),
                          const SizedBox(height: 4),
                          Text(_status, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Booking Confirmed • Paid via ${_booking.paymentMethod}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Driver Card Container matching Screen 23
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryBackground,
                        child: const Icon(Icons.person_rounded, size: 32, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(_booking.driverName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                const SizedBox(width: 6),
                                const Icon(Icons.star_rounded, color: AppColors.accent, size: 18),
                                Text('${_booking.driverRating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text('${_booking.vehicleModel} • ${_booking.licensePlate}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(_booking.selectedRide.name, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),

                  const Divider(height: 24, color: AppColors.border),

                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Call Driver',
                          isOutlined: true,
                          icon: Icons.phone_rounded,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Calling Driver...')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Message',
                          isOutlined: true,
                          icon: Icons.chat_bubble_outline_rounded,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening Driver Chat...')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  CustomButton(
                    text: 'Cancel Ride',
                    backgroundColor: AppColors.error,
                    onPressed: _cancelRide,
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
