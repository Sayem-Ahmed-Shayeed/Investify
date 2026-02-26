import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/controller/auth_controller.dart';
import 'package:investify/features/home/view/navbar/widgets/nav_item.dart';
import 'package:investify/utils/sizes/size.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: theme.colorScheme.surface),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: RomRomSizes.small),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (authController.isVerified.value)
                  Expanded(
                    child: NavItem(
                      icon: Icons.home_filled,
                      label: 'Home',
                      clickedTabIndex: 0,
                    ),
                  ),
                if (authController.isVerified.value)
                  Expanded(
                    child: NavItem(
                      icon: Icons.layers,
                      label: 'Sandbox',
                      clickedTabIndex: 1,
                    ),
                  ),
                if (authController.isVerified.value)
                  Expanded(
                    child: NavItem(
                      icon: Icons.chat_bubble,
                      label: 'Messages',
                      clickedTabIndex: 2,
                    ),
                  ),
                if (authController.isVerified.value)
                  Expanded(
                    child: NavItem(
                      icon: Icons.post_add,
                      label: 'Add Pitch',
                      clickedTabIndex: 3,
                    ),
                  ),
                if (authController.isVerified.value)
                  Expanded(
                    child: NavItem(
                      icon: Icons.calendar_month,
                      label: 'Calendar',
                      clickedTabIndex: 4,
                    ),
                  ),
                Expanded(
                  child: NavItem(
                    icon: Icons.person,
                    label: 'Profile',
                    clickedTabIndex: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
