import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../common/host_add_property_step3_common.dart';

class HostAddFarmhouseStep2DetailsScreen extends StatefulWidget {
  final String selectedCategory;

  const HostAddFarmhouseStep2DetailsScreen({
    super.key,
    this.selectedCategory = 'Farmhouse',
  });

  @override
  State<HostAddFarmhouseStep2DetailsScreen> createState() => _HostAddFarmhouseStep2DetailsScreenState();
}

class _HostAddFarmhouseStep2DetailsScreenState extends State<HostAddFarmhouseStep2DetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController(text: '2.5');
  String _selectedAreaUnit = 'Acres';

  // Guest Capacities (Distinct Overnight vs Daytime Gathering)
  int _overnightCapacity = 15;
  int _eventCapacity = 100;

  // Accommodation & Amenities
  int _bedrooms = 3;
  int _bathrooms = 3;
  int _parkingCapacity = 15;

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
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
                        const Text('Enter farm acreage, guest capacity & accommodation details', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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

                        // Farm Area (Value + Unit Dropdown)
                        _buildAreaPicker(),
                        const SizedBox(height: 22),

                        // Section 1: Guest Capacity Breakdown
                        _buildSectionLabel('Guest Capacities', 'Overnight sleeping vs daytime events'),
                        const SizedBox(height: 12),

                        // Max Overnight Stay Guests
                        _buildCounterRow(
                          'Max Overnight Stay Guests (Sleeping)',
                          _overnightCapacity,
                          (val) => setState(() => _overnightCapacity = val),
                          step: 2,
                          min: 1,
                        ),
                        const SizedBox(height: 14),

                        // Event / Party Lawn Capacity
                        _buildCounterRow(
                          'Day Event / Party Lawn Capacity (Guests)',
                          _eventCapacity,
                          (val) => setState(() => _eventCapacity = val),
                          step: 25,
                          min: 10,
                        ),
                        const SizedBox(height: 22),

                        // Section 2: Accommodation & Parking
                        _buildSectionLabel('Accommodation & Parking', 'Rooms, baths & vehicle space'),
                        const SizedBox(height: 12),

                        // Bedrooms Counter
                        _buildCounterRow(
                          'No: of Bedrooms / Cottages',
                          _bedrooms,
                          (val) => setState(() => _bedrooms = val),
                          min: 1,
                        ),
                        const SizedBox(height: 14),

                        // Bathrooms Counter
                        _buildCounterRow(
                          'No: of Bathrooms',
                          _bathrooms,
                          (val) => setState(() => _bathrooms = val),
                          min: 1,
                        ),
                        const SizedBox(height: 14),

                        // Parking Capacity
                        _buildCounterRow(
                          'Vehicle Parking Capacity',
                          _parkingCapacity,
                          (val) => setState(() => _parkingCapacity = val),
                          step: 5,
                          min: 2,
                          suffix: 'Cars',
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

                      final areaVal = _areaController.text.trim();
                      final farmAreaString = areaVal.isNotEmpty ? '$areaVal $_selectedAreaUnit' : '2.5 $_selectedAreaUnit';

                      final details = {
                        'farmArea': farmAreaString,
                        'farmAreaValue': areaVal.isNotEmpty ? areaVal : '2.5',
                        'farmAreaUnit': _selectedAreaUnit,
                        'overnightCapacity': _overnightCapacity,
                        'eventCapacity': _eventCapacity,
                        'dayEventCapacity': _eventCapacity,
                        'guests': _overnightCapacity,
                        'bedrooms': _bedrooms,
                        'bathrooms': _bathrooms,
                        'parkingCapacity': _parkingCapacity,
                        'vehicleParkingCapacity': '$_parkingCapacity Cars',
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

  Widget _buildSectionLabel(String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildAreaPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Farm / Land Area',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _areaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 2.5',
                    hintStyle: TextStyle(fontSize: 14, color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9FB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedAreaUnit,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                    items: const [
                      DropdownMenuItem(value: 'Acres', child: Text('Acres', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                      DropdownMenuItem(value: 'Guntas', child: Text('Guntas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                      DropdownMenuItem(value: 'Sq. Yards', child: Text('Sq. Yards', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                      DropdownMenuItem(value: 'Sq. Feet', child: Text('Sq. Feet', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                      DropdownMenuItem(value: 'Bigha', child: Text('Bigha', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedAreaUnit = val);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterRow(
    String title,
    int value,
    ValueChanged<int> onChanged, {
    int step = 1,
    int min = 1,
    String suffix = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                onTap: () => onChanged(value > (min + step - 1) ? value - step : min),
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
                suffix.isEmpty ? (value < 10 ? '0$value' : '$value') : '$value $suffix',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
