import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_placeholder.dart';
import 'host_add_property_step2_75.dart';
import 'villa/host_add_villa_step2_details_screen.dart';
import 'resort/host_add_resort_step2_details_screen.dart';
import 'farmhouse/host_add_farmhouse_step2_details_screen.dart';
import 'guesthouse/host_add_guesthouse_step2_details_screen.dart';

class HostAddPropertyStep1Screen extends StatefulWidget {
  const HostAddPropertyStep1Screen({Key? key}) : super(key: key);

  @override
  State<HostAddPropertyStep1Screen> createState() => _HostAddPropertyStep1ScreenState();
}

class _HostAddPropertyStep1ScreenState extends State<HostAddPropertyStep1Screen> {
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'Resort',
    'Villa',
    'Farmhouse',
    'Hotel',
    'Guest House',
  ];

  IconData _getCategoryIcon(int index) {
    switch (index) {
      case 0:
        return Icons.holiday_village_rounded;
      case 1:
        return Icons.villa_rounded;
      case 2:
        return Icons.cabin_rounded;
      case 3:
        return Icons.hotel_rounded;
      case 4:
        return Icons.gite_rounded;
      default:
        return Icons.home_rounded;
    }
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
        title: Column(
          children: const [
            Text('Add new property', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
            SizedBox(height: 2),
            Text('Set 1 by 9', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
            // Bottom Background Graphic (image 31.png)
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
                // 9-Step Progress Bar matching 71.png
            _buildProgressBar(1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Property Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Select the type of property you want to lot', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),

                    const SizedBox(height: 24),

                    // Grid of Property Cards matching 71.png with equal image dimensions
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 18,
                        childAspectRatio: 0.76,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedCategoryIndex == index;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategoryIndex = index),
                          child: Column(
                            children: [
                              // Category Container (95x95)
                              Container(
                                width: 95,
                                height: 95,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary.withOpacity(0.08) : const Color(0xFFF7F5FE),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    _getCategoryIcon(index),
                                    size: 40,
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _categories[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Primary Next Button matching 71.png
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomButton(
                text: 'Next',
                onPressed: () {
                  final chosenCat = _categories[_selectedCategoryIndex];
                  final catLower = chosenCat.toLowerCase();

                  if (catLower.contains('hotel')) {
                    // 1. Hotel Flow
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HostAddPropertyStep2Screen(
                          selectedCategory: chosenCat,
                        ),
                      ),
                    );
                  } else if (catLower.contains('resort')) {
                    // 2. Resort Flow
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HostAddResortStep2DetailsScreen(
                          selectedCategory: chosenCat,
                        ),
                      ),
                    );
                  } else if (catLower.contains('farmhouse')) {
                    // 3. Farmhouse Flow
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HostAddFarmhouseStep2DetailsScreen(
                          selectedCategory: chosenCat,
                        ),
                      ),
                    );
                  } else if (catLower.contains('guest house') || catLower.contains('guesthouse')) {
                    // 4. Guest House Flow
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HostAddGuestHouseStep2DetailsScreen(
                          selectedCategory: chosenCat,
                        ),
                      ),
                    );
                  } else {
                    // 5. Villa Flow
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HostAddVillaStep2DetailsScreen(
                          selectedCategory: chosenCat,
                        ),
                      ),
                    );
                  }
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
