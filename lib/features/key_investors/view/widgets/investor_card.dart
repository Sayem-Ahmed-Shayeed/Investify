import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/common_methods.dart';
import '../../../../utils/sizes/size.dart';
import '../../../../utils/theme/app_colors.dart';
import 'contact_button.dart';

class InvestorCard extends StatelessWidget {
  const InvestorCard({super.key, required this.investor});

  final Map<String, dynamic> investor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;

    return Card(
      margin: const EdgeInsets.only(bottom: MySizes.medium),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: isDark ? 0 : 1,
      child: Padding(
        padding: const EdgeInsets.all(MySizes.containerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: MySizes.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investor['institutionName'] ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        investor['investorName'] ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        investor['investorDesignation'] ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: MySizes.medium),
            Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
              height: 1,
            ),
            const SizedBox(height: MySizes.medium),

            // Contact buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContactButton(
                  theme: theme,
                  icon: Icons.phone,
                  label: investor['contactNumber'] ?? '',
                  color: Colors.green.shade600,
                  onTap: () => launchPhone(investor['contactNumber'] ?? ''),
                ),
                const SizedBox(height: MySizes.medium),
                ContactButton(
                  theme: theme,
                  icon: Icons.email,
                  label: investor['email'] ?? '',
                  color: Colors.blue.shade600,
                  onTap: () => launchEmail(investor['email'] ?? ''),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
