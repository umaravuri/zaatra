import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'host_home_dashboard_screen_37.dart';
import '../../../services/auth_service.dart';
import '../../../services/host_service.dart';
import '../role_selection_screen_27.dart';

class HostPropertySubmittedThankYouScreen extends StatefulWidget {
  final String propertyTitle;
  final String propertyType;
  final String pricePerNight;
  final String? hostPhone;
  final String? hostName;

  const HostPropertySubmittedThankYouScreen({
    super.key,
    this.propertyTitle = 'Sea View Villa',
    this.propertyType = 'Villa',
    this.pricePerNight = '₹ 4,500 / night',
    this.hostPhone,
    this.hostName,
  });

  @override
  State<HostPropertySubmittedThankYouScreen> createState() => _HostPropertySubmittedThankYouScreenState();
}

class _HostPropertySubmittedThankYouScreenState extends State<HostPropertySubmittedThankYouScreen> {
  bool _isChecking = false;

  void _checkApprovalStatus() async {
    setState(() => _isChecking = true);

    final prefs = await SharedPreferences.getInstance();
    final phone = widget.hostPhone ?? prefs.getString('currentPhone') ?? '';
    final result = await HostService.checkHostApprovalStatus(hostPhone: phone);

    if (!mounted) return;
    setState(() => _isChecking = false);

    if (result.status == HostApprovalStatus.approved) {
      final name = widget.hostName ?? await AuthService.getUserName(phone: phone);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Your property has been approved by Admin! Welcome to your Dashboard.'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HostHomeDashboardScreen(userName: name)),
        (route) => false,
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.hourglass_top_rounded, color: Color(0xFFE65100)),
              SizedBox(width: 8),
              Expanded(
                child: Text('Application Under Review', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: const Text(
            'Thank you for registering your property with us. Your application is under review.\n\nYou will be able to access your host dashboard once your property is approved by the admin team.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
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
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary.withOpacity(0.08),
                                    ),
                                  ),
                                  Container(
                                    width: 95,
                                    height: 95,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary.withOpacity(0.18),
                                    ),
                                  ),
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [AppColors.primary, Color(0xFFFFA000)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x3DFBC02D),
                                          blurRadius: 18,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.hourglass_top_rounded,
                                      color: Colors.white,
                                      size: 38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Thank You!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Application Under Review',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE65100),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'Thank you for registering your property with us. Your application is under review.\n\nYou will be able to access your host dashboard once your property is approved.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBF9FD),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE8DEF8), width: 1.2),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.villa_rounded, color: AppColors.primary, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.propertyTitle,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              '${widget.propertyType} • ${widget.pricePerNight}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10.0),
                                    child: Divider(height: 1, color: Color(0xFFE8DEF8)),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: const [
                                          Icon(Icons.pending_actions_rounded, size: 16, color: Color(0xFFE65100)),
                                          SizedBox(width: 6),
                                          Text(
                                            'Status: Pending Admin Approval',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFE65100),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF3E0),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'Pending',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFE65100),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: 'Go to Dashboard',
                              onPressed: _isChecking ? () {} : _checkApprovalStatus,
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                icon: _isChecking
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 18),
                                label: Text(
                                  _isChecking ? 'Checking Status...' : 'Check Approval Status',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
                                ),
                                onPressed: _isChecking ? null : _checkApprovalStatus,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                                  (route) => false,
                                );
                              },
                              child: const Text(
                                'Back to Home / Switch Account',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
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
