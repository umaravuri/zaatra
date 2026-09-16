import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/hotel_model.dart';
import '../../../services/auth_service.dart';
import 'property_detail_screen_62.dart';
import 'ride_search_screen_42.dart';
import 'stay_search_results_screen_45.dart';
import 'saved_favorites_screen_47.dart';
import 'customer_bookings_history_screen_43.dart';
import 'customer_profile_screen_44.dart';
import 'notifications_screen_52.dart';

class CustomerHomeScreen extends StatefulWidget {
  final String? userName;

  const CustomerHomeScreen({
    super.key,
    this.userName,
  });

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentNavIndex = 0;
  bool _isFavoriteRecommended = false;
  late String _displayName;

  @override
  void initState() {
    super.initState();
    _displayName = (widget.userName != null && widget.userName!.trim().isNotEmpty && widget.userName != 'Manohar')
        ? widget.userName!.trim()
        : 'User';
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    if (widget.userName == null || widget.userName!.trim().isEmpty || widget.userName == 'Manohar') {
      final name = await AuthService.getUserName(defaultFallback: 'User');
      if (mounted && name.isNotEmpty) {
        setState(() {
          _displayName = name;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Purple Header Section matching 38.png
                    _buildTopHeader(),

                    // Main Content Body
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),

                          // Categories Section matching 38.png
                          const Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildCategoriesRow(),

                          const SizedBox(height: 28),

                          // Recommended Stay Section matching 38.png
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recommended Stay',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const StaySearchResultsScreen()),
                                  );
                                },
                                child: const Text(
                                  'See all',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildRecommendedStayCard(),

                          const SizedBox(height: 28),

                          // Heritage Stays Section matching 38.png
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'heritage stays',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const StaySearchResultsScreen()),
                                  );
                                },
                                child: const Text(
                                  'See all',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildHeritageStayCard(),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar matching 38.png
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          decoration: const BoxDecoration(
            color: Color(0xFF6C4CE8),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // User Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/image 27.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Hello, $_displayName',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('👋', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Good Morning !',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  // Notification Bell with Badge
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CustomerNotificationsScreen()),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF3B30),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // Floating Search Bar matching 38.png
        Positioned(
          left: 20,
          right: 20,
          bottom: -22,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Search here',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.tune_rounded, color: Color(0xFF6C4CE8), size: 20),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategoryItem(
          icon: Icons.domain_rounded,
          label: 'Stay',
          iconColor: const Color(0xFF6C4CE8),
          bgColor: const Color(0xFFF3EDF7),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StaySearchResultsScreen()),
            );
          },
        ),
        _buildCategoryItem(
          icon: Icons.electric_moped_rounded,
          label: 'Ride',
          iconColor: const Color(0xFFE040FB),
          bgColor: const Color(0xFFFDEBFF),
          onTap: () {
            // 👉 User requested: When he clicks ride, go to Screen 42
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RideSearchScreen()),
            );
          },
        ),
        _buildCategoryItem(
          icon: Icons.account_balance_rounded,
          label: "Heritage's",
          iconColor: const Color(0xFF7C4DFF),
          bgColor: const Color(0xFFEDE7F6),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PropertyDetailScreen(hotel: mockHotels[2])),
            );
          },
        ),
        _buildCategoryItem(
          icon: Icons.local_offer_rounded,
          label: 'Offers',
          iconColor: const Color(0xFFFF5252),
          bgColor: const Color(0xFFFFEBEE),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 30),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedStayCard() {
    final hotel = mockHotels[2]; // Aranya Heritage Haveli

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image with Superhot tag & heart
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  hotel.image,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: const Color(0xFFF3EDF7),
                    child: const Center(child: Icon(Icons.hotel_rounded, size: 48, color: AppColors.primary)),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Superhot',
                    style: TextStyle(
                      color: Color(0xFFFF5252),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => setState(() => _isFavoriteRecommended = !_isFavoriteRecommended),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFavoriteRecommended ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                      color: const Color(0xFFFF5252),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Details Row matching 38.png
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            hotel.location,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹ ${hotel.basePrice.toStringAsFixed(0)} / night',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14),
                          const SizedBox(width: 3),
                          Text(
                            '${hotel.rating}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PropertyDetailScreen(hotel: hotel),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(90, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Book Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeritageStayCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PropertyDetailScreen(hotel: mockHotels[2])),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/Rectangle 128.png',
                width: 100,
                height: 85,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 85,
                  color: const Color(0xFFF3EDF7),
                  child: const Icon(Icons.villa_rounded, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'best luxury stay',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14),
                          SizedBox(width: 2),
                          Text('4.2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                      SizedBox(width: 3),
                      Text('Jaipur, Rajasthan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'A 174 Years-old heritage haveli in royal stay',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const StaySearchResultsScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerBookingsHistoryScreen()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedFavoritesScreen()));
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerProfileScreen()));
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6C4CE8),
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline_rounded),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
