import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/hotel_model.dart';
import 'property_detail_screen_62.dart';
import 'stay_filters_screen_43.dart';
import 'stay_map_search_screen_53.dart';

class StaySearchResultsScreen extends StatefulWidget {
  final String? destinationCity;
  final String? locationName;

  const StaySearchResultsScreen({
    super.key,
    this.destinationCity,
    this.locationName,
  });

  @override
  State<StaySearchResultsScreen> createState() => _StaySearchResultsScreenState();
}

class _StaySearchResultsScreenState extends State<StaySearchResultsScreen> {
  late List<Hotel> _hotels;

  @override
  void initState() {
    super.initState();
    if (widget.destinationCity != null && widget.destinationCity!.isNotEmpty) {
      final cityLower = widget.destinationCity!.toLowerCase();
      final filtered = mockHotels.where((h) =>
          h.city.toLowerCase().contains(cityLower) ||
          h.location.toLowerCase().contains(cityLower) ||
          (widget.locationName != null && h.description.toLowerCase().contains(widget.locationName!.toLowerCase()))
      ).toList();
      _hotels = filtered.isNotEmpty ? filtered : mockHotels;
    } else {
      _hotels = mockHotels;
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinationTitle = widget.locationName != null
        ? 'Stays near ${widget.locationName}'
        : (widget.destinationCity != null ? 'Hotels in ${widget.destinationCity}' : 'Hotels & Stays');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(destinationTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Explore ${_hotels.length} Accommodation Options', style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
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
                // Filter Chips Bar matching 45.png
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFilterChip(
                          icon: Icons.swap_vert_rounded,
                          label: 'Sort',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildFilterChip(
                          icon: Icons.filter_list_rounded,
                          label: 'Filter',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const StayFiltersScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildFilterChip(
                          icon: Icons.map_outlined,
                          label: 'Map',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const StayMapSearchScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Results 4 Dynamic Hotels matching 45.png
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    itemCount: _hotels.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final hotel = _hotels[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PropertyDetailScreen(hotel: hotel),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(8),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      width: 90,
                                      height: 80,
                                      color: const Color(0xFFF3EDF7),
                                      child: Image.asset(
                                        hotel.image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Center(
                                          child: Icon(Icons.hotel_rounded, color: AppColors.primary, size: 32),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Positioned(
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
                                    Text(
                                      hotel.title,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      hotel.location,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '₹${hotel.basePrice.toStringAsFixed(0)} / night',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7EC),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${hotel.rating}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
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

  Widget _buildFilterChip({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EDF7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.textPrimary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
