import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_placeholder.dart';
import 'select_room_screen_54.dart';

class NearbyStayDetailsScreen extends StatefulWidget {
  const NearbyStayDetailsScreen({Key? key}) : super(key: key);

  @override
  State<NearbyStayDetailsScreen> createState() => _NearbyStayDetailsScreenState();
}

class _NearbyStayDetailsScreenState extends State<NearbyStayDetailsScreen> {
  String _checkInDate = '12 May, Monday';
  String _checkOutDate = '15 May, Thursday';
  String _guests = '2 Adult, 1 Child';
  String _rooms = '1 Room';
  String _pets = 'No Peats';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nearby Stay',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Villa Card with Image & Specs matching 40.png
                    Stack(
                      children: [
                        const CustomImagePlaceholder(
                          height: 200,
                          width: double.infinity,
                          icon: Icons.villa_rounded,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        Positioned(
                          top: 14,
                          left: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Superhot',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF5A5F)),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.favorite_outline_rounded, color: Color(0xFFFF5A5F), size: 20),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Property Title & Location Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Aranya Heritage Villa',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7EC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
                              SizedBox(width: 4),
                              Text('4.2', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 16),
                        SizedBox(width: 4),
                        Text('Jaipur, Rajasthan', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '₹ 4,000 / night',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),

                    const SizedBox(height: 24),

                    // Check-In / Check-Out Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildPickerCard(
                            title: 'Check In',
                            value: _checkInDate,
                            icon: Icons.calendar_today_rounded,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildPickerCard(
                            title: 'Check Out',
                            value: _checkOutDate,
                            icon: Icons.calendar_today_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Guests Selector Box
                    _buildSelectionRow('Guests', _guests),
                    const SizedBox(height: 14),

                    // Rooms Selector Box
                    _buildSelectionRow('Rooms', _rooms),
                    const SizedBox(height: 14),

                    // Pets Selector Box
                    _buildSelectionRow('Pets', _pets),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Bar matching 40.png
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '₹ 2,540',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text('Per night', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                  SizedBox(
                    width: 160,
                    child: CustomButton(
                      text: 'Book Now',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SelectRoomScreen()),
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

  Widget _buildPickerCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildSelectionRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}
