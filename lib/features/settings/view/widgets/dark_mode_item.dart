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
          horizontal: MySizes.containerPadding,
          vertical: MySizes.small,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(MySizes.roundedButtonCorner),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(
                  MySizes.roundedButtonCorner,
                ),
              ),
              child: Icon(
                themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                size: MySizes.iconMedium,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: MySizes.medium),
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
