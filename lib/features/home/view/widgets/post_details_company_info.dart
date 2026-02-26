import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/theme/app_colors.dart';
import '../../controller/post_detail_controller.dart';

class PostDetailCompanyInfo extends StatelessWidget {
  final PostDetailController controller;

  const PostDetailCompanyInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.inputFillDark
                  : AppColors.inputFillLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? AppColors.cardBorderDark
                    : AppColors.cardBorderLight,
              ),
            ),
            child: Obx(() {
              final userData = controller.userData.value;
              final name = userData?['name'] ?? 'S';
              final profileImageUrl = userData?['profileImageUrl'];

              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    profileImageUrl != null &&
                        profileImageUrl.toString().isNotEmpty
                    ? Image.network(
                        profileImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildPlaceholder(name, isDark),
                      )
                    : _buildPlaceholder(name, isDark),
              );
            }),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(() {
              final userData = controller.userData.value;
              final name = userData?['name'] ?? 'Loading...';
              final bio = userData?['bio'] ?? '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.verified,
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                        size: 20,
                      ),
                    ],
                  ),
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      bio,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String name, bool isDark) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'S',
        style: TextStyle(
          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
