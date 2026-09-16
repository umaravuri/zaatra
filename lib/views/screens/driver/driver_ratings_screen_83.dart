import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DriverRatingsScreen extends StatelessWidget {
  const DriverRatingsScreen({Key? key}) : super(key: key);

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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Rating Score & Stars Header matching Image 3
              const Text(
                '4.8',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),

              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 24),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Based on 126 reviews',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 28),

              // Progress Bar Ratings Breakdown matching Image 3
              _buildRatingProgressRow('5', 0.85, '85'),
              const SizedBox(height: 10),
              _buildRatingProgressRow('4', 0.50, '31'),
              const SizedBox(height: 10),
              _buildRatingProgressRow('3', 0.30, '9'),
              const SizedBox(height: 10),
              _buildRatingProgressRow('2', 0.12, '2', progressColor: const Color(0xFFFF9800)),
              const SizedBox(height: 10),
              _buildRatingProgressRow('1', 0.08, '1', progressColor: const Color(0xFFE53935)),

              const SizedBox(height: 32),

              // Customer Review Card matching Image 3
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withAlpha(25)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBackground,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Neha Singh', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            const Text('20 May 2025', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(
                                5,
                                (index) => const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 16),
                    const Text(
                      '“ Great experience drive was on time and very polite. “',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 20),
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

  Widget _buildRatingProgressRow(String starLabel, double percentage, String countLabel, {Color progressColor = const Color(0xFF4CAF50)}) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Row(
            children: [
              Text(starLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(width: 4),
              const Icon(Icons.star_rounded, size: 12, color: AppColors.textPrimary),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 10,
              backgroundColor: const Color(0xFFF3EDF7),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 28,
          child: Text(
            countLabel,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
