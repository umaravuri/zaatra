import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../auth/login_screen_115.dart';

class HostProfileSettingsScreen extends StatelessWidget {
  final String? userName;
  const HostProfileSettingsScreen({Key? key, this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Personal Information', 'icon': Icons.person_outline_rounded},
      {'title': 'Bank Account', 'icon': Icons.account_balance_outlined},
      {'title': 'Security settings', 'icon': Icons.shield_outlined},
      {'title': 'Privacy & Policy', 'icon': Icons.privacy_tip_outlined},
      {'title': 'Help & Support', 'icon': Icons.notifications_none_rounded},
      {'title': 'Term & Conditions', 'icon': Icons.lock_outline_rounded},
      {'title': 'Notification Preferences', 'icon': Icons.notifications_none_rounded},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
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
            SingleChildScrollView(
        child: Column(
          children: [
            // Header with Purple Gradient Background matching 85.png
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('Za', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: userName != null && userName!.trim().isNotEmpty
                          ? Future.value(userName!.trim())
                          : AuthService.getUserName(),
                      builder: (context, snapshot) {
                        final displayName = snapshot.data ?? 'Host User';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text('Verified Host', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Settings List Container matching 85.png
            Container(
              transform: Matrix4.translationValues(0, -16, 0),
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  ...List.generate(menuItems.length, (index) {
                    final item = menuItems[index];

                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(item['icon'] as IconData, color: AppColors.textPrimary, size: 22),
                          title: Text(
                            item['title'] as String,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                          onTap: () {},
                        ),
                        const Divider(height: 16, color: AppColors.border),
                      ],
                    );
                  }),

                  const SizedBox(height: 32),

                  // Logout CTA Button matching 85.png
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEBEE),
                        side: const BorderSide(color: Colors.transparent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        await AuthService.logout();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logged Out Successfully.'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen(isExistingUser: true)),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text('App Version 2.5.0', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
          ],
        ),
    );
  }
}
