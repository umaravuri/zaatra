import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../common/host_add_property_step3_common.dart';

class HostAddResortStep2DetailsScreen extends StatefulWidget {
  final String selectedCategory;

  const HostAddResortStep2DetailsScreen({
    Key? key,
    this.selectedCategory = 'Resort',
  }) : super(key: key);

  @override
  State<HostAddResortStep2DetailsScreen> createState() => _HostAddResortStep2DetailsScreenState();
}

class _HostAddResortStep2DetailsScreenState extends State<HostAddResortStep2DetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _cottages = 0;
  int _pools = 0;
  int _maxCapacity = 0;
  int _restaurants = 0;

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
            Text('Set 2 by 9 (Resort Details)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                _buildProgressBar(2),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Resort Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Enter inventory, cottages & guest capacity for your resort listing', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 20),

                        // Selected Type Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.holiday_village_rounded, color: AppColors.primary, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Resort Destination',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Resort Name
                        CustomTextField(
                          label: 'Resort Name',
                          hint: 'Enter resort name here',
                          controller: _nameController,
                        ),
                        const SizedBox(height: 20),

                        // Cottages & Suites Counter
                        _buildCounterRow('Total Cottages & Luxury Suites', _cottages, (val) => setState(() => _cottages = val)),
                        const SizedBox(height: 16),

                        // Swimming Pools Counter
                        _buildCounterRow('Number of Swimming Pools & Water Features', _pools, (val) => setState(() => _pools = val)),
                        const SizedBox(height: 16),

                        // Max Guests Capacity Counter
                        _buildCounterRow('Max Guest Capacity (Overall Resort)', _maxCapacity, (val) => setState(() => _maxCapacity = val), step: 5),
                        const SizedBox(height: 16),

                        // In-house Restaurants Counter
                        _buildCounterRow('Multi-Cuisine Restaurants / Dining Halls', _restaurants, (val) => setState(() => _restaurants = val)),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomButton(
                    text: 'Next',
                    onPressed: () {
                      final name = _nameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a resort name.'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      if (_cottages <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please add at least 1 cottage/room.'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      final details = {
                        'cottages': _cottages,
                        'pools': _pools,
                        'capacity': _maxCapacity,
                        'restaurants': _restaurants,
                        'bedrooms': _cottages,
                        'bathrooms': _cottages,
                        'guests': _maxCapacity,
                      };

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HostAddPropertyStep3CommonScreen(
                            selectedCategory: widget.selectedCategory,
                            propertyName: _nameController.text.trim(),
                            propertyDetails: details,
                          ),
                        ),
                      );
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

  Widget _buildCounterRow(String title, int value, ValueChanged<int> onChanged, {int step = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => onChanged(value > step ? value - step : step),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDF7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.remove, color: AppColors.textPrimary, size: 20),
                ),
              ),
              Text(
                value < 10 ? '0$value' : '$value',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              InkWell(
                onTap: () => onChanged(value + step),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDF7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, color: AppColors.textPrimary, size: 20),
                ),
              ),
            ],
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
