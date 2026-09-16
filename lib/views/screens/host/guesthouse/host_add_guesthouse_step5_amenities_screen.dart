import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../common/host_add_property_step6_common.dart';

class HostAddGuestHouseStep5AmenitiesScreen extends StatefulWidget {
  final String selectedCategory;
  final String propertyName;
  final Map<String, dynamic> propertyDetails;
  final Map<String, dynamic> addressMap;
  final String formattedAddress;
  final String description;

  const HostAddGuestHouseStep5AmenitiesScreen({
    Key? key,
    required this.selectedCategory,
    required this.propertyName,
    required this.propertyDetails,
    required this.addressMap,
    required this.formattedAddress,
    required this.description,
  }) : super(key: key);

  @override
  State<HostAddGuestHouseStep5AmenitiesScreen> createState() => _HostAddGuestHouseStep5AmenitiesScreenState();
}

class _HostAddGuestHouseStep5AmenitiesScreenState extends State<HostAddGuestHouseStep5AmenitiesScreen> {
  final Set<String> _selectedAmenities = {};

  final List<Map<String, dynamic>> _guesthouseAmenities = [
    // Homestay Comforts
    {'title': 'Homely Cooked Meals', 'icon': Icons.soup_kitchen_rounded, 'isPremium': true},
    {'title': 'RO Drinking Water', 'icon': Icons.water_damage_rounded, 'isPremium': true},
    {'title': 'Shared Kitchen', 'icon': Icons.kitchen_rounded, 'isPremium': true},
    {'title': 'Washing Machine', 'icon': Icons.local_laundry_service_rounded, 'isPremium': true},
    {'title': 'Daily Housekeeping', 'icon': Icons.cleaning_services_rounded, 'isPremium': true},
    {'title': 'Common Living Hall', 'icon': Icons.weekend_rounded, 'isPremium': true},
    {'title': 'Work Desk & Chair', 'icon': Icons.desk_rounded, 'isPremium': true},
    {'title': 'Power Backup', 'icon': Icons.electric_bolt_rounded, 'isPremium': true},

    // Standard Room Amenities
    {'title': 'Wi-Fi', 'icon': Icons.wifi_rounded, 'isPremium': false},
    {'title': 'Air Conditioning', 'icon': Icons.ac_unit_rounded, 'isPremium': false},
    {'title': 'TV with Cable', 'icon': Icons.tv_rounded, 'isPremium': false},
    {'title': 'Hot Water Geyser', 'icon': Icons.bathtub_rounded, 'isPremium': false},
    {'title': 'Free Parking', 'icon': Icons.local_parking_rounded, 'isPremium': false},
    {'title': '24/7 CCTV Security', 'icon': Icons.security_rounded, 'isPremium': false},
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
            Text('Set 5 by 9 (Guest House Amenities)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                        const Text('Guest House Amenities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Select homestay amenities, kitchen, meal options and services provided', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 22),

                        // Section 1: Homestay Highlights
                        Row(
                          children: const [
                            Icon(Icons.home_outlined, color: AppColors.primary, size: 22),
                            SizedBox(width: 8),
                            Text('Homestay & Shared Facilities', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _buildAmenityGrid(_guesthouseAmenities.where((a) => a['isPremium'] == true).toList()),

                        const SizedBox(height: 24),

                        // Section 2: Room Facilities
                        Row(
                          children: const [
                            Icon(Icons.check_circle_outline_rounded, color: AppColors.textSecondary, size: 20),
                            SizedBox(width: 8),
                            Text('Room Essentials & Utilities', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _buildAmenityGrid(_guesthouseAmenities.where((a) => a['isPremium'] == false).toList()),

                        const SizedBox(height: 24),

                        // Selected Summary Chips
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
                                const SnackBar(
                                  content: Text('Please select at least one amenity to proceed.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HostAddPropertyStep6CommonScreen(
                                  selectedCategory: widget.selectedCategory,
                                  propertyName: widget.propertyName,
                                  propertyDetails: widget.propertyDetails,
                                  addressMap: widget.addressMap,
                                  formattedAddress: widget.formattedAddress,
                                  description: widget.description,
                                  amenities: _selectedAmenities.toList(),
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
            ),
            child: Row(
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: isSelected ? AppColors.primary : (isPremium ? const Color(0xFF1976D2) : AppColors.textSecondary),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
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
