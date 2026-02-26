import 'dart:io';

import 'package:flutter/material.dart';
import 'package:investify/utils/sizes/size.dart';

/// Widget for displaying gallery images with remove capability
class GalleryImageItem extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRemove;
  final double size;

  const GalleryImageItem({
    super.key,
    required this.imagePath,
    required this.onRemove,
    this.size = MySizes.galleryItemSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MySizes.roundedButtonCorner),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(MySizes.roundedButtonCorner),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: MySizes.closeButtonPadding,
          right: MySizes.closeButtonPadding,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(MySizes.closeButtonPadding),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: MySizes.closeButtonSize,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
