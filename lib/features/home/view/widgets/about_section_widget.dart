import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/theme/app_colors.dart';
import '../../controller/post_detail_controller.dart';

class PostDetailAbout extends StatelessWidget {
  final PostDetailController controller;

  const PostDetailAbout({super.key, required this.controller});

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
            'About',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final isExpanded = controller.isAboutExpanded.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.post.content,
                  maxLines: isExpanded ? null : 4,
                  overflow: isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: controller.toggleAboutExpanded,
                  child: Text(
                    isExpanded ? 'Show less' : 'Read more',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
