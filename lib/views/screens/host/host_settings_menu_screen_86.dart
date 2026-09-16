import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../auth/login_screen_115.dart';
import '../customer/help_support_screen_48.dart';
import '../customer/my_bookings_list_screen_46.dart';
import '../customer/saved_payment_methods_screen_46.dart';
import 'host_profile_settings_screen_85.dart';

class HostSettingsMenuScreen extends StatelessWidget {
  const HostSettingsMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Profile Banner matching 86.png
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'Z',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: AuthService.getUserName(),
                        builder: (context, snapshot) {
                          final hostName = snapshot.data ?? 'Host';
                          return Text(
                            hostName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Host Since may 2022',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // White Menu Container Body matching 86.png
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          _buildMenuItem(
                            icon: Icons.person_outline_rounded,
                            title: 'My Profile',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const HostProfileSettingsScreen()),
                              );
                            },
                          ),
                          const Divider(color: AppColors.border),
                          _buildMenuItem(
                            icon: Icons.credit_card_rounded,
                            title: 'Payment Methods',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SavedPaymentMethodsScreen()),
                              );
                            },
                          ),
                          const Divider(color: AppColors.border),
                          _buildMenuItem(
                            icon: Icons.shield_outlined,
                            title: 'Saved addressed',
                            onTap: () {},
                          ),
                          const Divider(color: AppColors.border),
                          _buildMenuItem(
                            icon: Icons.receipt_long_outlined,
                            title: 'My bookings',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MyBookingsListScreen()),
                              );
                            },
                          ),
                          const Divider(color: AppColors.border),
                          _buildMenuItem(
                            icon: Icons.notifications_none_rounded,
                            title: 'Help & Support',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                              );
                            },
                          ),
                          const Divider(color: AppColors.border),
                          _buildMenuItem(
                            icon: Icons.settings_outlined,
                            title: 'Settings',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    // Logout Button matching 86.png
                    GestureDetector(
                      onTap: () async {
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
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'Logout',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Text('App Version 2.5.0', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Icon(icon, color: AppColors.textPrimary, size: 24),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
