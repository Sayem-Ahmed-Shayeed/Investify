import 'package:flutter/material.dart';

import '../../../../utils/theme/app_colors.dart';

class PostDetailFinancials extends StatelessWidget {
  const PostDetailFinancials({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KEY FINANCIALS',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _FinancialCard(label: 'Target Raise', value: '\$2M'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FinancialCard(label: 'Valuation (Cap)', value: '\$15M'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FinancialCard(label: 'Min Ticket', value: '\$25k'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FinancialCard(label: 'Runway', value: '18 Mo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final String label;
  final String value;

  const _FinancialCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
