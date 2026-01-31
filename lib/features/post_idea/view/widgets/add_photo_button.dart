import 'package:flutter/material.dart';
import 'package:investify/utils/sizes/size.dart';
import 'package:investify/utils/theme/app_colors.dart';

/// Widget for the add photo button
class AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;

  const AddPhotoButton({
    super.key,
    required this.onTap,
    this.size = RomRomSizes.galleryItemSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(RomRomSizes.roundedButtonCorner),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: RomRomSizes.iconLarge,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: RomRomSizes.spaceBetweenItem),
            Text(
              'ADD PHOTO',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: RomRomSizes.roundedButtonCorner,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
