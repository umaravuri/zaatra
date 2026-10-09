import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'host_add_property_step6_81.dart';

class HostAddPropertyStep5Screen extends StatefulWidget {
  final Map<String, dynamic>? propertyData;
  const HostAddPropertyStep5Screen({super.key, this.propertyData});

  @override
  State<HostAddPropertyStep5Screen> createState() => _HostAddPropertyStep5ScreenState();
}

class _HostAddPropertyStep5ScreenState extends State<HostAddPropertyStep5Screen> {
  // Separate selections for Luxury and Regular rooms matching the user wireframe
  final Set<String> _luxuryAmenities = {};
  final Set<String> _regularAmenities = {};
  final TextEditingController _customAmenityController = TextEditingController();
  String _customTarget = 'Both'; // 'Both', 'Luxury', 'Regular'

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
    setState(() {
      if (_customTarget == 'Luxury' || _customTarget == 'Both') {
        _luxuryAmenities.add(text);
      }
      if (_customTarget == 'Regular' || _customTarget == 'Both') {
        _regularAmenities.add(text);
      }
      _customAmenityController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Step 5 of 9', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Amenities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Select amenities available for Luxury and Regular rooms', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),

                        const SizedBox(height: 22),

                        // 1. LUXURY ROOM AMENITIES LIST SECTION
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

                        const SizedBox(height: 24),

                        // 3. REGULAR ROOM AMENITIES LIST SECTION
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

                        const SizedBox(height: 24),

                        // 5. ADD CUSTOM AMENITY SECTION
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF9FD),
                            borderRadius: BorderRadius.circular(18),
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
                                'Add extra amenities not listed above and assign them',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _customAmenityController,
                                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                                      decoration: InputDecoration(
                                        hintText: 'e.g. EV Charger, Sound System',
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
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: _addCustomAmenity,
                                    child: const Text('+ Add', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Text('Assign to: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                  const SizedBox(width: 8),
                                  ...['Both', 'Luxury', 'Regular'].map((target) {
                                    final isSelected = _customTarget == target;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: ChoiceChip(
                                        label: Text(target, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.textPrimary)),
                                        selected: isSelected,
                                        selectedColor: AppColors.primary,
                                        backgroundColor: const Color(0xFFF3EDF7),
                                        onSelected: (_) => setState(() => _customTarget = target),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _amenitiesList.map((item) {
            final title = item['title'] as String;
            final isSelected = selectedSet.contains(title);

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onToggle(title),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: itemWidth,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF3EDF7) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
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
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
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
          }).toList(),
        );
      },
    );
  }

  Widget _buildSelectedChips({
    required String title,
    required Set<String> selectedSet,
    required ValueChanged<String> onRemove,
  }) {
    if (selectedSet.isEmpty) return const SizedBox.shrink();

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedSet.map((item) {
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
