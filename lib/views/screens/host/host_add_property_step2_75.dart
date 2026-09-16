import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'host_add_property_step3_78.dart';

class HostAddPropertyStep2Screen extends StatefulWidget {
  final String? selectedCategory;

  const HostAddPropertyStep2Screen({Key? key, this.selectedCategory}) : super(key: key);

  @override
  State<HostAddPropertyStep2Screen> createState() => _HostAddPropertyStep2ScreenState();
}

class _HostAddPropertyStep2ScreenState extends State<HostAddPropertyStep2Screen> {
  final TextEditingController _nameController = TextEditingController();
  late String _selectedCategory;

  final List<String> _propertyTypes = [
    'Resort',
    'Villa',
    'Farmhouse',
    'Hotel',
    'Guest House',
  ];

  // Master Total Rooms Controller for Hotel
  final TextEditingController _totalRoomsController = TextEditingController(text: '0');

  // Hotel Specific Room Sharing Controllers
  final TextEditingController _singleRegController = TextEditingController(text: '0');
  final TextEditingController _singleLuxController = TextEditingController(text: '0');
  final TextEditingController _doubleRegController = TextEditingController(text: '0');
  final TextEditingController _doubleLuxController = TextEditingController(text: '0');

  // Standard Property Counters
  final TextEditingController _bedroomsController = TextEditingController(text: '0');
  final TextEditingController _bathroomsController = TextEditingController(text: '0');

  int _getInt(TextEditingController ctrl) {
    return int.tryParse(ctrl.text.trim()) ?? 0;
  }

