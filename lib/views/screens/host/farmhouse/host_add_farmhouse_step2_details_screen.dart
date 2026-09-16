import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../common/host_add_property_step3_common.dart';

class HostAddFarmhouseStep2DetailsScreen extends StatefulWidget {
  final String selectedCategory;

  const HostAddFarmhouseStep2DetailsScreen({
    Key? key,
    this.selectedCategory = 'Farmhouse',
  }) : super(key: key);

  @override
  State<HostAddFarmhouseStep2DetailsScreen> createState() => _HostAddFarmhouseStep2DetailsScreenState();
}

class _HostAddFarmhouseStep2DetailsScreenState extends State<HostAddFarmhouseStep2DetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  int _bedrooms = 0;
  int _bathrooms = 0;
  int _eventCapacity = 0;

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
            Text('Set 2 by 9 (Farmhouse Details)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                        const Text('Farmhouse Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Enter farm acreage, party lawn capacity & bedroom details', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
                              Icon(Icons.agriculture_rounded, color: AppColors.primary, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Farmhouse & Nature Retreat',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Farmhouse Name
                        CustomTextField(
                          label: 'Farmhouse Name',
                          hint: 'Enter farmhouse name here',
                          controller: _nameController,
                        ),
                        const SizedBox(height: 18),

                        // Farm Area (Acres / Sq Yards)
                        CustomTextField(
                          label: 'Total Farm / Lawn Area',
                          hint: 'e.g. 2.5 Acres / 3,000 Sq Yards',
                          controller: _areaController,
                        ),
                        const SizedBox(height: 20),

                        // Event / Gathering Guest Capacity
                        _buildCounterRow('Event & Party Lawn Capacity (Guests)', _eventCapacity, (val) => setState(() => _eventCapacity = val), step: 25),
                        const SizedBox(height: 16),

                        // Bedrooms Counter
                        _buildCounterRow('No: of Bedrooms / Cottages', _bedrooms, (val) => setState(() => _bedrooms = val)),
                        const SizedBox(height: 16),

                        // Bathrooms Counter
                        _buildCounterRow('No: of Bathrooms', _bathrooms, (val) => setState(() => _bathrooms = val)),
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
                          const SnackBar(content: Text('Please enter a farmhouse name.'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      if (_bedrooms <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter at least 1 bedroom.'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      final details = {
                        'farmArea': _areaController.text.trim(),
                        'eventCapacity': _eventCapacity,
                        'bedrooms': _bedrooms,
                        'bathrooms': _bathrooms,
                        'guests': _eventCapacity,
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
