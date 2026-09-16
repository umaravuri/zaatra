import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_image_placeholder.dart';
import 'property_detail_screen_62.dart';

class StayMapSearchScreen extends StatelessWidget {
  const StayMapSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: const [
            Text('Goa, India', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('12 May - 15 May . 2 guest', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Stack(
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
            Stack(
        children: [
          // Interactive Map Box Container with Price Pins matching 53.png
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE8DEF8),
              child: Stack(
                children: [
                  _buildPricePin(top: 120, left: 80, price: '₹3,000'),
                  _buildPricePin(top: 180, left: 160, price: '₹4,500'),
                  _buildPricePin(top: 260, left: 90, price: '₹4,500'),
                  _buildPricePin(top: 200, right: 40, price: '₹2,000'),
                ],
              ),
            ),
          ),

          // Bottom Floating Property Card Overlay matching 53.png
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PropertyDetailScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 6)),
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      children: const [
                        CustomImagePlaceholder(
                          width: 90,
                          height: 80,
                          icon: Icons.villa_rounded,
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                        ),
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Icon(Icons.favorite_rounded, color: AppColors.primary, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('My Property', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          SizedBox(height: 4),
                          Text('Goa, India', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          SizedBox(height: 6),
                          Text('₹6,500 / night', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7EC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Text('4.5', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          SizedBox(width: 4),
                          Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
          ],
        ),
    );
  }

  Widget _buildPricePin({double? top, double? left, double? right, double? bottom, required String price}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        child: Text(
          price,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