  void _setInt(TextEditingController ctrl, int value) {
    final validVal = value < 0 ? 0 : value;
    ctrl.text = validVal.toString();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory ?? 'Resort';
    if (!_propertyTypes.contains(_selectedCategory)) {
      if (_selectedCategory.toLowerCase().contains('hotel')) {
        _selectedCategory = 'Hotel';
      } else if (_selectedCategory.toLowerCase().contains('guest')) {
        _selectedCategory = 'Guest House';
      } else {
        _selectedCategory = 'Resort';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalRoomsController.dispose();
    _singleRegController.dispose();
    _singleLuxController.dispose();
    _doubleRegController.dispose();
    _doubleLuxController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHotel = _selectedCategory.toLowerCase().contains('hotel');

    final totalRooms = _getInt(_totalRoomsController);
    final singleReg = _getInt(_singleRegController);
    final singleLux = _getInt(_singleLuxController);
    final doubleReg = _getInt(_doubleRegController);
    final doubleLux = _getInt(_doubleLuxController);
    final allocatedRooms = singleReg + singleLux + doubleReg + doubleLux;
    final isAllocationExact = totalRooms > 0 && allocatedRooms == totalRooms;
    final remainingRooms = totalRooms - allocatedRooms;

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
            Text('Step 2 of 9', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
            // Bottom Background Graphic (image 31.png)
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
                        const Text('Property details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Details for your selected property type', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),

                        const SizedBox(height: 24),

                        // Property Type Selector Dropdown Box
                        const Text('Property Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                              items: _propertyTypes.map((String type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                                      const SizedBox(width: 10),
                                      Text(
                                        type,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedCategory = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Property Name Field
                        CustomTextField(
                          label: 'Property Name',
                          hint: 'Enter property name here',
                          controller: _nameController,
                        ),

                        const SizedBox(height: 20),

                        // Dynamic Fields
                        if (isHotel) ...[
                          // 🏨 MASTER TOTAL ROOMS FIELD WITH DIRECT INPUT
                          _buildEditableCounterRow(
                            'Total Number of Rooms',
                            _totalRoomsController,
                            isMaster: true,
                          ),
                          if (!isAllocationExact && totalRooms > 0) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFFD54F), width: 1.2),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFF57F17), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      remainingRooms > 0
                                          ? '$remainingRooms room(s) remaining to allocate ($allocatedRooms / $totalRooms)'
                                          : 'Allocated rooms exceed total rooms by ${-remainingRooms} ($allocatedRooms / $totalRooms)',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFF57F17)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),
                          const Text(
                            'Room Category Breakdown',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 12),

                          _buildEditableCounterRow(
                            'No:of Single Sharing Regular Rooms',
                            _singleRegController,
                          ),
                          const SizedBox(height: 16),
                          _buildEditableCounterRow(
                            'No:of Single Sharing Luxury Rooms',
                            _singleLuxController,
                          ),
                          const SizedBox(height: 16),
                          _buildEditableCounterRow(
                            'No:of Double Sharing Regular Rooms',
                            _doubleRegController,
                          ),
                          const SizedBox(height: 16),
                          _buildEditableCounterRow(
                            'No:of Double Sharing Luxury Rooms',
                            _doubleLuxController,
                          ),
                        ] else ...[
                          // 🏡 RESORT / VILLA / FARMHOUSE / GUEST HOUSE COUNTERS
                          _buildEditableCounterRow(
                            'No:of Bed rooms',
                            _bedroomsController,
                          ),
                          const SizedBox(height: 16),
                          _buildEditableCounterRow(
                            'No:of Bath rooms',
                            _bathroomsController,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Allocation mismatch banner
                if (isHotel && (totalRooms <= 0 || allocatedRooms != totalRooms))
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFB74D)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            totalRooms <= 0
                                ? 'Please enter a total number of rooms (at least 1).'
                                : remainingRooms > 0
                                    ? 'Total rooms ($totalRooms) does not match sum of rooms ($allocatedRooms). Please allocate $remainingRooms more room(s).'
                                    : 'Sum of rooms ($allocatedRooms) exceeds total rooms ($totalRooms) by ${-remainingRooms}. Cannot proceed until counts match.',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFFE65100)),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Primary Next Button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomButton(
                    text: 'Next',
                    onPressed: () {
                      final propertyName = _nameController.text.trim();
                      if (propertyName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a property name.'), backgroundColor: Colors.red),
                        );
                        return;
                      }

                      if (isHotel) {
                        if (totalRooms <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Total number of rooms must be at least 1.'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        if (allocatedRooms != totalRooms) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                remainingRooms > 0
                                    ? 'Room allocation mismatch! Sum of categories ($allocatedRooms) is less than total rooms ($totalRooms). Please allocate the remaining $remainingRooms room(s).'
                                    : 'Room allocation mismatch! Sum of categories ($allocatedRooms) exceeds total rooms ($totalRooms) by ${-remainingRooms} room(s). Cannot proceed until room numbers match.',
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                          return;
                        }
                      } else {
                        final bedrooms = _getInt(_bedroomsController);
                        if (bedrooms <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter at least 1 bedroom.'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                      }

                      final propertyData = {
                        'propertyType': _selectedCategory,
                        'propertyName': propertyName,
                        'totalRooms': totalRooms,
                        'singleSharingRegularRooms': singleReg,
                        'singleSharingLuxuryRooms': singleLux,
                        'doubleSharingRegularRooms': doubleReg,
                        'doubleSharingLuxuryRooms': doubleLux,
                      };

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HostAddPropertyStep3Screen(
                            selectedCategory: _selectedCategory,
                            propertyName: propertyName,
                            propertyData: propertyData,
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

  Widget _buildEditableCounterRow(
    String title,
    TextEditingController controller, {
    bool isMaster = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isMaster ? FontWeight.w800 : FontWeight.bold,
                  color: isMaster ? AppColors.primary : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Type or click + / -',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isMaster ? const Color(0xFFF7F5FE) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isMaster ? AppColors.primary.withOpacity(0.5) : AppColors.border,
              width: isMaster ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Decrement Button
              InkWell(
                onTap: () {
                  final current = _getInt(controller);
                  _setInt(controller, current > 0 ? current - 1 : 0);
                },
                borderRadius: BorderRadius.circular(10),
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

              // Direct Numeric Input Box
              SizedBox(
                width: 80,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isMaster ? AppColors.primary : AppColors.textPrimary,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: (val) {
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),

              // Increment Button
              InkWell(
                onTap: () {
                  final current = _getInt(controller);
                  _setInt(controller, current + 1);
                },
                borderRadius: BorderRadius.circular(10),
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
