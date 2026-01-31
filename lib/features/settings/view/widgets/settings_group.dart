import 'package:flutter/material.dart';

import '../../../../utils/sizes/size.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(RomRomSizes.roundedBoxCorner),
      ),
      child: Column(children: children),
    );
  }
}

Widget buildArrow(ThemeData theme) {
  return Icon(
    Icons.chevron_right,
    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
    size: RomRomSizes.xl,
  );
}
