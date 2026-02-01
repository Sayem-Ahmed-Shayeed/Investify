import 'package:flutter/material.dart';

Widget buildAppVersion(ThemeData theme) {
  return Padding(
    padding: const EdgeInsets.only(top: 150),
    child: Center(
      child: Text(
        'Investify v1.0.0',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    ),
  );
}
