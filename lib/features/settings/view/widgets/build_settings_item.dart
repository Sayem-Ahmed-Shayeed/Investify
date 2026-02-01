import 'package:flutter/material.dart';

import '../../../../utils/sizes/size.dart';

class BuildSettingsItem extends StatelessWidget {
  const BuildSettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RomRomSizes.roundedBoxCorner),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RomRomSizes.containerPadding,
            vertical: RomRomSizes.medium,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(RomRomSizes.roundedButtonCorner),
                decoration: BoxDecoration(
                  color: (iconColor ?? theme.colorScheme.primary).withValues(
                    alpha: 0.15,
                  ),
                  borderRadius: BorderRadius.circular(
                    RomRomSizes.roundedButtonCorner,
                  ),
                ),
                child: Icon(
                  icon,
                  size: RomRomSizes.iconMedium,
                  color: iconColor ?? theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: RomRomSizes.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor ?? theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle ?? "",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing ?? Container(),
            ],
          ),
        ),
      ),
    );
  }
}
