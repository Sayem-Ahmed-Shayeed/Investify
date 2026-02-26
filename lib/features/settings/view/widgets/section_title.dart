import 'package:flutter/material.dart';

import '../../../../utils/sizes/size.dart';

Widget buildSectionTitle(ThemeData theme, String title) {
  return Padding(
    padding: const EdgeInsets.only(
      left: MySizes.small,
      bottom: MySizes.roundedButtonCorner,
      top: MySizes.small,
    ),
    child: Text(
      title.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );
}
