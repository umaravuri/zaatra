import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'host_add_property_step7_76.dart';

class HostAddPropertyStep6Screen extends StatefulWidget {
  final Map<String, dynamic>? propertyData;
  const HostAddPropertyStep6Screen({super.key, this.propertyData});

  @override
  State<HostAddPropertyStep6Screen> createState() => _HostAddPropertyStep6ScreenState();
}

class _HostAddPropertyStep6ScreenState extends State<HostAddPropertyStep6Screen> {
  final Set<String> _selectedRules = {};
  final TextEditingController _customRuleController = TextEditingController();

  final List<Map<String, dynamic>> _rules = [
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

  void _toggleRule(String title) {
    setState(() {
      if (_selectedRules.contains(title)) {
        _selectedRules.remove(title);
      } else {
        _selectedRules.add(title);
      }
    });
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
      _rules.add({'title': text, 'icon': Icons.rule_rounded});
      _selectedRules.add(text);
      _customRuleController.clear();
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
            Text('Step 6 of 9', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                _buildProgressBar(6),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('House Rules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                SizedBox(height: 4),
                                Text('Tap to enable or disable rules for guests', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8DEF8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_selectedRules.length} Active',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Interactive Rules List with Checkmarks
                        ...List.generate(_rules.length, (index) {
                          final item = _rules[index];
                          final title = item['title'] as String;
                          final isSelected = _selectedRules.contains(title);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Material(
                              color: isSelected ? const Color(0xFFFAFAFE) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFE8DEF8) : const Color(0xFFF3EDF7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(item['icon'] as IconData, color: AppColors.primary, size: 20),
                                ),
                                title: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                  ),
                                ),
                                trailing: Icon(
                                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                  color: isSelected ? const Color(0xFF2E7D32) : AppColors.textMuted,
                                  size: 22,
                                ),
                                onTap: () => _toggleRule(title),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 12),

                        // Inline Add Custom Rule Section
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
                                'Specify any special guidelines or rules for your guests',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      label: '',
                                      hint: 'e.g. Valid Gov ID required, No loud music',
                                      controller: _customRuleController,
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

                // Dual Buttons Row matching 81.png
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
                            final updatedData = Map<String, dynamic>.from(widget.propertyData ?? {});
                            updatedData['houseRules'] = _selectedRules.toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HostAddPropertyStep7Screen(
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
