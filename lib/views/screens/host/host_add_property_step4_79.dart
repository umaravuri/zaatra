import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'host_add_property_step5_80.dart';

class HostAddPropertyStep4Screen extends StatefulWidget {
  final Map<String, dynamic>? propertyData;
  const HostAddPropertyStep4Screen({Key? key, this.propertyData}) : super(key: key);

  @override
  State<HostAddPropertyStep4Screen> createState() => _HostAddPropertyStep4ScreenState();
}

class _HostAddPropertyStep4ScreenState extends State<HostAddPropertyStep4Screen> {
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.propertyData?['description'] ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
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
            Text('Set 4 by 9', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
            _buildProgressBar(4),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Tell guests about your property', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),

                    const SizedBox(height: 20),

                    // Multi-line Text Area matching 79.png
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE8DEF8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            controller: _descriptionController,
                            maxLines: 8,
                            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
                            decoration: const InputDecoration(
                              hintText: 'Enter a detailed description of your property, amenities, and unique highlights...',
                              hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                              border: InputBorder.none,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text('1000/1000', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Dual Buttons Row matching 79.png
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
                        final desc = _descriptionController.text.trim();
                        if (desc.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a description for your property.'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        final updatedData = Map<String, dynamic>.from(widget.propertyData ?? {});
                        updatedData['description'] = desc;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HostAddPropertyStep5Screen(
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
