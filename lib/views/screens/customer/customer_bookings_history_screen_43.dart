import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/customer_booking_model.dart';
import '../../../services/booking_service.dart';
import 'booking_details_screen_49.dart';
import 'customer_home_screen_38.dart';
import 'heritage_places_screen.dart';
import 'ride_confirmed_detail_screen_112.dart';
import 'ride_search_map_screen_44.dart';
import 'stay_search_results_screen_45.dart';

class CustomerBookingsHistoryScreen extends StatefulWidget {
  final String? initialCategory;

  const CustomerBookingsHistoryScreen({
    super.key,
    this.initialCategory,
  });

  @override
  State<CustomerBookingsHistoryScreen> createState() => _CustomerBookingsHistoryScreenState();
}

class _CustomerBookingsHistoryScreenState extends State<CustomerBookingsHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categories = const [
    'Stay',
    'Ride',
    'Heritage Sites',
    'Banquet Halls',
  ];

  final Map<String, List<CustomerBookingItem>> _bookingsByCategory = {
    'Stay': [],
    'Ride': [],
    'Heritage Sites': [],
    'Banquet Halls': [],
  };

  final Map<String, bool> _isLoadingCategory = {
    'Stay': true,
    'Ride': true,
    'Heritage Sites': true,
    'Banquet Halls': true,
  };

  @override
  void initState() {
    super.initState();
    int initialIndex = 0;
    if (widget.initialCategory != null) {
      final idx = _categories.indexWhere(
        (c) => c.toLowerCase() == widget.initialCategory!.toLowerCase(),
      );
      if (idx != -1) initialIndex = idx;
    }

    _tabController = TabController(
      length: _categories.length,
      vsync: this,
      initialIndex: initialIndex,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final category = _categories[_tabController.index];
      if (_bookingsByCategory[category]?.isEmpty ?? true) {
        _fetchCategoryBookings(category);
      }
    });

    _fetchAllBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllBookings() async {
    for (final category in _categories) {
      _fetchCategoryBookings(category);
    }
  }

  Future<void> _fetchCategoryBookings(String category) async {
    setState(() {
      _isLoadingCategory[category] = true;
    });

    try {
      final items = await BookingService.getCustomerBookings(category: category);
      if (mounted) {
        setState(() {
          _bookingsByCategory[category] = items;
          _isLoadingCategory[category] = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingCategory[category] = false;
        });
      }
    }
  }

  void _onBookingTapped(CustomerBookingItem booking) {
    if (booking.category == 'Ride') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RideConfirmedDetailScreen112(
            bookingId: booking.id.isNotEmpty ? booking.id : booking.bookingId,
            bookingData: booking.rawJson,
          ),
        ),
      );
    } else if (booking.category == 'Stay') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomerBookingDetailsScreen(),
        ),
      );
    } else if (booking.category == 'Heritage Sites') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HeritagePlacesScreen(),
        ),
      );
    } else {
      // Banquet Halls
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomerBookingDetailsScreen(),
        ),
      );
    }
  }

  void _navigateToExploreCategory(String category) {
    if (category == 'Ride') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RideSearchMapScreen()),
      );
    } else if (category == 'Stay') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StaySearchResultsScreen()),
      );
    } else if (category == 'Heritage Sites') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HeritagePlacesScreen()),
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Bookings',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () {
              final activeCategory = _categories[_tabController.index];
              _fetchCategoryBookings(activeCategory);
            },
          ),
          IconButton(
            icon: const Icon(Icons.home_rounded, color: AppColors.primary),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              tabs: _categories.map((category) => Tab(text: category)).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((category) {
          return _buildCategoryTabContent(category);
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryTabContent(String category) {
    final isLoading = _isLoadingCategory[category] ?? false;
    final bookings = _bookingsByCategory[category] ?? [];

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Loading bookings...',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _fetchCategoryBookings(category),
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event_note_outlined,
                      size: 56,
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'No $category Bookings',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You do not have any $category bookings at the moment.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToExploreCategory(category),
                    icon: const Icon(Icons.explore_outlined, size: 18, color: Colors.white),
                    label: Text(
                      'Explore $category',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchCategoryBookings(category),
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(CustomerBookingItem booking) {
    return InkWell(
      onTap: () => _onBookingTapped(booking),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.type,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: booking.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: booking.statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDF7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(booking.icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.subtitle,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  booking.price,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.primary,
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
