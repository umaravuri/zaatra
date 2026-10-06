import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../widgets/custom_button.dart';
import 'customer/customer_home_screen_38.dart';
import 'host/host_home_dashboard_screen_37.dart';
import 'host/become_host_screen_28.dart';
import 'host/host_property_submitted_thankyou_screen.dart';
import 'driver/driver_home_dashboard_screen_83.dart';
import 'driver/become_driver_screen_29.dart';
import 'onboarding/application_submitted_screen_23.dart';
import 'onboarding/driver_application_rejected_screen.dart';
import '../../services/host_service.dart';
import '../../services/driver_service.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String? phoneNumber;
  final bool isExistingUser;

  const RoleSelectionScreen({
    super.key,
    this.phoneNumber,
    this.isExistingUser = false,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = 'Customer';
  bool _isLoading = false;

  void _confirmRole() async {
    setState(() {
      _isLoading = true;
    });

    final phone = widget.phoneNumber ?? '+91 98765 43210';

    // 🚀 Call Backend Mobile Login Step 3: Select Role & Obtain JWT Token (POST /api/auth/mobile/select-role)
    final roleRes = await AuthService.selectRoleMobile(
      phone: phone,
      role: _selectedRole,
    );

    final user = roleRes['user'] ?? (roleRes['data'] is Map ? roleRes['data']['user'] : null);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    // Navigate directly to appropriate screen for selected role
    if (_selectedRole == 'Customer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
      );
    } else if (_selectedRole == 'Host') {
      // Dynamic host name resolution
      final resolvedHostName = (user != null && user['name'] != null && user['name'].toString().isNotEmpty)
          ? user['name'].toString()
          : await AuthService.getUserName(phone: phone);

      // Check approval status: Gated from dashboard until property is approved
      final approval = await HostService.checkHostApprovalStatus(
        hostPhone: phone,
        userProfile: user is Map<String, dynamic> ? user : (user is Map ? Map<String, dynamic>.from(user) : null),
      );

      if (!mounted) return;

      if (approval.status == HostApprovalStatus.noProperties) {
        // Case 1: Host has not registered any properties yet
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BecomeHostScreen()),
        );
      } else if (approval.status == HostApprovalStatus.pendingApproval) {
        // Case 2: Host submitted properties but pending admin approval -> Gated
        final firstProp = approval.properties.isNotEmpty ? approval.properties.first : null;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HostPropertySubmittedThankYouScreen(
              hostPhone: phone,
              hostName: resolvedHostName,
              propertyTitle: firstProp?['title'] ?? firstProp?['name'] ?? 'Submitted Property',
              propertyType: firstProp?['type'] ?? 'Hotel',
            ),
          ),
        );
      } else {
        // Case 3: Approved by admin -> Host Dashboard
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HostHomeDashboardScreen(userName: resolvedHostName)),
        );
      }
    } else {
      // Driver Role Selected
      final statusResult = await DriverService.getDriverApprovalStatus(phone: phone);
      final isApproved = statusResult['isApproved'] == true;
      final status = (statusResult['status'] ?? '').toString().toLowerCase();
      final kyc = (statusResult['kyc'] ?? '').toString().toLowerCase();
      final isRejected = status == 'suspended' || status == 'rejected' || kyc == 'rejected';

      final driverData = statusResult['driver'];
      final hasSubmittedDocuments = driverData != null &&
          ((driverData['documents'] is Map &&
                  (driverData['documents']['vehicleRegistration']?.toString().isNotEmpty == true ||
                   driverData['documents']['pollutionCertificate']?.toString().isNotEmpty == true)) ||
           (driverData['vehicleInfo'] is Map &&
                  driverData['vehicleInfo']['vehicleNumberPlate']?.toString().isNotEmpty == true));

      if (!mounted) return;

      if (isApproved) {
        // Case 1: Approved by Admin -> Driver Dashboard (Screen 83)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DriverHomeDashboardScreen83()),
        );
      } else if (isRejected) {
        // Case 2: Rejected by Admin -> Application Rejected Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverApplicationRejectedScreen(
              rejectionReason: statusResult['message']?.toString(),
              driverPhone: phone,
            ),
          ),
        );
      } else if (status == 'pending' && hasSubmittedDocuments) {
        // Case 3: Application Pending / Under Review -> Application Submitted Screen (Screen 82/23)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ApplicationSubmittedScreen(driverPhone: phone),
          ),
        );
      } else {
        // Case 4: Not yet submitted -> Get Started (Screen 29)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BecomeDriverScreen()),
        );
      }
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
            // Bottom Background Graphic (image 31.png)
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
              // Back Button matching Screen 27
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.inputBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
                ),
              ),

              const SizedBox(height: 28),

              // Title Header matching Screen 27
              const Text(
                'Choose your role',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select a role to continue',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 36),

              // Role Option Card 1: Customer
              _buildRoleOptionCard(
                role: 'Customer',
                subtitle: 'book a stay and rides',
                icon: Icons.person_rounded,
                iconColor: const Color(0xFFFBC02D),
                iconBgColor: const Color(0xFFFFFDE7),
              ),

              const SizedBox(height: 16),

              // Role Option Card 2: Host
              _buildRoleOptionCard(
                role: 'Host',
                subtitle: 'List your properties',
                icon: Icons.home_rounded,
                iconColor: const Color(0xFFE53935),
                iconBgColor: const Color(0xFFFFEBEE),
              ),

              const SizedBox(height: 16),

              // Role Option Card 3: Driver
              _buildRoleOptionCard(
                role: 'Driver',
                subtitle: 'Offer rides and earns',
                icon: Icons.directions_car_rounded,
                iconColor: const Color(0xFFD32F2F),
                iconBgColor: const Color(0xFFFFEBEE),
              ),

              const SizedBox(height: 48),

              // Confirm Button matching Screen 27
              CustomButton(
                text: 'Confirm',
                isLoading: _isLoading,
                onPressed: _confirmRole,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    ),
  ),
);
  }

  Widget _buildRoleOptionCard({
    required String role,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F5FE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Role Icon in Circular Badge matching Screen 27
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
