import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final IconData icon;
  final String? label;
  final BorderRadius? borderRadius;

  const CustomImagePlaceholder({
    Key? key,
    this.width,
    this.height,
    this.icon = Icons.image_rounded,
    this.label,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDF7),
        borderRadius: borderRadius ?? BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: (height != null && height! < 60) ? 22 : 28),
          if (label != null) const SizedBox(height: 4),
          if (label != null)
            Text(
              label!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
