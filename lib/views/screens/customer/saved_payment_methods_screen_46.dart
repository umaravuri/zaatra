import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';

class SavedPaymentMethodsScreen extends StatelessWidget {
  const SavedPaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved Payment Methods'),
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
            SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Zaatra Digital Wallet', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    const Text('\$250.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Add Funds to Wallet',
                      backgroundColor: Colors.white,
                      textColor: AppColors.primary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening Wallet Top-up Modal...')),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text('Saved Credit & Debit Cards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 14),

              _buildCardTile(
                type: 'Visa',
                cardNumber: '•••• •••• •••• 4242',
                expiry: 'Expires 12/28',
                isDefault: true,
                color: const Color(0xFF1A1F71),
              ),

              _buildCardTile(
                type: 'Mastercard',
                cardNumber: '•••• •••• •••• 8899',
                expiry: 'Expires 08/27',
                isDefault: false,
                color: const Color(0xFFEB001B),
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: 'Add New Card',
                isOutlined: true,
                icon: Icons.add_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add New Card form dialog opened.')),
                  );
                },
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTile({
    required String type,
    required String cardNumber,
    required String expiry,
    required bool isDefault,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(8)),
            child: Text(type, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cardNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(expiry, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primaryBackground, borderRadius: BorderRadius.circular(6)),
              child: const Text('Default', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
        ],
      ),
    );
  }
}
