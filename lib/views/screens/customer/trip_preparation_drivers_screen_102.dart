import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/ride_booking_model.dart';
import 'driver_booking_detail_screen_104.dart';

class TripPreparationDriversScreen extends StatefulWidget {
  final String pickup;
  final String destination;
  final String date;
  final String time;
  final String passengers;
  final String paidForSeat;
  final String luggage;

  const TripPreparationDriversScreen({
    super.key,
    this.pickup = 'Madhapur',
    this.destination = 'Secunderabad',
    this.date = '20 May 2026',
    this.time = '09:30 AM',
    this.passengers = '3 Seats',
    this.paidForSeat = '₹ 550',
    this.luggage = '1 Medium Bag',
  });

  @override
  State<TripPreparationDriversScreen> createState() => _TripPreparationDriversScreenState();
}

class _TripPreparationDriversScreenState extends State<TripPreparationDriversScreen> {
  final List<RideDriver> _drivers = mockRideDrivers;

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
          'Trip Preparation',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
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
                        // Route Info Box matching 102.png
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.pickup,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 18),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      widget.destination,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${widget.date} - ${widget.time}',
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Sort / Filter / Map Chips Row matching 102.png
                        Row(
                          children: [
                            Expanded(child: _buildChip(Icons.swap_vert_rounded, 'Sort')),
                            const SizedBox(width: 10),
                            Expanded(child: _buildChip(Icons.filter_list_rounded, 'Filter')),
                            const SizedBox(width: 10),
                            Expanded(child: _buildChip(Icons.map_outlined, 'Map')),
                          ],
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Available drivers',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),

                        const SizedBox(height: 16),

                        // Driver Cards List matching 102.png
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _drivers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final driver = _drivers[index];

                            return GestureDetector(
                              onTap: () {
                                final count = int.tryParse(widget.passengers.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
                                final effectiveSeats = count > 0 ? count : 1;
                                final session = RideBookingSession(
                                  driver: driver,
                                  pickup: widget.pickup,
                                  destination: widget.destination,
                                  date: widget.date,
                                  time: widget.time,
                                  seatsCount: effectiveSeats,
                                  totalAmount: driver.pricePerSeat * effectiveSeats,
                                  luggage: widget.luggage,
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DriverBookingDetailScreen(session: session),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        color: const Color(0xFFF3EDF7),
                                        child: Image.asset(
                                          driver.avatarImage,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Center(
                                            child: Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            driver.name,
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            driver.carModel,
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${driver.seatsAvailable} seats left • Departure ${driver.departureTime}',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹ ${driver.pricePerSeat.toStringAsFixed(0)}',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF7EC),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                '${driver.rating}',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDF7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.textPrimary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
