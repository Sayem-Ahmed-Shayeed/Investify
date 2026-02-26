import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/theme/app_colors.dart';
import '../../controller/post_detail_controller.dart';

class PostDetailFounders extends StatelessWidget {
  final PostDetailController controller;

  const PostDetailFounders({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Founders',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final userData = controller.userData.value;
            final name = userData?['name'] ?? 'Founder';
            final profileImageUrl = userData?['profileImageUrl'];

            return SizedBox(
              width: 100,
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'CEO & Founder',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String name, bool isDark) {
    return Container(
      color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'F',
          style: TextStyle(
            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
