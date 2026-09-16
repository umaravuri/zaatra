import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/hotel_model.dart';
import '../../widgets/custom_button.dart';
import 'select_room_screen_54.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Hotel? hotel;

  const PropertyDetailScreen({super.key, this.hotel});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isFavorite = true;

  Hotel get _activeHotel => widget.hotel ?? mockHotels[0];

  IconData _getAmenityIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('wi-fi') || lower.contains('wifi')) return Icons.wifi_rounded;
    if (lower.contains('tv')) return Icons.tv_rounded;
    if (lower.contains('kitchen')) return Icons.soup_kitchen_rounded;
    if (lower.contains('parking')) return Icons.local_parking_rounded;
    if (lower.contains('pool')) return Icons.pool_rounded;
    if (lower.contains('ac')) return Icons.ac_unit_rounded;
    if (lower.contains('hot water')) return Icons.hot_tub_rounded;
    if (lower.contains('breakfast')) return Icons.free_breakfast_rounded;
    if (lower.contains('restaurant') || lower.contains('dining') || lower.contains('lunch')) return Icons.restaurant_rounded;
    if (lower.contains('bar') || lower.contains('mini bar')) return Icons.local_bar_rounded;
    if (lower.contains('butler') || lower.contains('room service')) return Icons.room_service_rounded;
    if (lower.contains('garden') || lower.contains('nature')) return Icons.nature_people_rounded;
    if (lower.contains('beach')) return Icons.beach_access_rounded;
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final hotel = _activeHotel;

    return Scaffold(
      backgroundColor: Colors.white,
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Hero Banner Image matching 62.png
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                              child: Container(
                                height: 280,
                                width: double.infinity,
                                color: const Color(0xFFF3EDF7),
                                child: Image.asset(
                                  hotel.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.hotel_rounded, size: 64, color: AppColors.primary),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 16,
                              left: 16,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Colors.black12, blurRadius: 6),
                                    ],
                                  ),
                                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 16,
                              right: 16,
                              child: GestureDetector(
                                onTap: () => setState(() => _isFavorite = !_isFavorite),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Colors.black12, blurRadius: 6),
                                    ],
                                  ),
                                  child: Icon(
                                    _isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      hotel.title,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 20),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${hotel.rating}',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(hotel.location, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),

                              const SizedBox(height: 20),

                              // Description Box
                              Text(
                                hotel.description,
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                              ),

                              const SizedBox(height: 24),

                              // 4 Spec Circles Row matching 62.png
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildSpecCircle(Icons.person_rounded, hotel.specs.guests),
                                  _buildSpecCircle(Icons.face_rounded, hotel.specs.kids),
                                  _buildSpecCircle(Icons.king_bed_rounded, hotel.specs.beds),
                                  _buildSpecCircle(Icons.bathtub_rounded, hotel.specs.baths),
                                ],
                              ),

                              const SizedBox(height: 28),

                              // Amenities Section Grid matching 62.png
                              const Text(
                                'Amenities',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 16),

                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: hotel.amenities.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 1.2,
                                ),
                                itemBuilder: (context, index) {
                                  final amenity = hotel.amenities[index];
                                  return Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(_getAmenityIcon(amenity), color: AppColors.textPrimary, size: 22),
                                        const SizedBox(height: 6),
                                        Text(
                                          amenity,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Sticky Bar matching 62.png
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 10, offset: const Offset(0, -4)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '₹ ${hotel.basePrice.toStringAsFixed(0)} / night',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          const Text('Starting price', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      SizedBox(
                        width: 160,
                        child: CustomButton(
                          text: 'Book Now',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SelectRoomScreen(hotel: hotel),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecCircle(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: const BoxDecoration(
            color: Color(0xFFF3EDF7),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, color: AppColors.textPrimary, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
