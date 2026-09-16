import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_image_placeholder.dart';
import 'host_booking_details_screen_65.dart';

class HostBookingsListScreen extends StatefulWidget {
  const HostBookingsListScreen({Key? key}) : super(key: key);

  @override
  State<HostBookingsListScreen> createState() => _HostBookingsListScreenState();
}

class _HostBookingsListScreenState extends State<HostBookingsListScreen> {
  int _selectedTab = 0;

  final List<String> _tabs = ['Upcoming', 'Completed', 'Cancelled', 'Ongoing'];

  final List<Map<String, dynamic>> _bookings = [
    {'name': 'Anjali Sharma', 'property': 'See view vila', 'date': '20 May - 24 May', 'price': '₹ 24,000', 'status': 'Conformed'},
    {'name': 'Anjali Sharma', 'property': 'See view vila', 'date': '20 May - 24 May', 'price': '₹ 24,000', 'status': 'Conformed'},
    {'name': 'Anjali Sharma', 'property': 'See view vila', 'date': '20 May - 24 May', 'price': '₹ 24,000', 'status': 'Pending'},
    {'name': 'Anjali Sharma', 'property': 'See view vila', 'date': '20 May - 24 May', 'price': '₹ 24,000', 'status': 'Conformed'},
    {'name': 'Anjali Sharma', 'property': 'See view vila', 'date': '20 May - 24 May', 'price': '₹ 24,000', 'status': 'Conformed'},
  ];

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
          'Booking',
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
            Column(
          children: [
            // Filter Pills Tab Row matching 64.png
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = _selectedTab == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : const Color(0xFFF3EDF7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 10),

            // Bookings List matching 64.png
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20.0),
                itemCount: _bookings.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = _bookings[index];
                  final isConformed = item['status'] == 'Conformed';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HostBookingDetailsScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const CustomImagePlaceholder(
                            width: 60,
                            height: 60,
                            icon: Icons.person_rounded,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                const SizedBox(height: 4),
                                Text(item['property'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Text(item['date'], style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(item['price'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              const SizedBox(height: 6),
                              Text(
                                item['status'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isConformed ? const Color(0xFF2E7D32) : Colors.orangeAccent,
                                ),
                              ),
                            ],
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
}
