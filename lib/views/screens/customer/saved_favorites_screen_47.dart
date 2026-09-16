import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SavedFavoritesScreen extends StatefulWidget {
  const SavedFavoritesScreen({Key? key}) : super(key: key);

  @override
  State<SavedFavoritesScreen> createState() => _SavedFavoritesScreenState();
}

class _SavedFavoritesScreenState extends State<SavedFavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved & Favorites'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Favorite Hotels (2)'),
            Tab(text: 'Saved Places (3)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Favorite Hotels Tab
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildHotelFavoriteTile(
                title: 'Grand Zaatra Resort & Spa',
                location: 'Cox\'s Bazar • 4.9⭐',
                price: '\$140 / night',
                icon: Icons.apartment_rounded,
              ),
              _buildHotelFavoriteTile(
                title: 'Zaatra Luxury Beach Villa',
                location: 'Inani Beach • 4.8⭐',
                price: '\$210 / night',
                icon: Icons.holiday_village_rounded,
              ),
            ],
          ),

          // Saved Places Tab
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildPlaceFavoriteTile(
                title: 'Home',
                address: 'Gulshan 2, Avenue 4, Dhaka',
                icon: Icons.home_rounded,
              ),
              _buildPlaceFavoriteTile(
                title: 'Office',
                address: 'Banani Model Town, Block D',
                icon: Icons.work_rounded,
              ),
              _buildPlaceFavoriteTile(
                title: 'Airport',
                address: 'Hazrat Shahjalal Int. Airport',
                icon: Icons.flight_takeoff_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHotelFavoriteTile({required String title, required String location, required String price, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: AppColors.primaryBackground, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(location, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPlaceFavoriteTile({required String title, required String address, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: AppColors.inputBackground, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(address, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.bookmark_remove_rounded, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}
