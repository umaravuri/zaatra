import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'host_profile_settings_screen_85.dart';

class HostMoreMenuScreen extends StatelessWidget {
  final String? userName;
  const HostMoreMenuScreen({Key? key, this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Promotions', 'icon': Icons.local_offer_outlined},
      {'title': 'Reports & Analysis', 'icon': Icons.insert_chart_outlined_rounded},
      {'title': 'Support & Help', 'icon': Icons.headset_mic_outlined},
      {'title': 'Profile & settings', 'icon': Icons.person_outline_rounded},
      {'title': 'Notifications', 'icon': Icons.notifications_none_rounded},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'More',
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
          itemCount: menuItems.length,
          separatorBuilder: (context, index) => const Divider(height: 24, color: AppColors.border),
          itemBuilder: (context, index) {
            final item = menuItems[index];

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(item['icon'] as IconData, color: AppColors.textPrimary, size: 24),
              title: Text(
                item['title'] as String,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              onTap: () {
                if (item['title'] == 'Profile & settings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HostProfileSettingsScreen(userName: userName)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening ${item['title']}...')),
                  );
                }
              },
            );
          },
        ),
          ],
        ),
      ),
    );
  }
}
