import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HostRatingsReviewsScreen extends StatelessWidget {
  const HostRatingsReviewsScreen({Key? key}) : super(key: key);

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
              // Rating Score Header matching 114.png
              const Text('4.8', style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 24)),
              ),
              const SizedBox(height: 6),
              const Text('Based on 126 reviews', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),

              const SizedBox(height: 28),

              // Rating Progress Bars Breakdown matching 114.png
              _buildRatingBar('5', 0.85, '85'),
              const SizedBox(height: 8),
              _buildRatingBar('4', 0.40, '31'),
              const SizedBox(height: 8),
              _buildRatingBar('3', 0.25, '9'),
              const SizedBox(height: 8),
              _buildRatingBar('2', 0.10, '2'),
              const SizedBox(height: 8),
              _buildRatingBar('1', 0.05, '1'),

              const SizedBox(height: 32),

              // Customer Review Card matching 114.png
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF3EDF7)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3EDF7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Neha Singh', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            const Text('20 May 2025', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (index) => const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 14)),
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
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4, fontStyle: FontStyle.italic),
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 14),

                    const Center(
                      child: Text(
                        'View all reviews',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
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

  Widget _buildRatingBar(String starNumber, double percentage, String count) {
    return Row(
      children: [
        Text(starNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(width: 6),
        const Icon(Icons.star_rounded, size: 16, color: AppColors.textPrimary),
        const SizedBox(width: 14),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: const Color(0xFFF3EDF7),
              color: const Color(0xFF4CAF50),
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 24,
          child: Text(count, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}
