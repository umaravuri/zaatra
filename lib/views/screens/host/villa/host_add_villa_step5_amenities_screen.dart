import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import 'host_add_villa_step6_rules_screen.dart';

class HostAddVillaStep5AmenitiesScreen extends StatefulWidget {
  final String villaName;
  final int bedrooms;
  final int bathrooms;
  final String formattedAddress;
  final String description;
  final String selectedCategory;

  const HostAddVillaStep5AmenitiesScreen({
    Key? key,
    required this.villaName,
    required this.bedrooms,
    required this.bathrooms,
    required this.formattedAddress,
    required this.description,
    this.selectedCategory = 'Villa',
  }) : super(key: key);

  @override
  State<HostAddVillaStep5AmenitiesScreen> createState() => _HostAddVillaStep5AmenitiesScreenState();
}

class _HostAddVillaStep5AmenitiesScreenState extends State<HostAddVillaStep5AmenitiesScreen> {
  // Amenities selection
  final Set<String> _selectedAmenities = {};

  // Comprehensive Amenities List including all standard & High-End Villa Amenities
  final List<Map<String, dynamic>> _villaAmenitiesList = [
    // High-End Villa Amenities
    {'title': 'Private Pool', 'icon': Icons.pool_rounded, 'isPremium': true},
    {'title': 'Clubhouse', 'icon': Icons.holiday_village_rounded, 'isPremium': true},
    {'title': 'Modular Kitchen', 'icon': Icons.soup_kitchen_rounded, 'isPremium': true},
    {'title': 'Private Lawn', 'icon': Icons.grass_rounded, 'isPremium': true},
    {'title': 'Jacuzzi', 'icon': Icons.hot_tub_rounded, 'isPremium': true},
    {'title': 'BBQ Grill', 'icon': Icons.outdoor_grill_rounded, 'isPremium': true},
    {'title': 'Home Theatre', 'icon': Icons.movie_filter_rounded, 'isPremium': true},
    {'title': 'Game Lounge', 'icon': Icons.sports_esports_rounded, 'isPremium': true},
    {'title': 'Power Backup', 'icon': Icons.bolt_rounded, 'isPremium': true},
    {'title': '24/7 Security', 'icon': Icons.security_rounded, 'isPremium': true},
    {'title': 'Bonfire Pit', 'icon': Icons.local_fire_department_rounded, 'isPremium': true},
    {'title': 'Chef on Demand', 'icon': Icons.restaurant_menu_rounded, 'isPremium': true},

    // Standard Property Amenities
    {'title': 'Wi-Fi', 'icon': Icons.wifi_rounded, 'isPremium': false},
    {'title': 'Tv', 'icon': Icons.tv_rounded, 'isPremium': false},
    {'title': 'AC', 'icon': Icons.ac_unit_rounded, 'isPremium': false},
    {'title': 'Parking', 'icon': Icons.local_parking_rounded, 'isPremium': false},
    {'title': 'Washing', 'icon': Icons.local_laundry_service_rounded, 'isPremium': false},
    {'title': 'Hot water', 'icon': Icons.water_drop_rounded, 'isPremium': false},
    {'title': 'Break fast', 'icon': Icons.free_breakfast_rounded, 'isPremium': false},
    {'title': 'Lunch', 'icon': Icons.restaurant_rounded, 'isPremium': false},
    {'title': 'Mini Bar', 'icon': Icons.wine_bar_rounded, 'isPremium': false},
    {'title': 'Balcony', 'icon': Icons.balcony_rounded, 'isPremium': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: const [
            Text('Add new property', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
            SizedBox(height: 2),
            Text('Set 5 by 9 (Villa Flow)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
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
                _buildProgressBar(5),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Villa Amenities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Select luxury & high-end amenities available at your villa', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 22),

                        // Section 1: High-End Luxury Villa Amenities
                        Row(
                          children: const [
                            Icon(Icons.stars_rounded, color: AppColors.primary, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'High-End Villa Amenities',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _buildAmenityGrid(_villaAmenitiesList.where((a) => a['isPremium'] == true).toList()),

                        const SizedBox(height: 24),

                        // Section 2: General Property Amenities
                        Row(
                          children: const [
                            Icon(Icons.check_circle_outline_rounded, color: AppColors.textSecondary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'General & Essential Amenities',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _buildAmenityGrid(_villaAmenitiesList.where((a) => a['isPremium'] == false).toList()),

                        const SizedBox(height: 24),

                        // Selected Amenities Summary Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9FB),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE8DEF8)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Amenities (${_selectedAmenities.length})',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 12),
                              if (_selectedAmenities.isEmpty)
                                const Text('No amenities selected.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
                              else
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _selectedAmenities.map((item) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3EDF7),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            item,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                          ),
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () => setState(() => _selectedAmenities.remove(item)),
                                            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.primary),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Back',
                          isOutlined: true,
                          backgroundColor: Colors.white,
                          textColor: AppColors.primary,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CustomButton(
                          text: 'Next',
                          onPressed: () {
                            if (_selectedAmenities.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select at least 1 amenity for your villa.'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HostAddVillaStep6RulesScreen(
                                  villaName: widget.villaName,
                                  bedrooms: widget.bedrooms,
                                  bathrooms: widget.bathrooms,
                                  formattedAddress: widget.formattedAddress,
                                  description: widget.description,
                                  selectedAmenities: _selectedAmenities.toList(),
                                  selectedCategory: widget.selectedCategory,
                                ),
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

  Widget _buildAmenityGrid(List<Map<String, dynamic>> list) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final title = item['title'] as String;
        final isSelected = _selectedAmenities.contains(title);
        final isPremium = item['isPremium'] == true;

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedAmenities.remove(title);
              } else {
                _selectedAmenities.add(title);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF3EDF7) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : (isPremium ? AppColors.primary.withOpacity(0.35) : AppColors.border),
                width: isSelected ? 1.6 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: isSelected ? AppColors.primary : (isPremium ? const Color(0xFFFFA000) : AppColors.textSecondary),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(int currentStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: List.generate(9, (index) {
          final isCompleted = index < currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    color: isCompleted ? AppColors.primary : const Color(0xFFF3EDF7),
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.primary : const Color(0xFFF3EDF7),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
