import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/utils/sizes/size.dart';

import '../../../auth/controller/auth_controller.dart';
import 'build_settings_item.dart';

class LogOutItem extends StatelessWidget {
  const LogOutItem({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BuildSettingsItem(
      icon: Icons.logout,
      title: 'Sign Out',
      iconColor: Colors.red,
      textColor: Colors.red,
      onTap: () {
        _showLogoutConfirmation(theme);
      },
    );
  }

  void _showLogoutConfirmation(ThemeData theme) {
    final authController = Get.find<AuthController>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(RomRomSizes.xl),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(RomRomSizes.roundedBoxCorner),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: RomRomSizes.xl),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Warning icon
              Container(
                padding: const EdgeInsets.all(RomRomSizes.containerPadding),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout,
                  size: RomRomSizes.xxxl,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: RomRomSizes.xl),
              // Title
              Text(
                'Sign Out',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: RomRomSizes.small),
              
              Text(
                'Are you sure you want to sign out of your account?',
                textAlign: TextAlign.center,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: RomRomSizes.xxl),
              // Sign Out Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    authController.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      vertical: RomRomSizes.containerPadding,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        RomRomSizes.roundedBoxCorner,
                      ),
                    ),
                  ),
                  child: Text(
                    'Sign Out',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Get.isDarkMode
                          ? Get.theme.colorScheme.onSurface
                          : Get.theme.colorScheme.surface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: RomRomSizes.medium),
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: RomRomSizes.containerPadding,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        RomRomSizes.roundedBoxCorner,
                      ),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Get.theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
