import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DriverSupportHelpScreen extends StatelessWidget {
  const DriverSupportHelpScreen({Key? key}) : super(key: key);

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
          'Support & Help',
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
            Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Help Center',
                    subtitle: 'Bropers helpful articles',
                  ),
                  const Divider(height: 24, color: AppColors.border),
                  _buildMenuItem(
                    context,
                    icon: Icons.confirmation_number_outlined,
                    title: 'Raise a Tickets',
                    subtitle: 'Get help from our teams',
                  ),
                  const Divider(height: 24, color: AppColors.border),
                  _buildMenuItem(
                    context,
                    icon: Icons.open_in_browser_rounded,
                    title: 'FAQ',
                    subtitle: 'Find answers quickly',
                  ),
                  const Divider(height: 24, color: AppColors.border),
                  _buildMenuItem(
                    context,
                    icon: Icons.call_outlined,
                    title: 'Call Supports',
                    subtitle: '+ 91 000-000-0000',
                  ),
                  const Divider(height: 24, color: AppColors.border),
                  _buildMenuItem(
                    context,
                    icon: Icons.description_outlined,
                    title: 'Teams & Policies',
                    subtitle: 'Platform polices & rules',
                  ),
                ],
              ),
            ),

            // Bottom Still Need Help Banner matching Image 1
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Still Need Help',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'We are have for you 24/7',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3EDF7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 48),
                  ),
                ],
              ),
            ),
          ],
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $title...')),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F5FE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary, size: 22),
          ],
        ),
      ),
    );
  }
}
