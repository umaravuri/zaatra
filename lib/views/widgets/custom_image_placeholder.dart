import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final IconData icon;
  final String? label;
  final String? imageUrl;
  final BorderRadius? borderRadius;

  const CustomImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.icon = Icons.image_rounded,
    this.label,
    this.imageUrl,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(14);

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      final img = imageUrl!.trim();
      return ClipRRect(
        borderRadius: effectiveRadius,
        child: SizedBox(
          width: width,
          height: height,
          child: img.startsWith('http')
              ? Image.network(
                  img,
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                )
              : Image.asset(
                  img,
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                ),
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
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
