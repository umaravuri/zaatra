import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'host_add_property_step7_76.dart';

class HostAddPropertyStep6Screen extends StatefulWidget {
  final Map<String, dynamic>? propertyData;
  const HostAddPropertyStep6Screen({Key? key, this.propertyData}) : super(key: key);

  @override
  State<HostAddPropertyStep6Screen> createState() => _HostAddPropertyStep6ScreenState();
}

class _HostAddPropertyStep6ScreenState extends State<HostAddPropertyStep6Screen> {
  final Set<String> _selectedRules = {};

  final List<Map<String, dynamic>> _rules = [
    {'title': 'No Smoking', 'icon': Icons.smoke_free_rounded},
    {'title': 'No Pets', 'icon': Icons.pets_rounded},
    {'title': 'No Parties or events', 'icon': Icons.celebration_rounded},
    {'title': 'Suitable for children', 'icon': Icons.child_care_rounded},
    {'title': 'Quiet Hours (10:00 PM – 07:00 AM)', 'icon': Icons.access_time_rounded},
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

  void _showAddCustomRuleDialog() {
    final customRuleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.rule_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Add Custom Rule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: TextField(
          controller: customRuleController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. No shoes inside living areas',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final newRule = customRuleController.text.trim();
              if (newRule.isNotEmpty) {
                setState(() {
                  _rules.add({'title': newRule, 'icon': Icons.check_box_outlined});
                  _selectedRules.add(newRule);
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Custom rule "$newRule" added!'),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Add Rule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
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
                                color: isSelected ? AppColors.primary.withOpacity(0.5) : AppColors.border,
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

                        const SizedBox(height: 8),

                        // Add Custom Rule Button
                        InkWell(
                          onTap: _showAddCustomRuleDialog,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F5FE),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  '+ Add Custom Rule',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Dual Buttons Row
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
                          text: 'Next: Pricing',
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
