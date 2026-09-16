import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomerNotificationsScreen extends StatelessWidget {
  const CustomerNotificationsScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> _notifications = const [
    {'title': 'Booking Conformed', 'subtitle': 'Your booking is processing', 'time': '2m ago'},
    {'title': 'Booking Conformed', 'subtitle': 'Your booking is processing', 'time': '2m ago'},
    {'title': 'Booking Conformed', 'subtitle': 'Your booking is processing', 'time': '2m ago'},
    {'title': 'Booking Conformed', 'subtitle': 'Your booking is processing', 'time': '2m ago'},
    {'title': 'Booking Conformed', 'subtitle': 'Your booking is processing', 'time': '2m ago'},
    {'title': 'Booking Conformed', 'subtitle': 'Your booking is processing', 'time': '2m ago'},
    {'title': 'Booking Conformed', 'subtitle': 'Your booking is processing', 'time': '2m ago'},
    {'title': 'Booking Conformed', 'subtitle': 'Your booking is processing', 'time': '2m ago'},
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
          'Notification',
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
          itemCount: _notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final notif = _notifications[index];

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEBEE),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'B',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif['title']!,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notif['subtitle']!,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    notif['time']!,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
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
