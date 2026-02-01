import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/sizes/size.dart';
import '../../../settings/controller/theme_controller.dart';

class DarkModeItem extends StatelessWidget {
  const DarkModeItem({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);
    
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RomRomSizes.containerPadding,
          vertical: RomRomSizes.small,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(RomRomSizes.roundedButtonCorner),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(
                  RomRomSizes.roundedButtonCorner,
                ),
              ),
              child: Icon(
                themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                size: RomRomSizes.iconMedium,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: RomRomSizes.medium),
            Expanded(
              child: Text(
                'Dark Mode',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Switch.adaptive(
              value: themeController.isDarkMode,
              onChanged: (_) => themeController.toggleTheme(),
            ),
          ],
        ),
      );
    });
  }
}
