import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> _payments = const [
    {'title': 'Payment occen view report', 'date': '10 May 2025', 'amount': '₹ 12,550'},
    {'title': 'Payment occen view report', 'date': '10 May 2025', 'amount': '₹ 12,550'},
    {'title': 'Payment occen view report', 'date': '10 May 2025', 'amount': '₹ 12,550'},
    {'title': 'Payment occen view report', 'date': '10 May 2025', 'amount': '₹ 12,550'},
    {'title': 'Payment occen view report', 'date': '10 May 2025', 'amount': '₹ 12,550'},
    {'title': 'Payment occen view report', 'date': '10 May 2025', 'amount': '₹ 12,550'},
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
          'Payment History',
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
            ListView.separated(
          padding: const EdgeInsets.all(20.0),
          itemCount: _payments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final item = _payments[index];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']!,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['date']!,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item['amount']!,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Complete',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
          ],
        ),
      ),
    );
  }
}
