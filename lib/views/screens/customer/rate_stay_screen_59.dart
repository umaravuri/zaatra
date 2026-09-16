import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';

class RateStayScreen extends StatefulWidget {
  const RateStayScreen({Key? key}) : super(key: key);

  @override
  State<RateStayScreen> createState() => _RateStayScreenState();
}

class _RateStayScreenState extends State<RateStayScreen> {
  int _rating = 4;
  final _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rate your Stay',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Title Header matching 59.png
                    const Text(
                      'How was your\nrating in sun set beach villa',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 5 Star Interactive Rating Bar matching 59.png
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setState(() => _rating = index + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Icon(
                              index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: index < _rating ? const Color(0xFFFFB800) : const Color(0xFFFFE0B2),
                              size: 44,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 36),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Say anything',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Multi-line Review Input Field matching 59.png
                    TextField(
                      controller: _reviewController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Enter here',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: const Color(0xFFF9F8FD),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Submit Review CTA matching 59.png
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: CustomButton(
                text: 'Submit Review',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you! Review submitted successfully.')),
                  );
                  Navigator.pop(context);
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
