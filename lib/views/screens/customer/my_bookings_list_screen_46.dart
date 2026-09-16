import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_image_placeholder.dart';
import 'booking_details_screen_49.dart';

class MyBookingsListScreen extends StatefulWidget {
  const MyBookingsListScreen({Key? key}) : super(key: key);

  @override
  State<MyBookingsListScreen> createState() => _MyBookingsListScreenState();
}

class _MyBookingsListScreenState extends State<MyBookingsListScreen> {
  int _selectedTabIndex = 0; // 0: Upcoming, 1: Completed, 2: Cancelled

  final List<Map<String, dynamic>> _bookings = [
    {'title': 'My Property', 'location': 'Goa, India', 'price': '₹6,500 / night', 'rating': '4.5'},
    {'title': 'My Property', 'location': 'Goa, India', 'price': '₹6,500 / night', 'rating': '4.5'},
    {'title': 'My Property', 'location': 'Goa, India', 'price': '₹6,500 / night', 'rating': '4.5'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Booking',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
            // Segmented Tabs Header matching 46.png, 47.png, 48.png
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(child: _buildTabButton('Upcoming', 0)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTabButton('Completed', 1)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTabButton('Cancelled', 2)),
                ],
              ),
            ),

            // Bookings List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final booking = _bookings[index];
                  final isCompleted = _selectedTabIndex == 1;
                  final isCancelled = _selectedTabIndex == 2;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CustomerBookingDetailsScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFFF1F8E9)
                            : isCancelled
                                ? const Color(0xFFFFEBEE)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: const [
                              CustomImagePlaceholder(
                                width: 85,
                                height: 75,
                                icon: Icons.villa_rounded,
                                borderRadius: BorderRadius.all(Radius.circular(14)),
                              ),
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Icon(Icons.favorite_rounded, color: AppColors.primary, size: 18),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(booking['title'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                const SizedBox(height: 4),
                                Text(booking['location'], style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                const SizedBox(height: 6),
                                Text(booking['price'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            ),
                          ),
                          if (isCompleted)
                            const Text(
                              'Complete',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                            )
                          else if (isCancelled)
                            const Text(
                              'Cancelled',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7EC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Text(booking['rating'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
                                ],
                              ),
                            ),
                        ],
                      ),
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

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF3EDF7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
