import 'package:flutter/material.dart';
import 'package:investify/utils/sizes/size.dart';
import 'package:investify/utils/theme/app_colors.dart';

class SandboxTab extends StatelessWidget {
  const SandboxTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(RomRomSizes.roundedBoxCorner),
            border: Border.all(
              color: isDark
                  ? AppColors.cardBorderDark
                  : AppColors.cardBorderLight,
              width: 0.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.inputFillDark
                      : AppColors.inputFillLight,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.layers,
                  size: 60,
                  color: theme.iconTheme.color,
                ),
              ),
              const SizedBox(height: RomRomSizes.spaceBetweenElements),
              Text("Sandbox", style: theme.textTheme.headlineMedium),
              const SizedBox(height: RomRomSizes.spaceBetweenItem),
              Text(
                "Test your investment strategies here",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: RomRomSizes.spaceBetweenElements),
              Text(
                "Coming soon...",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
