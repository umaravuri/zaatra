import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'booking_details_screen_49.dart';
import 'ride_confirmed_detail_screen_112.dart';

class MyBookingsListScreen extends StatefulWidget {
  const MyBookingsListScreen({super.key});

  @override
  State<MyBookingsListScreen> createState() => _MyBookingsListScreenState();
}

class _MyBookingsListScreenState extends State<MyBookingsListScreen> {
  int _selectedCategoryIndex = 0; // 0: Stay, 1: Ride, 2: Heritage Sites, 3: Banquet Halls

  final List<String> _categories = const [
    'Stay',
    'Ride',
    'Heritage Sites',
    'Banquet Halls',
  ];

  final Map<int, List<Map<String, dynamic>>> _categoryBookings = {
    0: [
      {
        'title': 'Grand Zaatra Resort & Spa',
        'location': 'Goa, India',
        'price': '₹14,500',
        'subtitle': '25 Aug - 28 Aug • 3 Nights',
        'status': 'Confirmed',
        'icon': Icons.apartment_rounded,
        'rating': '4.8',
      },
      {
        'title': 'Zaatra Heritage Boutique Hotel',
        'location': 'Jaipur, Rajasthan',
        'price': '₹6,800',
        'subtitle': '12 Sep - 14 Sep • 2 Nights',
        'status': 'Confirmed',
        'icon': Icons.domain_rounded,
        'rating': '4.6',
      },
      {
        'title': 'Hilltop Luxury Private Villa',
        'location': 'Lonavala, Maharashtra',
        'price': '₹18,000',
        'subtitle': '05 Jul - 07 Jul • 2 Nights',
        'status': 'Completed',
        'icon': Icons.villa_rounded,
        'rating': '4.9',
      },
    ],
    1: [
      {
        'title': 'Vijayawada ➔ Tirupati',
        'location': 'Pickup: Benz Circle',
        'price': '₹870',
        'subtitle': 'Today • Kia Seltos (Sarah Ahmed)',
        'status': 'Scheduled',
        'icon': Icons.directions_car_rounded,
        'rating': '4.9',
      },
      {
        'title': 'Hyderabad ➔ Bangalore',
        'location': 'Pickup: Gachibowli',
        'price': '₹1,200',
        'subtitle': '15 Aug 2026 • Toyota Innova',
        'status': 'Completed',
        'icon': Icons.directions_car_rounded,
        'rating': '4.7',
      },
      {
        'title': 'Guntur ➔ Ongole',
        'location': 'Pickup: Bus Station',
        'price': '₹450',
        'subtitle': '20 Jul 2026 • Maruti Dzire',
        'status': 'Completed',
        'icon': Icons.directions_car_rounded,
        'rating': '4.8',
      },
    ],
    2: [
      {
        'title': 'Golconda Fort Guided Tour',
        'location': 'Hyderabad, Telangana',
        'price': '₹400',
        'subtitle': '28 Sep 2026 • 2 Visitors',
        'status': 'Confirmed',
        'icon': Icons.account_balance_rounded,
        'rating': '4.9',
      },
      {
        'title': 'Charminar Heritage Walk',
        'location': 'Old City, Hyderabad',
        'price': '₹600',
        'subtitle': '10 Oct 2026 • 3 Adults',
        'status': 'Confirmed',
        'icon': Icons.museum_rounded,
        'rating': '4.8',
      },
      {
        'title': 'Qutb Shahi Tombs Experience',
        'location': 'Ibrahim Bagh, Hyderabad',
        'price': '₹250',
        'subtitle': '15 Aug 2026 • 1 Adult',
        'status': 'Completed',
        'icon': Icons.temple_hindu_rounded,
        'rating': '4.7',
      },
    ],
    3: [
      {
        'title': 'Grand Royal Palace Banquet',
        'location': 'Banjara Hills, Hyderabad',
        'price': '₹1,25,000',
        'subtitle': '18 Nov 2026 • Wedding (500 Guests)',
        'status': 'Reserved',
        'icon': Icons.celebration_rounded,
        'rating': '5.0',
      },
      {
        'title': 'Zaatra Crystal Ballroom',
        'location': 'Jubilee Hills, Hyderabad',
        'price': '₹75,000',
        'subtitle': '24 Dec 2026 • Reception (250 Guests)',
        'status': 'Pending',
        'icon': Icons.festival_rounded,
        'rating': '4.9',
      },
      {
        'title': 'Emerald Green Lawn & Banquet',
        'location': 'Madhapur, Hyderabad',
        'price': '₹95,000',
        'subtitle': '10 Jul 2026 • Full Day (300 Guests)',
        'status': 'Completed',
        'icon': Icons.event_seat_rounded,
        'rating': '4.8',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final currentList = _categoryBookings[_selectedCategoryIndex] ?? [];
    final currentCategoryName = _categories[_selectedCategoryIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Bookings',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
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
                // Scrollable Category Tabs Header matching the 4 categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: _categories.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: _buildCategoryPill(entry.value, entry.key),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 4),

                // Bookings List
                Expanded(
                  child: currentList.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_note_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                                const SizedBox(height: 16),
                                Text(
                                  'No $currentCategoryName Bookings',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'You do not have any $currentCategoryName bookings at the moment.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: currentList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final booking = currentList[index];
                            final status = booking['status'] as String? ?? 'Confirmed';
                            final isCompleted = status == 'Completed';

                            return GestureDetector(
                              onTap: () {
                                if (_selectedCategoryIndex == 1) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RideConfirmedDetailScreen112()),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CustomerBookingDetailsScreen()),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3EDF7),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(booking['icon'] as IconData, color: AppColors.primary, size: 26),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            booking['title'],
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            booking['subtitle'],
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            booking['price'],
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? AppColors.primary.withValues(alpha: 0.1)
                                            : const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isCompleted ? AppColors.primary : const Color(0xFF2E7D32),
                                        ),
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

  Widget _buildCategoryPill(String label, int index) {
    final isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF3EDF7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
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
