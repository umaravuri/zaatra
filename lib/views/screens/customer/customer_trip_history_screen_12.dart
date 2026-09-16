import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomerTripHistoryScreen extends StatefulWidget {
  const CustomerTripHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CustomerTripHistoryScreen> createState() => _CustomerTripHistoryScreenState();
}

class _CustomerTripHistoryScreenState extends State<CustomerTripHistoryScreen> {
  int _selectedTabIndex = 0; // 0: All, 1: Complete, 2: Cancelled

  final List<Map<String, String>> _trips = const [
    {'from': 'Madhapur', 'to': 'Secundrabad', 'dateTime': '20 May 2024 - 09 : 00 AM', 'status': 'Complete'},
    {'from': 'Madhapur', 'to': 'Secundrabad', 'dateTime': '20 May 2024 - 09 : 00 AM', 'status': 'Complete'},
    {'from': 'Madhapur', 'to': 'Secundrabad', 'dateTime': '20 May 2024 - 09 : 00 AM', 'status': 'Complete'},
    {'from': 'Madhapur', 'to': 'Secundrabad', 'dateTime': '20 May 2024 - 09 : 00 AM', 'status': 'Complete'},
    {'from': 'Madhapur', 'to': 'Secundrabad', 'dateTime': '20 May 2024 - 09 : 00 AM', 'status': 'Complete'},
    {'from': 'Madhapur', 'to': 'Secundrabad', 'dateTime': '20 May 2024 - 09 : 00 AM', 'status': 'Complete'},
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
          'Trip History',
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
            // Segmented Tabs Header matching 12.png
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(child: _buildTabButton('All', 0)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTabButton('Complete', 1)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTabButton('Cancelled', 2)),
                ],
              ),
            ),

            // Trip Cards List matching 12.png
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: _trips.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final trip = _trips[index];

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3EDF7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.alt_route_rounded, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(trip['from']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 16),
                                  const SizedBox(width: 8),
                                  Text(trip['to']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(trip['dateTime']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            trip['status']!,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ],
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

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF3EDF7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
