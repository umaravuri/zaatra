import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/hotel_model.dart';
import '../../../models/heritage_place_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/heritage_service.dart';
import 'property_detail_screen_62.dart';
import 'ride_search_map_screen_44.dart';
import 'stay_search_results_screen_45.dart';
import 'saved_favorites_screen_47.dart';
import 'customer_bookings_history_screen_43.dart';
import 'customer_profile_screen_44.dart';
import 'notifications_screen_52.dart';
import 'heritage_places_screen.dart';
import 'heritage_detail_screen.dart';

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
  bool _isFavoriteFalaknuma = false;
  final Set<int> _favoriteIndices = {};
  late String _displayName;
  HeritagePlace? _featuredHeritagePlace;
  List<HeritagePlace> _famousHeritagePlaces = [];

  @override
  void initState() {
    super.initState();
    _displayName = (widget.userName != null && widget.userName!.trim().isNotEmpty)
        ? widget.userName!.trim()
        : 'User';
    _loadUserName();
    _loadFeaturedHeritagePlace();
  }

  Future<void> _loadUserName() async {
    final name = await AuthService.getUserName(defaultFallback: 'User');
    if (mounted && name.isNotEmpty) {
      setState(() {
        _displayName = name;
      });
    }
  }

  Future<void> _loadFeaturedHeritagePlace() async {
    final famous = await HeritageService.getFamousPlaces();
    if (mounted && famous.isNotEmpty) {
      setState(() {
        _famousHeritagePlaces = famous;
        _featuredHeritagePlace = famous.first;
      });
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
                    // 1. Top Purple Header Section with 4 Service Cards matching 38.png
                    _buildTopHeader(),

                    // Main Body Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),

                          // 2. Recent Search Section matching 38.png
                          const Text(
                            'Recent Search',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildRecentSearchCard(),
                          const SizedBox(height: 12),
                          _buildRecentSearchCard(),

                          const SizedBox(height: 28),

                          // 3. Categories (Row 1) matching 38.png
                          _buildSectionHeader('Categories'),
                          const SizedBox(height: 14),
                          _buildCategoriesCarousel(offsetKey: 0),

                          const SizedBox(height: 28),

                          // 4. Categories (Row 2) matching 38.png
                          _buildSectionHeader('Categories'),
                          const SizedBox(height: 14),
                          _buildCategoriesCarousel(offsetKey: 10),

                          const SizedBox(height: 28),

                          // 5. Historical & historic Showcase matching 38.png
                          _buildSectionHeader(
                            'Historical & historic',
                            onSeeAll: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const HeritagePlacesScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildHistoricCard(),

                          const SizedBox(height: 28),

                          // 6. Reviews Section matching 38.png
                          const Text(
                            'Reviews',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildReviewsRow(),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 7. Bottom Navigation Bar matching 38.png
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF6C4CE8),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Profile Row
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
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
                        color: Colors.white.withValues(alpha: 0.15),
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

          const SizedBox(height: 18),

          // 4 Main Module Feature Cards (All 4 Side-by-Side in a Single Row)
          Row(
            children: [
              Expanded(
                child: _buildServiceCard(
                  title: 'Stay',
                  icon: Icons.domain_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StaySearchResultsScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildServiceCard(
                  title: 'Ride',
                  icon: Icons.electric_moped_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RideSearchMapScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildServiceCard(
                  title: 'Heritage',
                  icon: Icons.account_balance_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HeritagePlacesScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildServiceCard(
                  title: 'Banquet',
                  icon: Icons.celebration_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StaySearchResultsScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll ??
              () {
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
    );
  }

  Widget _buildRecentSearchCard() {
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
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/Rectangle 128.png',
                width: 95,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 95,
                  height: 80,
                  color: const Color(0xFFF3EDF7),
                  child: const Icon(Icons.villa_rounded, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'best luxury stay',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14),
                          SizedBox(width: 2),
                          Text('4.2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                      SizedBox(width: 3),
                      Text('Jaipur, Rajasthan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
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

  Widget _buildCategoriesCarousel({required int offsetKey}) {
    return SizedBox(
      height: 275,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final isFav = _favoriteIndices.contains(offsetKey + index);
          return Container(
            width: 190,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      child: Image.asset(
                        'assets/images/image 28.png',
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          color: const Color(0xFFF3EDF7),
                          child: const Center(
                            child: Icon(Icons.hotel_rounded, size: 36, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isFav) {
                              _favoriteIndices.remove(offsetKey + index);
                            } else {
                              _favoriteIndices.add(offsetKey + index);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                            color: isFav ? const Color(0xFFFF5252) : AppColors.textSecondary,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aranya Heritage Villa',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      const Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 11, color: AppColors.textSecondary),
                          SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              'Jaipur, Rajasthan',
                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '₹ 4,000 / night',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 10),
                                SizedBox(width: 2),
                                Text('4.2', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PropertyDetailScreen(hotel: mockHotels[0])),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Book Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoricCard() {
    if (_famousHeritagePlaces.length > 1) {
      return SizedBox(
        height: 310,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _famousHeritagePlaces.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final place = _famousHeritagePlaces[index];
            return _buildHistoricMonumentCard(place, width: 280);
          },
        ),
      );
    }

    final place = _featuredHeritagePlace;
    return _buildHistoricMonumentCard(place);
  }

  Widget _buildHistoricMonumentCard(HeritagePlace? place, {double? width}) {
    final title = place?.title ?? 'Taj Mahal';
    final city = place != null ? '${place.city}, ${place.state}' : 'Agra, Uttar Pradesh';
    final timings = place != null ? 'Opening ${place.timings.openTime} - ${place.timings.closeTime}' : 'Opening 06:00 AM - 06:30 PM';
    final rating = place != null ? place.rating.toStringAsFixed(1) : '5.0';
    final coverImg = place?.coverImage ?? 'https://images.unsplash.com/photo-1564507592333-c60657eea523?auto=format&fit=crop&w=800&q=80';
    final placeId = place?.placeId ?? 'HP-1003';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HeritageDetailScreen(
              placeId: placeId,
              initialPlace: place,
            ),
          ),
        );
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    coverImg,
                    height: 160,
                    width: width ?? double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/image 25.png',
                      height: 160,
                      width: width ?? double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: const Color(0xFFF3EDF7),
                        child: const Center(child: Icon(Icons.castle_rounded, color: AppColors.primary, size: 48)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isFavoriteFalaknuma = !_isFavoriteFalaknuma),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isFavoriteFalaknuma ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                            color: _isFavoriteFalaknuma ? const Color(0xFFFF5252) : AppColors.textSecondary,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 16),
                      ),
                    ],
                  ),
                ),
                if (place?.mustVisit == true || place?.isFeatured == true)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB800),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, size: 11, color: Colors.black87),
                          const SizedBox(width: 3),
                          Text(
                            place?.mustVisit == true ? 'Must Visit' : 'Featured',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C4CE8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    city,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          timings,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 12),
                            const SizedBox(width: 2),
                            Text(rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.explore_rounded, size: 12, color: Color(0xFF6C4CE8)),
                      SizedBox(width: 4),
                      Text(
                        'Tap to explore details & timings',
                        style: TextStyle(fontSize: 11, color: Color(0xFF6C4CE8), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildReviewPill(Icons.domain_rounded, 'Reviews'),
          const SizedBox(width: 12),
          _buildReviewPill(Icons.electric_moped_rounded, 'Reviews'),
          const SizedBox(width: 12),
          _buildReviewPill(Icons.account_balance_rounded, 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildReviewPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6C4CE8).withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6C4CE8)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C4CE8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedFavoritesScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerBookingsHistoryScreen()));
          } else if (index == 3) {
            // Message / Chat tab
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No new messages.'), duration: Duration(seconds: 1)),
            );
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
            icon: Icon(Icons.favorite_outline_rounded),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Message',
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
