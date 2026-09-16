import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_image_placeholder.dart';
import 'host_my_property_list_screen_63.dart';
import 'host_bookings_list_screen_64.dart';
import 'host_earnings_analytics_screen_69.dart';
import 'host_more_menu_screen_68.dart';
import 'host_ratings_reviews_screen_114.dart';
import 'host_add_property_step1_71.dart';

import '../../../services/auth_service.dart';

class HostHomeDashboardScreen extends StatefulWidget {
  final String? userName;
  const HostHomeDashboardScreen({Key? key, this.userName}) : super(key: key);

  @override
  State<HostHomeDashboardScreen> createState() => _HostHomeDashboardScreenState();
}

class _HostHomeDashboardScreenState extends State<HostHomeDashboardScreen> {
  int _currentIndex = 0;
  String _hostName = '';

  @override
  void initState() {
    super.initState();
    _resolveHostName();
  }

  void _resolveHostName() async {
    if (widget.userName != null && widget.userName!.trim().isNotEmpty) {
      if (mounted) setState(() => _hostName = widget.userName!.trim());
      return;
    }
    final name = await AuthService.getUserName();
    if (mounted) setState(() => _hostName = name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HostAddPropertyStep1Screen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_home_work_rounded, color: Colors.white),
        label: const Text('Add Property', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(context),
            const HostBookingsListScreen(),
            const HostMyPropertyListScreen(),
            const HostEarningsAnalyticsScreen(),
            HostMoreMenuScreen(userName: _hostName),
          ],
        ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.maps_home_work_rounded), label: 'Property'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time_rounded), label: 'Earning'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz_rounded), label: 'More'),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row matching 37.png
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/zaatra_location_bg.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Hello, ${_hostName.isNotEmpty ? _hostName : 'Host'} ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const Text('👋', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text('Good Morning !', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 26),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stats Cards Row matching 37.png
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Earnings', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      const Text('₹ 1,24,256', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('+12.9% This Month', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDF7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Occupancy', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      const Text('78%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('+8% this month', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Update Section matching 37.png
          const Text('Recent Update', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRecentUpdateItem(context, Icons.home_rounded, 'Property', '06', () {
                setState(() => _currentIndex = 2);
              }),
              _buildRecentUpdateItem(context, Icons.calendar_month_rounded, 'Active Bookings', '12', () {
                setState(() => _currentIndex = 1);
              }),
              _buildRecentUpdateItem(context, Icons.star_rounded, 'Reviews', '4.8', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HostRatingsReviewsScreen()));
              }),
            ],
          ),

          const SizedBox(height: 28),

          // Revenue overview Section matching 37.png
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Revenue overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EDF7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Text('This Month', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Wave Chart Mockup Container matching 37.png
          Container(
            height: 160,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              painter: _RevenueWavePainter(),
            ),
          ),

          const SizedBox(height: 24),

          // Recent Bookings Section matching 37.png
          const Text('Recent Bookings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const CustomImagePlaceholder(
                  width: 90,
                  height: 65,
                  icon: Icons.villa_rounded,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('See view Villa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      const Text('20 May - 24 May', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      const Text('Conform', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                    ],
                  ),
                ),
                const Text('₹ 24,000', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUpdateItem(BuildContext context, IconData icon, String label, String count, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EDF7),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(count, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _RevenueWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8DEF8)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..cubicTo(size.width * 0.25, size.height * 0.4, size.width * 0.5, size.height * 0.8, size.width * 0.75, size.height * 0.3)
      ..cubicTo(size.width * 0.85, size.height * 0.2, size.width * 0.95, size.height * 0.1, size.width, size.height * 0.2)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
