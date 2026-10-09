import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../host_add_property_step7_76.dart';
import '../villa/host_add_villa_step7_pricing_screen.dart';
import '../resort/host_add_resort_step7_pricing_screen.dart';
import '../farmhouse/host_add_farmhouse_step7_pricing_screen.dart';
import '../guesthouse/host_add_guesthouse_step7_pricing_screen.dart';

class HostAddPropertyStep6CommonScreen extends StatefulWidget {
  final String selectedCategory;
  final String propertyName;
  final Map<String, dynamic> propertyDetails;
  final Map<String, dynamic> addressMap;
  final String formattedAddress;
  final String description;
  final dynamic amenities;

  const HostAddPropertyStep6CommonScreen({
    super.key,
    required this.selectedCategory,
    required this.propertyName,
    required this.propertyDetails,
    required this.addressMap,
    required this.formattedAddress,
    required this.description,
    required this.amenities,
  });

  @override
  State<HostAddPropertyStep6CommonScreen> createState() => _HostAddPropertyStep6CommonScreenState();
}

class _HostAddPropertyStep6CommonScreenState extends State<HostAddPropertyStep6CommonScreen> {
  final Set<String> _selectedRules = {};
  final List<String> _customRules = [];
  final TextEditingController _customRuleController = TextEditingController();

  final List<Map<String, dynamic>> _standardRules = [
    {'title': 'No Smoking', 'icon': Icons.smoke_free_rounded},
    {'title': 'No Pets', 'icon': Icons.pets_rounded},
    {'title': 'No Parties or events', 'icon': Icons.celebration_rounded},
    {'title': 'Suitable for children', 'icon': Icons.child_care_rounded},
    {'title': 'Quiet Hours (10:00 PM – 07:00 AM)', 'icon': Icons.access_time_rounded},
  ];

  @override
  void dispose() {
    _customRuleController.dispose();
    super.dispose();
  }

  void _addCustomRule() {
    final text = _customRuleController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a house rule.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedRules.contains(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This rule is already added.'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() {
      _selectedRules.add(text);
      _customRules.add(text);
      _customRuleController.clear();
    });
  }

  void _navigateToStep7() {
    final cat = widget.selectedCategory.trim().toLowerCase();
    final rulesList = _selectedRules.toList();

    if (cat == 'resort') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HostAddResortStep7PricingScreen(
            selectedCategory: widget.selectedCategory,
            propertyName: widget.propertyName,
            propertyDetails: widget.propertyDetails,
            addressMap: widget.addressMap,
            formattedAddress: widget.formattedAddress,
            description: widget.description,
            amenities: widget.amenities,
            houseRules: rulesList,
          ),
        ),
      );
    } else if (cat == 'farmhouse') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HostAddFarmhouseStep7PricingScreen(
            selectedCategory: widget.selectedCategory,
            propertyName: widget.propertyName,
            propertyDetails: widget.propertyDetails,
            addressMap: widget.addressMap,
            formattedAddress: widget.formattedAddress,
            description: widget.description,
            amenities: widget.amenities,
            houseRules: rulesList,
          ),
        ),
      );
    } else if (cat == 'guest house' || cat == 'guesthouse') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HostAddGuestHouseStep7PricingScreen(
            selectedCategory: widget.selectedCategory,
            propertyName: widget.propertyName,
            propertyDetails: widget.propertyDetails,
            addressMap: widget.addressMap,
            formattedAddress: widget.formattedAddress,
            description: widget.description,
            amenities: widget.amenities,
            houseRules: rulesList,
          ),
        ),
      );
    } else if (cat == 'villa') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HostAddVillaStep7PricingScreen(
            villaName: widget.propertyName,
            bedrooms: widget.propertyDetails['bedrooms'] ?? 4,
            bathrooms: widget.propertyDetails['bathrooms'] ?? 3,
            formattedAddress: widget.formattedAddress,
            description: widget.description,
            selectedAmenities: widget.amenities is List ? (widget.amenities as List).cast<String>() : ['Private Pool'],
            selectedCategory: widget.selectedCategory,
          ),
        ),
      );
    } else {
      // Hotel (Default)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HostAddPropertyStep7Screen(),
        ),
      );
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
          children: [
            const Text('Add new property', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
            const SizedBox(height: 2),
            Text('Step 6 of 9 (${widget.selectedCategory})', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                        Text('Set house rules for your ${widget.selectedCategory.toLowerCase()} guests', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 20),

                        // Standard House Rules List
                        ..._standardRules.map((rule) {
                          final title = rule['title'] as String;
                          final isSelected = _selectedRules.contains(title);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedRules.remove(title);
                                } else {
                                  _selectedRules.add(title);
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFF9F9FB) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3EDF7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(rule['icon'] as IconData, color: AppColors.primary, size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
                        }),

                        // Custom Rules List (if any added)
                        if (_customRules.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text('Custom Added Rules', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 10),
                          ..._customRules.map((customRule) {
                            final isSelected = _selectedRules.contains(customRule);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFF9F9FB) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3EDF7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.rule_rounded, color: AppColors.primary, size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      customRule,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _selectedRules.remove(customRule);
                                        _customRules.remove(customRule);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],

                        const SizedBox(height: 16),

                        // Add Custom Rule Card Section
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
                                    'Add Custom House Rule',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Specify any special guidelines or rules for your property',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _customRuleController,
                                      decoration: InputDecoration(
                                        hintText: 'e.g. No footwear inside, Valid Gov ID required',
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
                                      onSubmitted: (_) => _addCustomRule(),
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
                                    onPressed: _addCustomRule,
                                    child: const Text('+ Add Rule', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
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
                          onPressed: _navigateToStep7,
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
