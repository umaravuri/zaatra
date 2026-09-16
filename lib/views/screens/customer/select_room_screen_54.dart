import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/hotel_model.dart';
import '../../widgets/custom_button.dart';
import 'booking_summary_screen_55.dart';

class SelectRoomScreen extends StatefulWidget {
  final Hotel? hotel;

  const SelectRoomScreen({
    super.key,
    this.hotel,
  });

  @override
  State<SelectRoomScreen> createState() => _SelectRoomScreenState();
}

class _SelectRoomScreenState extends State<SelectRoomScreen> {
  int _selectedRoomIndex = 0;

  Hotel get _activeHotel => widget.hotel ?? mockHotels[0];
  List<HotelRoom> get _activeRooms => _activeHotel.rooms;

  @override
  Widget build(BuildContext context) {
    final hotel = _activeHotel;
    final rooms = _activeRooms;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Select Room',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
            ),
            Text(
              hotel.title,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
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
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: rooms.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      final isSelected = _selectedRoomIndex == index;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedRoomIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF7F4FB) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? AppColors.primary.withAlpha(25) : Colors.black.withAlpha(8),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Room Thumbnail Image with fallback
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 84,
                                  height: 80,
                                  color: const Color(0xFFF3EDF7),
                                  child: Image.asset(
                                    room.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Icon(
                                        room.icon,
                                        size: 32,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Room Title, Price & Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      room.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      room.priceFormatted,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      room.specs,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      room.amenities,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF2E7D32),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // Select / Selected Button
                              ElevatedButton(
                                onPressed: () => setState(() => _selectedRoomIndex = index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected ? AppColors.primary : const Color(0xFFF3EDF7),
                                  foregroundColor: isSelected ? Colors.white : AppColors.primary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  minimumSize: const Size(70, 36),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  isSelected ? 'Selected' : 'Select',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Continue CTA Button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomButton(
                    text: 'Continue',
                    onPressed: () {
                      final chosenRoom = rooms[_selectedRoomIndex];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingSummaryScreen(
                            hotel: hotel,
                            selectedRoom: chosenRoom,
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
}
