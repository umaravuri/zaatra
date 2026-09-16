import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomerBookingsHistoryScreen extends StatefulWidget {
  const CustomerBookingsHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CustomerBookingsHistoryScreen> createState() => _CustomerBookingsHistoryScreenState();
}

class _CustomerBookingsHistoryScreenState extends State<CustomerBookingsHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Trips & Bookings'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Active (2)'),
            Tab(text: 'Completed (8)'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Tab
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildBookingCard(
                type: 'HOTEL STAY',
                title: 'Grand Zaatra Resort & Spa',
                subtitle: '25 Aug - 28 Aug • 3 Nights (2 Adults)',
                price: '\$455.00',
                status: 'Confirmed ✅',
                icon: Icons.apartment_rounded,
                statusColor: AppColors.success,
              ),
              _buildBookingCard(
                type: 'RIDE BOOKING',
                title: 'Gulshan 2 ➔ Banani Model Town',
                subtitle: 'Driver: Sarah Ahmed (Zaatra Comfort)',
                price: '\$22.00',
                status: 'Arriving in 3m ⏳',
                icon: Icons.directions_car_rounded,
                statusColor: AppColors.accent,
              ),
            ],
          ),

          // Completed Tab
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildBookingCard(
                type: 'RIDE BOOKING',
                title: 'Dhanmondi 32 ➔ Airport Terminal 2',
                subtitle: '15 Aug 2026 • 14.2 km',
                price: '\$38.00',
                status: 'Completed',
                icon: Icons.directions_car_rounded,
                statusColor: AppColors.primary,
              ),
              _buildBookingCard(
                type: 'HOTEL STAY',
                title: 'Zaatra Heritage Boutique Hotel',
                subtitle: '01 Aug - 03 Aug • 2 Nights',
                price: '\$190.00',
                status: 'Completed',
                icon: Icons.domain_rounded,
                statusColor: AppColors.primary,
              ),
            ],
          ),

          // Cancelled Tab
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildBookingCard(
                type: 'RIDE BOOKING',
                title: 'Uttara 7 ➔ Farmgate',
                subtitle: '20 Jul 2026 • Cancelled by user',
                price: '\$0.00',
                status: 'Cancelled',
                icon: Icons.directions_car_rounded,
                statusColor: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard({
    required String type,
    required String title,
    required String subtitle,
    required String price,
    required String status,
    required IconData icon,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(type, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
              Text(status, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: statusColor)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.inputBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}
