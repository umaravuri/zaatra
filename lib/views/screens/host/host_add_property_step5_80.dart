import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'host_add_property_step6_81.dart';

class HostAddPropertyStep5Screen extends StatefulWidget {
  final Map<String, dynamic>? propertyData;
  const HostAddPropertyStep5Screen({Key? key, this.propertyData}) : super(key: key);

  @override
  State<HostAddPropertyStep5Screen> createState() => _HostAddPropertyStep5ScreenState();
}

class _HostAddPropertyStep5ScreenState extends State<HostAddPropertyStep5Screen> {
  // Separate selections for Luxury and Regular rooms matching the user wireframe
  final Set<String> _luxuryAmenities = {};
  final Set<String> _regularAmenities = {};

  final List<Map<String, dynamic>> _amenitiesList = [
    {'title': 'Wi-Fi', 'icon': Icons.wifi_rounded},
    {'title': 'Tv', 'icon': Icons.tv_rounded},
    {'title': 'AC', 'icon': Icons.ac_unit_rounded},
    {'title': 'Kitchen', 'icon': Icons.soup_kitchen_rounded},
    {'title': 'Parking', 'icon': Icons.local_parking_rounded},
    {'title': 'Pool', 'icon': Icons.pool_rounded},
    {'title': 'Washing', 'icon': Icons.local_laundry_service_rounded},
    {'title': 'Hot water', 'icon': Icons.water_drop_rounded},
    {'title': 'Break fast', 'icon': Icons.free_breakfast_rounded},
    {'title': 'Lunch', 'icon': Icons.restaurant_rounded},
    {'title': 'Mini Bar', 'icon': Icons.wine_bar_rounded},
    {'title': 'Balcony', 'icon': Icons.balcony_rounded},
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
            Text('Set 5 by 9', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                _buildProgressBar(5),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Amenities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Select amenities available for Luxury and Regular rooms', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),

                        const SizedBox(height: 22),

                        // ==========================================
                        // 1. LUXURY ROOM AMENITIES LIST SECTION
                        // ==========================================
                        _buildSectionHeader(
                          title: 'Amenities in Luxury Rooms',
                          subtitle: 'Select all amenities provided in Luxury Rooms',
                          icon: Icons.star_rounded,
                        ),
                        const SizedBox(height: 14),

                        _buildAmenityGrid(
                          selectedSet: _luxuryAmenities,
                          onToggle: (title) {
                            setState(() {
                              if (_luxuryAmenities.contains(title)) {
                                _luxuryAmenities.remove(title);
                              } else {
                                _luxuryAmenities.add(title);
                              }
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // 2. SELECTED AMENITIES (LUXURY ROOMS)
                        _buildSelectedChips(
                          title: 'Selected Amenities (Luxury)',
                          selectedSet: _luxuryAmenities,
                          onRemove: (item) => setState(() => _luxuryAmenities.remove(item)),
                        ),

                        const SizedBox(height: 28),
                        const Divider(height: 1, color: Color(0xFFE8DEF8)),
                        const SizedBox(height: 24),

                        // ==========================================
                        // 3. REGULAR ROOM AMENITIES LIST SECTION
                        // ==========================================
                        _buildSectionHeader(
                          title: 'Amenities in Regular Rooms',
                          subtitle: 'Select all amenities provided in Regular Rooms',
                          icon: Icons.check_circle_outline_rounded,
                        ),
                        const SizedBox(height: 14),

                        _buildAmenityGrid(
                          selectedSet: _regularAmenities,
                          onToggle: (title) {
                            setState(() {
                              if (_regularAmenities.contains(title)) {
                                _regularAmenities.remove(title);
                              } else {
                                _regularAmenities.add(title);
                              }
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // 4. SELECTED AMENITIES (REGULAR ROOMS)
                        _buildSelectedChips(
                          title: 'Selected Amenities (Regular)',
                          selectedSet: _regularAmenities,
                          onRemove: (item) => setState(() => _regularAmenities.remove(item)),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Dual Buttons Row matching 80.png
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
                            if (_regularAmenities.isEmpty && _luxuryAmenities.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select at least 1 amenity for your rooms.'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            final updatedData = Map<String, dynamic>.from(widget.propertyData ?? {});
                            updatedData['regularAmenities'] = _regularAmenities.toList();
                            updatedData['luxuryAmenities'] = _luxuryAmenities.toList();
                            updatedData['amenities'] = _regularAmenities.union(_luxuryAmenities).toList();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HostAddPropertyStep6Screen(
                                  propertyData: updatedData,
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

  Widget _buildSectionHeader({required String title, required String subtitle, required IconData icon}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityGrid({
    required Set<String> selectedSet,
    required ValueChanged<String> onToggle,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: _amenitiesList.length,
      itemBuilder: (context, index) {
        final item = _amenitiesList[index];
        final title = item['title'] as String;
        final isSelected = selectedSet.contains(title);

        return GestureDetector(
          onTap: () => onToggle(title),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF3EDF7) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
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
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
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

  Widget _buildSelectedChips({
    required String title,
    required Set<String> selectedSet,
    required ValueChanged<String> onRemove,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title (${selectedSet.length})',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          if (selectedSet.isEmpty)
            const Text(
              'No amenities selected yet.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedSet.map((item) {
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
                        onTap: () => onRemove(item),
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
