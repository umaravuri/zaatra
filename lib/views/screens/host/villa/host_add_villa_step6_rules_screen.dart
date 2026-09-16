import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import 'host_add_villa_step7_pricing_screen.dart';

class HostAddVillaStep6RulesScreen extends StatefulWidget {
  final String villaName;
  final int bedrooms;
  final int bathrooms;
  final String formattedAddress;
  final String description;
  final List<String> selectedAmenities;
  final String selectedCategory;

  const HostAddVillaStep6RulesScreen({
    Key? key,
    required this.villaName,
    required this.bedrooms,
    required this.bathrooms,
    required this.formattedAddress,
    required this.description,
    required this.selectedAmenities,
    this.selectedCategory = 'Villa',
  }) : super(key: key);

  @override
  State<HostAddVillaStep6RulesScreen> createState() => _HostAddVillaStep6RulesScreenState();
}

class _HostAddVillaStep6RulesScreenState extends State<HostAddVillaStep6RulesScreen> {
  final Set<String> _selectedRules = {};

  final List<Map<String, dynamic>> _rules = [
    {'title': 'No Smoking Indoors', 'icon': Icons.smoke_free_rounded},
    {'title': 'Pets Allowed on Lawn', 'icon': Icons.pets_rounded},
    {'title': 'Events Allowed with Prior Notice', 'icon': Icons.celebration_rounded},
    {'title': 'Suitable for Children & Families', 'icon': Icons.child_care_rounded},
    {'title': 'Quiet Hours (11:00 PM – 06:00 AM)', 'icon': Icons.access_time_rounded},
  ];

  void _toggleRule(String title) {
    setState(() {
      if (_selectedRules.contains(title)) {
        _selectedRules.remove(title);
      } else {
        _selectedRules.add(title);
      }
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
        title: Column(
          children: const [
            Text('Add new property', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
            SizedBox(height: 2),
            Text('Set 6 by 9 (Villa Flow)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                _buildProgressBar(6),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('House Rules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Set house rules for your villa guests', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 20),

                        ..._rules.map((rule) {
                          final title = rule['title'] as String;
                          final isSelected = _selectedRules.contains(title);
                          return InkWell(
                            onTap: () => _toggleRule(title),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary.withOpacity(0.04) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary.withOpacity(0.1) : const Color(0xFFF3EDF7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      rule['icon'] as IconData,
                                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HostAddVillaStep7PricingScreen(
                                  villaName: widget.villaName,
                                  bedrooms: widget.bedrooms,
                                  bathrooms: widget.bathrooms,
                                  formattedAddress: widget.formattedAddress,
                                  description: widget.description,
                                  selectedAmenities: widget.selectedAmenities,
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
