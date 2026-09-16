import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HostEarningsAnalyticsScreen extends StatelessWidget {
  const HostEarningsAnalyticsScreen({Key? key}) : super(key: key);

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
          'Earnings',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EDF7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Text('Month', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary, size: 18),
              ],
            ),
          ),
        ],
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Earnings Header matching 69.png
              const Text('Total Earnings', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              const Text('₹ 1,24,000', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('+ 12.5% vs This Month', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),

              const SizedBox(height: 24),

              // Bar Chart Graph Container matching 69.png
              Container(
                height: 180,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar(100),
                    _buildBar(70),
                    _buildBar(85),
                    _buildBar(110),
                    _buildBar(65),
                    _buildBar(90),
                    _buildBar(120),
                    _buildBar(80),
                    _buildBar(95),
                    _buildBar(60),
                    _buildBar(130),
                    _buildBar(105),
                    _buildBar(140),
                    _buildBar(115),
                    _buildBar(160),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('1 May', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text('10 May', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text('20 May', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text('31 May', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),

              const SizedBox(height: 28),

              // Pending Payout Box matching 69.png
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EDF7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Pending Payout', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    Text('₹24,000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    SizedBox(height: 4),
                    Text('Payout on 5th jun 2024', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Platform commission Tile matching 69.png
              _buildListTile('Platform commission', '₹14,000'),
              const SizedBox(height: 12),

              // Transactions Tile matching 69.png
              _buildListTile('Transactions', ''),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 10,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildListTile(String title, String trailingText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Row(
            children: [
              if (trailingText.isNotEmpty)
                Text(trailingText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
              if (trailingText.isNotEmpty) const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
