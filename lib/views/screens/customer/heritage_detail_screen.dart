import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/heritage_place_model.dart';
import '../../../models/hotel_model.dart';
import '../../../services/heritage_service.dart';
import 'property_detail_screen_62.dart';
import 'ride_search_screen_42.dart';

class HeritageDetailScreen extends StatefulWidget {
  final String placeId;
  final HeritagePlace? initialPlace;

  const HeritageDetailScreen({
    super.key,
    required this.placeId,
    this.initialPlace,
  });

  @override
  State<HeritageDetailScreen> createState() => _HeritageDetailScreenState();
}

class _HeritageDetailScreenState extends State<HeritageDetailScreen> {
  HeritagePlace? _place;
  List<Hotel> _nearbyHotels = [];
  bool _isLoading = true;
  bool _isLoadingHotels = true;
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPlace != null) {
      _place = widget.initialPlace;
      _isLoading = false;
      if (widget.initialPlace!.nearbyProperties.isNotEmpty) {
        _nearbyHotels = widget.initialPlace!.nearbyProperties;
        _isLoadingHotels = false;
      } else {
        _loadNearbyHotels(widget.initialPlace!);
      }
    }
    _loadPlaceDetails();
  }

  Future<void> _loadPlaceDetails() async {
    final fetched = await HeritageService.getPlaceDetails(widget.placeId);
    if (mounted && fetched != null) {
      setState(() {
        _place = fetched;
        _isLoading = false;
        if (fetched.nearbyProperties.isNotEmpty) {
          _nearbyHotels = fetched.nearbyProperties;
          _isLoadingHotels = false;
        }
      });
      if (fetched.nearbyProperties.isEmpty) {
        _loadNearbyHotels(fetched);
      }
    } else if (mounted) {
      setState(() => _isLoading = false);
      if (_place != null && _nearbyHotels.isEmpty) {
        _loadNearbyHotels(_place!);
      }
    }
  }

  Future<void> _loadNearbyHotels(HeritagePlace place) async {
    final hotels = await HeritageService.getNearbyHotels(
      city: place.city,
      placeId: place.placeId,
    );
    if (mounted) {
      setState(() {
        _nearbyHotels = hotels;
        _isLoadingHotels = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _place == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Heritage Monument', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final place = _place!;
    final allImages = <String>[];
    if (place.coverImage.isNotEmpty) {
      allImages.add(place.coverImage);
    }
    for (final img in place.images) {
      if (!allImages.contains(img)) {
        allImages.add(img);
      }
    }
    if (allImages.isEmpty) {
      allImages.add('https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=800&q=80');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: CustomScrollView(
        slivers: [
          // 1. Collapsible Hero Header with Photo Gallery
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: const Color(0xFF6C4CE8),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                      color: _isFavorite ? const Color(0xFFFF4B4B) : Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _isFavorite = !_isFavorite);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isFavorite ? 'Saved to Favorites ❤️' : 'Removed from Favorites'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: '${place.title} - ${place.address}'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Monument details copied to clipboard! 📋')),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: allImages.length,
                    onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                    itemBuilder: (context, idx) {
                      return Image.network(
                        allImages[idx],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF6C4CE8),
                          child: const Center(
                            child: Icon(Icons.account_balance_rounded, size: 64, color: Colors.white54),
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Gallery Page Indicator
                  if (allImages.length > 1)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${allImages.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  // Must Visit / Featured Badge
                  if (place.mustVisit || place.isFeatured)
                    Positioned(
                      top: 60,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB800),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded, size: 14, color: Colors.black87),
                            const SizedBox(width: 4),
                            Text(
                              place.mustVisit ? 'Must Visit' : 'Featured',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 2. Main Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & ID Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EDF7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF6C4CE8).withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          place.category,
                          style: const TextStyle(
                            color: Color(0xFF6C4CE8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (place.placeId.isNotEmpty)
                        Text(
                          place.placeId,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title & Tagline
                  Text(
                    place.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (place.tagline.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      place.tagline,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Rating & Location Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              place.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${place.reviewsCount} reviews)',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF6C4CE8)),
                      const SizedBox(width: 4),
                      Text(
                        '${place.city}, ${place.state}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C4CE8),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // 3. Timings & Visiting Schedule Card
                  _buildSectionHeader('Timings & Visiting Hours', Icons.access_time_rounded),
                  const SizedBox(height: 12),
                  _buildTimingsCard(place.timings),

                  const SizedBox(height: 24),

                  // 4. Entry Fees Structure Card
                  _buildSectionHeader('Entry Fee & Pricing', Icons.monetization_on_rounded),
                  const SizedBox(height: 12),
                  _buildEntryFeeCard(place.entryFee),

                  // 5. Famous Highlights (if available)
                  if (place.famousHighlights.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader('Famous Highlights', Icons.stars_rounded),
                    const SizedBox(height: 12),
                    _buildHighlightsCard(place.famousHighlights),
                  ],

                  // 6. About & History
                  if (place.description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader('About Monument', Icons.info_outline_rounded),
                    const SizedBox(height: 10),
                    Text(
                      place.description,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                    ),
                  ],

                  if (place.history.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSectionHeader('Historical Background', Icons.history_edu_rounded),
                    const SizedBox(height: 10),
                    Text(
                      place.history,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                    ),
                  ],

                  if (place.architectureDetails.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSectionHeader('Architecture & Design', Icons.architecture_rounded),
                    const SizedBox(height: 10),
                    Text(
                      place.architectureDetails,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                    ),
                  ],

                  if (place.significance.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSectionHeader('Cultural Significance', Icons.flag_rounded),
                    const SizedBox(height: 10),
                    Text(
                      place.significance,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                    ),
                  ],

                  // 7. Visitor Guidelines
                  if (place.guidelines.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader('Visitor Guidelines & Tips', Icons.rule_rounded),
                    const SizedBox(height: 12),
                    _buildGuidelinesCard(place.guidelines),
                  ],

                  // 8. Address & Map
                  const SizedBox(height: 24),
                  _buildSectionHeader('Address & Location', Icons.map_rounded),
                  const SizedBox(height: 12),
                  _buildAddressCard(place),

                  // 9. Stay Nearby Section (All hotels in this heritage place's city)
                  const SizedBox(height: 24),
                  _buildNearbyStaysSection(place),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // 10. Sticky Bottom Navigation Bar with Primary Ride Booking CTA
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final destinationQuery = place.city.isNotEmpty
                    ? '${place.title}, ${place.city}'
                    : place.title;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RideSearchScreen(
                      initialDestination: destinationQuery,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.directions_car_rounded, size: 20),
              label: const Text(
                'Book Ride to Destination',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C4CE8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6C4CE8)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimingsCard(HeritageTimings timings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildInfoColumn('Opening Hours', '${timings.openTime} - ${timings.closeTime}', Icons.schedule_rounded),
              Container(height: 36, width: 1, color: AppColors.border),
              _buildInfoColumn('Open Days', timings.openDays, Icons.calendar_today_rounded),
            ],
          ),
          if (timings.bestTimeToVisit.isNotEmpty || timings.averageVisitDuration.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            if (timings.bestTimeToVisit.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.wb_sunny_rounded, size: 16, color: Color(0xFFFFB800)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Best Time: ${timings.bestTimeToVisit}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            if (timings.averageVisitDuration.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF6C4CE8)),
                  const SizedBox(width: 8),
                  Text(
                    'Avg. Duration: ${timings.averageVisitDuration}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryFeeCard(HeritageEntryFee fee) {
    if (fee.isFreeEntry) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF81C784)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 22),
            SizedBox(width: 10),
            Text('Free Entry for all visitors 🎉', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFeeItem('Domestic', '₹${fee.domestic.toStringAsFixed(0)}'),
              _buildFeeItem('Foreigner', '₹${fee.foreigner.toStringAsFixed(0)}'),
              _buildFeeItem('Children', fee.children > 0 ? '₹${fee.children.toStringAsFixed(0)}' : 'Free'),
              if (fee.cameraFee > 0)
                _buildFeeItem('Camera', '₹${fee.cameraFee.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeeItem(String title, String price) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(price, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
      ],
    );
  }

  Widget _buildHighlightsCard(List<String> highlights) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: highlights.map((hl) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB800)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hl,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.3),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGuidelinesCard(List<String> guidelines) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFF59D)),
      ),
      child: Column(
        children: guidelines.map((rule) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_rounded, size: 16, color: Color(0xFFF57F17)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    rule,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF37474F), height: 1.3),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddressCard(HeritagePlace place) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_pin, color: Color(0xFF6C4CE8), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  place.address.isNotEmpty ? place.address : '${place.title}, ${place.city}, ${place.state}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: place.address));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Address copied! 📋')),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF6C4CE8)),
                label: const Text('Copy Address', style: TextStyle(color: Color(0xFF6C4CE8), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: place.mapLocation.googleMapsUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Google Maps location copied! 🗺️')),
                  );
                },
                icon: const Icon(Icons.map_rounded, size: 16, color: Color(0xFF6C4CE8)),
                label: const Text('Map Link', style: TextStyle(color: Color(0xFF6C4CE8), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 9. Nearby Stays Section Widget
  Widget _buildNearbyStaysSection(HeritagePlace place) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('Stay Nearby', Icons.hotel_rounded),
            if (!_isLoadingHotels && _nearbyHotels.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EDF7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_nearbyHotels.length} ${place.city.isNotEmpty ? "in ${place.city}" : "Available"}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C4CE8),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Top-rated hotels, heritage stays & resorts near ${place.title}',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        if (_isLoadingHotels)
          Container(
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const CircularProgressIndicator(color: Color(0xFF6C4CE8)),
          )
        else if (_nearbyHotels.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.hotel_outlined, size: 40, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  'No listed stays near ${place.city}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Explore other city accommodations from the main Stays search.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(
            children: _nearbyHotels.map((hotel) => _buildHotelCard(hotel)).toList(),
          ),
      ],
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PropertyDetailScreen(hotel: hotel),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel Thumbnail Image with Rating Badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: hotel.image.startsWith('assets/')
                          ? Image.asset(
                              hotel.image,
                              width: 100,
                              height: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 100,
                                height: 110,
                                color: const Color(0xFFF3EDF7),
                                child: const Icon(Icons.hotel_rounded, color: Color(0xFF6C4CE8)),
                              ),
                            )
                          : Image.network(
                              hotel.image,
                              width: 100,
                              height: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 100,
                                height: 110,
                                color: const Color(0xFFF3EDF7),
                                child: const Icon(Icons.hotel_rounded, color: Color(0xFF6C4CE8)),
                              ),
                            ),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 12),
                            const SizedBox(width: 2),
                            Text(
                              hotel.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Property Type, Distance badge & Review count
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3EDF7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              hotel.type,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C4CE8),
                              ),
                            ),
                          ),
                          if (hotel.distanceFormatted != null && hotel.distanceFormatted!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.near_me_rounded, size: 9, color: Color(0xFF2E7D32)),
                                  const SizedBox(width: 2),
                                  Text(
                                    hotel.distanceFormatted!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            '${hotel.reviewCount} reviews',
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Hotel Title
                      Text(
                        hotel.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Location text
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              hotel.location,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Amenities / Specs
                      Text(
                        '${hotel.specs.guests} • ${hotel.amenities.take(2).join(" • ")}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Price & Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '₹${hotel.basePrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                                const TextSpan(
                                  text: ' / night',
                                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C4CE8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'View Stay',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
