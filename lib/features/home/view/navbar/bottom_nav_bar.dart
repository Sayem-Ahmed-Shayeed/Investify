import 'package:flutter/material.dart';
import 'package:investify/features/home/view/navbar/widgets/nav_item.dart';
import 'package:investify/utils/sizes/size.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A38) : const Color(0xFF2C3E50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: RomRomSizes.small),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            NavItem(icon: Icons.home_filled, label: 'Home', clickedTabIndex: 0),
            NavItem(icon: Icons.layers, label: 'Sandbox', clickedTabIndex: 1),
            NavItem(
              icon: Icons.chat_bubble,
              label: 'Messages',
              clickedTabIndex: 2,
              showBadge: true,
            ),
            NavItem(
              icon: Icons.calendar_month,
              label: 'Calendar',
              clickedTabIndex: 3,
            ),
          ],
        ),
      ),
    );
  }
}
