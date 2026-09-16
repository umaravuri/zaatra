import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';

class DriverStatusScreen extends StatelessWidget {
  final String role;

  const DriverStatusScreen({Key? key, this.role = 'Driver'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('$role Verification Status'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card matching Screen 16
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Under Review ⏳',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '$role Account Pending Approval',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Our verification team is inspecting your documents.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Verification Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),

              const SizedBox(height: 16),

              // Verification Checklist Timeline matching Screen 16
              _buildTimelineStep(
                title: 'Personal Information',
                subtitle: 'Full name, DOB, and contact details',
                status: 'Verified',
                isDone: true,
              ),

              _buildTimelineStep(
                title: 'Document Verification',
                subtitle: 'Government ID & Driving License photo',
                status: 'In Review',
                isDone: false,
                isCurrent: true,
              ),

              _buildTimelineStep(
                title: 'Vehicle & Background Check',
                subtitle: 'Vehicle registration & safety check',
                status: 'Pending',
                isDone: false,
              ),

              const SizedBox(height: 36),

              CustomButton(
                text: 'Go to Dashboard',
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required String status,
    required bool isDone,
    bool isCurrent = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primaryBackground : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? AppColors.primary : AppColors.border,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.success
                  : (isCurrent ? AppColors.primary : AppColors.inputBackground),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check_rounded : (isCurrent ? Icons.hourglass_top_rounded : Icons.lock_clock_rounded),
              color: isDone || isCurrent ? Colors.white : AppColors.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFFE8F5E9)
                  : (isCurrent ? AppColors.accentLight : AppColors.inputBackground),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDone
                    ? AppColors.success
                    : (isCurrent ? AppColors.accent : AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
