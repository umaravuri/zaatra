import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_image_placeholder.dart';

class DriverRatingsReviewsScreen extends StatelessWidget {
  const DriverRatingsReviewsScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> _starsBreakdown = const [
    {'stars': 5, 'ratio': 0.85, 'count': 85},
    {'stars': 4, 'ratio': 0.45, 'count': 31},
    {'stars': 3, 'ratio': 0.25, 'count': 9},
    {'stars': 2, 'ratio': 0.10, 'count': 2},
    {'stars': 1, 'ratio': 0.05, 'count': 1},
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
          'Ratings',
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
            SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Overall Rating Number Header matching 113.png
              const Text(
                '4.8',
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),

              const SizedBox(height: 6),

              // 5 Gold Stars Row matching 113.png
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 24);
                }),
              ),

              const SizedBox(height: 6),

              const Text(
                'Based on 126 reviews',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 28),

              // Rating Progress Bars List matching 113.png
              Column(
                children: _starsBreakdown.map((item) {
                  final stars = item['stars'] as int;
                  final ratio = item['ratio'] as double;
                  final count = item['count'] as int;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Row(
                            children: [
                              Text('$stars', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              const SizedBox(width: 4),
                              const Icon(Icons.star_rounded, size: 14, color: AppColors.textPrimary),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFF3EDF7),
                              color: stars >= 3 ? const Color(0xFF4CAF50) : (stars == 2 ? Colors.orange : Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 30,
                          child: Text(
                            '$count',
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Customer Review Card Container matching 113.png
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CustomImagePlaceholder(
                          width: 44,
                          height: 44,
                          icon: Icons.person_rounded,
                          borderRadius: BorderRadius.all(Radius.circular(22)),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Neha Singh', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            const Text('20 May 2025', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (index) {
                                return const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14);
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 12),

                    const Text(
                      '“ Great experience drive was on time and very polite. “',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 10),

                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'View all reviews',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }
}
