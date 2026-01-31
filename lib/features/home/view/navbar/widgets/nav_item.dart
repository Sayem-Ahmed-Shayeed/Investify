import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/nav_bar_controller.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int clickedTabIndex;
  final bool showBadge;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.clickedTabIndex,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final navBarController = Get.find<NavBarController>();
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.outline;

    return GestureDetector(
      onTap: () {
        navBarController.onTabChanged(clickedTabIndex);
      },
      behavior: HitTestBehavior.opaque,
      child: Obx(() {
        final isSelected =
            navBarController.currentTabIndex.value == clickedTabIndex;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
                if (showBadge)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? selectedColor : unselectedColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }),
    );
  }
}
