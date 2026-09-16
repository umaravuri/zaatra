import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_placeholder.dart';
import 'driver_trip_prep_stops_screen_101.dart';

class DriverTripPrepNotesScreen extends StatefulWidget {
  const DriverTripPrepNotesScreen({Key? key}) : super(key: key);

  @override
  State<DriverTripPrepNotesScreen> createState() => _DriverTripPrepNotesScreenState();
}

class _DriverTripPrepNotesScreenState extends State<DriverTripPrepNotesScreen> {
  final _notesController = TextEditingController();

  final List<Map<String, String>> _passengers = const [
    {'name': 'Ramesh Verma', 'seat': 'Seat 1'},
    {'name': 'Ramesh Verma', 'seat': 'Seat 2'},
    {'name': 'Ramesh Verma', 'seat': 'Seat 3'},
  ];

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
                    // Route Box matching 100.png
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Text('Madhapur', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              SizedBox(width: 12),
                              Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 18),
                              SizedBox(width: 12),
                              Text('Secundrabad', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text('20 May 2024 - 09 : 00 AM', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Passengers (3)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),

                    const SizedBox(height: 12),

                    // Passenger List Card matching 100.png
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: List.generate(_passengers.length, (index) {
                          final p = _passengers[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: index < _passengers.length - 1 ? 14 : 0),
                            child: Row(
                              children: [
                                const CustomImagePlaceholder(
                                  width: 44,
                                  height: 44,
                                  icon: Icons.person_rounded,
                                  borderRadius: BorderRadius.all(Radius.circular(22)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                      const SizedBox(height: 2),
                                      Text(p['seat']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF3EDF7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.phone_rounded, color: AppColors.primary, size: 18),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Pickup Point Row matching 100.png
                    const Text('Pickup Point', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('pink square mall,Madhapur', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        Text('07 : 45 AM', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Notes Field matching 100.png
                    const Text('Notes to driver', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _notesController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Enter here',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: const Color(0xFFF9F8FD),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Message All CTA matching 100.png
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomButton(
                text: 'Message All',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverTripPrepStopsScreen()),
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
