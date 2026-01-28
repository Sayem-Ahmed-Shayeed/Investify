import 'package:flutter/material.dart';
import 'package:investify/utils/theme/app_colors.dart';

class SocialButton extends StatelessWidget {
  final IconData icon;

  const SocialButton({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: theme.iconTheme.color),
    );
  }
}
