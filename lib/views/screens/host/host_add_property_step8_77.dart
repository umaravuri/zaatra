import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'host_add_property_step9_72.dart';

class HostAddPropertyStep8Screen extends StatefulWidget {
  final Map<String, dynamic>? propertyData;
  const HostAddPropertyStep8Screen({Key? key, this.propertyData}) : super(key: key);

  @override
  State<HostAddPropertyStep8Screen> createState() => _HostAddPropertyStep8ScreenState();
}

class _HostAddPropertyStep8ScreenState extends State<HostAddPropertyStep8Screen> {
  String? _checkInTime;
  String? _checkOutTime;

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
            Text('Set 8 by 9', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
            _buildProgressBar(8),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Check in - Check out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Set timing for check-in and check-out', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),

                    const SizedBox(height: 24),

                    // Check-in Time Field
                    _buildTimePickerBox('Check in - time', _checkInTime ?? 'Select Check-in Time', () async {
                      final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 14, minute: 0));
                      if (time != null) {
                        setState(() => _checkInTime = time.format(context));
                      }
                    }, isSelected: _checkInTime != null),

                    const SizedBox(height: 20),

                    // Check-out Time Field
                    _buildTimePickerBox('Check Out - Time', _checkOutTime ?? 'Select Check-out Time', () async {
                      final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 11, minute: 0));
                      if (time != null) {
                        setState(() => _checkOutTime = time.format(context));
                      }
                    }, isSelected: _checkOutTime != null),
                  ],
                ),
              ),
            ),

            // Dual Buttons Row matching 77.png
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
                        if (_checkInTime == null || _checkOutTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select both check-in and check-out times.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        final updatedData = Map<String, dynamic>.from(widget.propertyData ?? {});
                        updatedData['checkInTime'] = _checkInTime!;
                        updatedData['checkOutTime'] = _checkOutTime!;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HostAddPropertyStep9Screen(
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

  Widget _buildTimePickerBox(String label, String value, VoidCallback onTap, {bool isSelected = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
                const Icon(Icons.access_time_rounded, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ],
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
