import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../common/host_add_property_step6_common.dart';

class HostAddResortStep5AmenitiesScreen extends StatefulWidget {
  final String selectedCategory;
  final String propertyName;
  final Map<String, dynamic> propertyDetails;
  final Map<String, dynamic> addressMap;
  final String formattedAddress;
  final String description;

  const HostAddResortStep5AmenitiesScreen({
    super.key,
    required this.selectedCategory,
    required this.propertyName,
    required this.propertyDetails,
    required this.addressMap,
    required this.formattedAddress,
    required this.description,
  });

  @override
  State<HostAddResortStep5AmenitiesScreen> createState() => _HostAddResortStep5AmenitiesScreenState();
}

class _HostAddResortStep5AmenitiesScreenState extends State<HostAddResortStep5AmenitiesScreen> {
  final Set<String> _selectedAmenities = {};
  final TextEditingController _customAmenityController = TextEditingController();

  final List<Map<String, dynamic>> _resortAmenities = [
    // Premium Resort Highlights
    {'title': 'Infinity Pool', 'icon': Icons.pool_rounded, 'isPremium': true},
    {'title': 'Buffet Restaurant', 'icon': Icons.restaurant_rounded, 'isPremium': true},
    {'title': 'Spa & Wellness', 'icon': Icons.spa_rounded, 'isPremium': true},
    {'title': 'Beach / Lakefront', 'icon': Icons.beach_access_rounded, 'isPremium': true},
    {'title': 'Water Slides', 'icon': Icons.water_drop_rounded, 'isPremium': true},
    {'title': 'Adventure Sports', 'icon': Icons.sports_soccer_rounded, 'isPremium': true},
    {'title': 'Bar & Lounge', 'icon': Icons.local_bar_rounded, 'isPremium': true},
    {'title': 'Banquet Hall', 'icon': Icons.celebration_rounded, 'isPremium': true},
    {'title': 'Valet Parking', 'icon': Icons.local_parking_rounded, 'isPremium': true},
    {'title': 'Live Shows', 'icon': Icons.theater_comedy_rounded, 'isPremium': true},
    {'title': 'Gym & Fitness', 'icon': Icons.fitness_center_rounded, 'isPremium': true},
    {'title': '24/7 Room Service', 'icon': Icons.room_service_rounded, 'isPremium': true},

    // Standard Amenities
    {'title': 'Wi-Fi', 'icon': Icons.wifi_rounded, 'isPremium': false},
    {'title': 'AC', 'icon': Icons.ac_unit_rounded, 'isPremium': false},
    {'title': 'TV', 'icon': Icons.tv_rounded, 'isPremium': false},
    {'title': 'Hot Water', 'icon': Icons.hot_tub_rounded, 'isPremium': false},
    {'title': 'Laundry', 'icon': Icons.local_laundry_service_rounded, 'isPremium': false},
    {'title': 'Airport Shuttle', 'icon': Icons.airport_shuttle_rounded, 'isPremium': false},
  ];

  @override
  void dispose() {
    _customAmenityController.dispose();
    super.dispose();
  }

  void _addCustomAmenity() {
    final text = _customAmenityController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amenity name.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedAmenities.contains(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This amenity is already added.'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() {
      _selectedAmenities.add(text);
      _customAmenityController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final premiumAmenities = _resortAmenities.where((a) => a['isPremium'] == true).toList();
    final standardAmenities = _resortAmenities.where((a) => a['isPremium'] == false).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          children: [
            Text('Add new property', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
            SizedBox(height: 2),
            Text('Step 5 of 9 (Resort Amenities)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resort Amenities & Facilities',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Select luxury resort features, dining & wellness facilities available for guests',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),

                        // Section 1: Resort Exclusive Amenities
                        _buildSectionHeader(
                          title: 'Resort & Wellness Facilities',
                          subtitle: 'Highlights and luxury experiences',
                          icon: Icons.stars_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildAmenityPairsList(premiumAmenities),

                        const SizedBox(height: 24),

                        // Section 2: General Guest Comforts
                        _buildSectionHeader(
                          title: 'Guest Comforts & Services',
                          subtitle: 'Essential utilities & standard guest services',
                          icon: Icons.check_circle_outline_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildAmenityPairsList(standardAmenities),

                        const SizedBox(height: 24),

                        // Section 3: Add Custom Amenity
                        _buildCustomAmenityInput(),

                        const SizedBox(height: 24),

                        // Selected Summary Chips
                        _buildSelectedSummary(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Navigation Buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
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
                                  content: Text('Please select or add at least 1 amenity for your resort.'),
                                  backgroundColor: Colors.red,
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

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityPairsList(List<Map<String, dynamic>> list) {
    final List<List<Map<String, dynamic>>> rows = [];
    for (int i = 0; i < list.length; i += 2) {
      rows.add(list.sublist(i, (i + 2 <= list.length) ? i + 2 : list.length));
    }

    return Column(
      children: rows.map((rowItems) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            children: [
              Expanded(child: _buildAmenityCard(rowItems[0])),
              const SizedBox(width: 10),
              if (rowItems.length > 1)
                Expanded(child: _buildAmenityCard(rowItems[1]))
              else
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmenityCard(Map<String, dynamic> item) {
    final title = item['title'] as String;
    final isSelected = _selectedAmenities.contains(title);
    final isPremium = item['isPremium'] == true;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
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
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3EDF7) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isPremium ? AppColors.primary.withValues(alpha: 0.35) : AppColors.border),
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              item['icon'] as IconData,
              color: isSelected
                  ? AppColors.primary
                  : (isPremium ? const Color(0xFFE65100) : AppColors.textSecondary),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAmenityInput() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Add Custom Amenity',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Add any unique amenities or services provided by your resort',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customAmenityController,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'e.g. EV Charger, Lake Kayaking, Bonfire',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE8DEF8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE8DEF8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  onSubmitted: (_) => _addCustomAmenity(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _addCustomAmenity,
                child: const Text('+ Add', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Amenities (${_selectedAmenities.length})',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              if (_selectedAmenities.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _selectedAmenities.clear()),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedAmenities.isEmpty)
            const Text('No amenities selected yet.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
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
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
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
    );
  }

  Widget _buildProgressBar(int currentStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: List.generate(9, (index) {
          final isCompleted = index < currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index == 8 ? 0 : 4),
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : const Color(0xFFF3EDF7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
