import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';

class StayFiltersScreen extends StatefulWidget {
  const StayFiltersScreen({Key? key}) : super(key: key);

  @override
  State<StayFiltersScreen> createState() => _StayFiltersScreenState();
}

class _StayFiltersScreenState extends State<StayFiltersScreen> {
  double _priceValue = 5000;
  int _selectedTypeIndex = 1;
  final List<bool> _amenitiesSelected = [true, false, false, true, false];
  int _selectedRatingIndex = 2;
  bool _installationBookings = false;
  bool _freeCancellations = true;

  final List<Map<String, dynamic>> _types = [
    {'title': 'Hotels', 'icon': Icons.apartment_rounded},
    {'title': 'Villas', 'icon': Icons.villa_rounded},
    {'title': 'Houses', 'icon': Icons.home_rounded},
    {'title': 'Form house', 'icon': Icons.nature_people_rounded},
  ];

  final List<String> _amenities = ['Free Wi-Fi', 'Parking', 'Swimming Pool', 'Ac Conditioner', 'Free Break fast'];
  final List<String> _ratings = ['3 ★', '4 ★', '4.5 ★'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Filters',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Range Slider matching 43.png
                    const Text('Price Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: const Color(0xFFE8DEF8),
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withOpacity(0.1),
                      ),
                      child: Slider(
                        value: _priceValue,
                        min: 1500,
                        max: 20000,
                        onChanged: (val) => setState(() => _priceValue = val),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('₹ 1,500', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        Text('₹ 20,000', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Property Type Cards Grid matching 43.png
                    const Text('Property Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 16),

                    Row(
                      children: List.generate(_types.length, (index) {
                        final type = _types[index];
                        final isSelected = _selectedTypeIndex == index;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTypeIndex = index),
                            child: Container(
                              margin: EdgeInsets.only(right: index < _types.length - 1 ? 10 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3EDF7),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(type['icon'] as IconData, color: AppColors.primary, size: 26),
                                  const SizedBox(height: 8),
                                  Text(
                                    type['title'] as String,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 28),

                    // Amenities Checkboxes Grid matching 43.png
                    const Text('Amenities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: List.generate(_amenities.length, (index) {
                        return SizedBox(
                          width: (MediaQuery.of(context).size.width - 60) / 2,
                          child: Row(
                            children: [
                              Checkbox(
                                value: _amenitiesSelected[index],
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) {
                                  setState(() => _amenitiesSelected[index] = val ?? false);
                                },
                              ),
                              Expanded(
                                child: Text(
                                  _amenities[index],
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 28),

                    // Ratings Selection Chips matching 43.png
                    const Text('Ratings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 14),

                    Row(
                      children: List.generate(_ratings.length, (index) {
                        final isSelected = _selectedRatingIndex == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedRatingIndex = index),
                            child: Container(
                              margin: EdgeInsets.only(right: index < _ratings.length - 1 ? 12 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _ratings[index].replaceAll('★', '').trim(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    // Toggle Switches matching 43.png
                    SwitchListTile(
                      title: const Text('Installation Bookings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      value: _installationBookings,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _installationBookings = val),
                    ),

                    SwitchListTile(
                      title: const Text('Free Cancellations', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      value: _freeCancellations,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _freeCancellations = val),
                    ),
                  ],
                ),
              ),
            ),

            // Apply Filters CTA
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomButton(
                text: 'Apply Filters',
                onPressed: () => Navigator.pop(context),
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
