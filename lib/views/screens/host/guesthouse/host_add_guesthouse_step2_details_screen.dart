import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../common/host_add_property_step3_common.dart';

class HostAddGuestHouseStep2DetailsScreen extends StatefulWidget {
  final String selectedCategory;

  const HostAddGuestHouseStep2DetailsScreen({
    Key? key,
    this.selectedCategory = 'Guest House',
  }) : super(key: key);

  @override
  State<HostAddGuestHouseStep2DetailsScreen> createState() => _HostAddGuestHouseStep2DetailsScreenState();
}

class _HostAddGuestHouseStep2DetailsScreenState extends State<HostAddGuestHouseStep2DetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _guestRooms = 0;
  int _attachedBaths = 0;
  int _sharedBaths = 0;
  int _maxGuests = 0;

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
            Text('Set 2 by 9 (Guest House Details)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                        const Text('Guest House Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Enter private room count, bathroom setup and common area details', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
                              Icon(Icons.home_work_rounded, color: AppColors.primary, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Guest House & Homestay',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Guest House Name
                        CustomTextField(
                          label: 'Guest House / Homestay Name',
                          hint: 'Enter guest house name here',
                          controller: _nameController,
                        ),
                        const SizedBox(height: 20),

                        // Private Guest Rooms Counter
                        _buildCounterRow('No: of Private Guest Rooms', _guestRooms, (val) => setState(() => _guestRooms = val)),
                        const SizedBox(height: 16),

                        // Attached Bathrooms Counter
                        _buildCounterRow('Attached Bathrooms', _attachedBaths, (val) => setState(() => _attachedBaths = val)),
                        const SizedBox(height: 16),

                        // Shared / Common Bathrooms
                        _buildCounterRow('Shared / Hallway Bathrooms', _sharedBaths, (val) => setState(() => _sharedBaths = val)),
                        const SizedBox(height: 16),

                        // Total Guest Capacity Counter
                        _buildCounterRow('Total Max Guest Capacity', _maxGuests, (val) => setState(() => _maxGuests = val), step: 2),
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
                          const SnackBar(content: Text('Please enter a guest house name.'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      if (_guestRooms <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter at least 1 guest room.'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      final details = {
                        'rooms': _guestRooms,
                        'attachedBaths': _attachedBaths,
                        'sharedBaths': _sharedBaths,
                        'bedrooms': _guestRooms,
                        'bathrooms': _attachedBaths + _sharedBaths,
                        'capacity': _maxGuests,
                        'guests': _maxGuests,
                        'parkingCapacity': _guestRooms,
                        'vehicleParkingCapacity': '$_guestRooms Cars',
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
