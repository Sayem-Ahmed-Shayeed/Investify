import 'package:flutter/material.dart';

import '../../utils/theme/app_colors.dart';

class RoleBadge extends StatelessWidget {
  final bool isInvestor;
  final double size;

  const RoleBadge({super.key, required this.isInvestor, this.size = 18});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isInvestor) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 4),
          ImageIcon(
            AssetImage('assets/icons/investor.png'),
            size: 18,
            color: isDark ? AppColors.primaryDark : Colors.black,
          ),
        ],
      );
    }

    return Icon(
      Icons.verified,
      color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      size: size,
    );
  }
}
