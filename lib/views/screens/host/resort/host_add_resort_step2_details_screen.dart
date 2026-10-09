import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../common/host_add_property_step3_common.dart';

class HostAddResortStep2DetailsScreen extends StatefulWidget {
  final String selectedCategory;

  const HostAddResortStep2DetailsScreen({
    super.key,
    this.selectedCategory = 'Resort',
  });

  @override
  State<HostAddResortStep2DetailsScreen> createState() => _HostAddResortStep2DetailsScreenState();
}

class _HostAddResortStep2DetailsScreenState extends State<HostAddResortStep2DetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  
  // Cottages Configuration
  int _cottages = 1;
  int _guestsPerCottage = 4;

  // Luxury Suites Configuration
  int _luxurySuites = 0;
  int _guestsPerSuite = 2;

  // Amenities Counters
  int _pools = 1;
  int _restaurants = 1;

  int get _totalUnits => _cottages + _luxurySuites;
  int get _totalCapacity => (_cottages * _guestsPerCottage) + (_luxurySuites * _guestsPerSuite);

  @override
  void dispose() {
    _nameController.dispose();
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
        title: const Column(
          children: [
            Text('Add new property', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
            SizedBox(height: 2),
            Text('Step 2 of 9 (Resort Details)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                        const Text('Resort Inventory & Capacity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Configure cottages, luxury suites and guest capacities for your resort', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 20),

                        // Selected Type Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
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
                        const SizedBox(height: 24),

                        // 1. Cottages Section
                        _buildSectionHeader(
                          title: 'Standard Cottages',
                          subtitle: 'Independent garden, forest or poolside cottages',
                          icon: Icons.cabin_rounded,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCounterRow(
                                'Total Cottages',
                                _cottages,
                                (val) => setState(() => _cottages = val),
                                min: 0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCounterRow(
                                'Guests / Cottage',
                                _guestsPerCottage,
                                (val) => setState(() => _guestsPerCottage = val),
                                min: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 2. Luxury Suites Section
                        _buildSectionHeader(
                          title: 'Luxury Suites',
                          subtitle: 'Premium private jacuzzi / executive panoramic suites',
                          icon: Icons.villa_rounded,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCounterRow(
                                'Total Luxury Suites',
                                _luxurySuites,
                                (val) => setState(() => _luxurySuites = val),
                                min: 0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCounterRow(
                                'Guests / Suite',
                                _guestsPerSuite,
                                (val) => setState(() => _guestsPerSuite = val),
                                min: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Auto-Calculated Overall Capacity Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F5FC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE8DEF8)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE8DEF8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Calculated Resort Capacity', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$_totalUnits Units Total • $_totalCapacity Max Guests',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 3. Amenities & Facilities Counters
                        _buildSectionHeader(
                          title: 'Resort Amenities & Facilities',
                          subtitle: 'Water bodies and in-house restaurants',
                          icon: Icons.pool_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildCounterRow(
                          'Number of Swimming Pools & Water Features',
                          _pools,
                          (val) => setState(() => _pools = val),
                          min: 0,
                        ),
                        const SizedBox(height: 14),
                        _buildCounterRow(
                          'Multi-Cuisine Restaurants / Dining Halls',
                          _restaurants,
                          (val) => setState(() => _restaurants = val),
                          min: 0,
                        ),
                        const SizedBox(height: 10),
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
                      if (_totalUnits <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please add at least 1 cottage or luxury suite.'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      final details = {
                        'cottages': _cottages,
                        'guestsPerCottage': _guestsPerCottage,
                        'luxurySuites': _luxurySuites,
                        'guestsPerSuite': _guestsPerSuite,
                        'totalUnits': _totalUnits,
                        'totalCapacity': _totalCapacity,
                        'capacity': _totalCapacity,
                        'pools': _pools,
                        'restaurants': _restaurants,
                        'bedrooms': _totalUnits,
                        'bathrooms': _totalUnits,
                        'guests': _totalCapacity,
                        'dayEventCapacity': _totalCapacity * 3,
                        'parkingCapacity': _totalUnits * 2,
                        'vehicleParkingCapacity': '${_totalUnits * 2} Cars',
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

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounterRow(String title, int value, ValueChanged<int> onChanged, {int min = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => onChanged(value > min ? value - 1 : min),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDF7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.remove, color: AppColors.textPrimary, size: 18),
                ),
              ),
              Text(
                value < 10 ? '0$value' : '$value',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              InkWell(
                onTap: () => onChanged(value + 1),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDF7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: AppColors.textPrimary, size: 18),
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
